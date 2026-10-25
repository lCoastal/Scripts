--[[
    Steal An Egg — Egg Watcher  (read-only)
    ------------------------------------------------------------
    * Reads the live field-egg snapshot (same call the game's own client makes)
    * Filters: money/s, weight, size boost vs average, name, rarity
    * When a new batch of eggs spawns, posts matches to a Discord webhook
    * Editable webhook URL, ping target (user ID) and message template
    * Does NOT move you, steal, sell, teleport or touch anything in the game.

    UI: RightCtrl = show / hide window
    Config is saved to  EggWatcher_config.json  in your executor workspace.

    Template placeholders:
      {ping} {count} {total} {eggs} {joinlink} {server} {player} {time} {place}
]]

--------------------------------------------------------------------
-- SERVICES / SINGLETON
--------------------------------------------------------------------
local Players     = game:GetService("Players")
local RS          = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UIS         = game:GetService("UserInputService")
local LP          = Players.LocalPlayer

if _G.__EGGWATCH then pcall(_G.__EGGWATCH.Stop) task.wait(0.2) end

local ALIVE = true
local conns = {}

--------------------------------------------------------------------
-- FIELD NAME ALIASES  (edit here if the game renames things)
--------------------------------------------------------------------
local F = {
    uid      = { "Uid", "UID", "Id" },
    category = { "AssetCategory", "Category", "Asset", "EggCategory" },
    scale    = { "AssetScale", "Scale", "Size" },
    muts     = { "Mutations", "Mutation" },
    area     = { "Area", "AreaId", "Zone" },
    weight   = { "WeightKg", "Weight" },                  -- on the egg record, if present
    -- on the Assets definition:
    d_rate   = { "EarningRate", "Earning", "MoneyPerSecond" },
    d_name   = { "DisplayName", "Name", "_id" },
    d_rarity = { "Rarity", "RarityName", "Tier", "Grade" },
}
local EXP = 1.85 -- Scale exponent in the money formula (documented in the Kiwzu repo)

local function pick(t, names)
    if type(t) ~= "table" then return nil end
    for _, n in ipairs(names) do
        if t[n] ~= nil then return t[n] end
    end
    return nil -- explicit: falling off the end returns NO value, and tonumber(pick(..)) then errors "missing argument #1"
end

--------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------
local FILE = "EggWatcher_config.json"
local CFG = {
    Enabled       = true,
    Interval      = 3,            -- seconds between scans
    NotifyOnStart = false,        -- also notify for eggs already present at load
    MaxLines      = 15,           -- eggs listed per message

    -- filters (leave blank = ignored). MatchMode ALL = every set filter must pass, ANY = at least one
    MatchMode     = "ALL",
    MinMoney      = "",           -- money / second, accepts 10M, 2.5b, 1t ...
    MinWeight     = "",           -- kg
    MinSize       = "",           -- % bigger than average (negative = smaller)
    MaxSize       = "",           -- % bigger than average
    Names         = {},           -- set of selected egg names  { ["Dragon Egg"] = true }  (empty = ignore)
    Rarities      = {},           -- set of selected rarities   { ["Legendary"] = true }   (empty = ignore)
    SizeBaseline  = "BASE",       -- BASE = Scale 1.0 is average | FIELD = average of same egg type in the server right now

    -- webhook
    Webhook       = "",
    UserId        = "",           -- Discord user ID to ping (digits) — blank = no ping
    UseEmbed      = true,
    Username      = "Egg Watcher",
    Template      = "{ping} **{count}** matching egg(s) just spawned! ({total} eggs in the server)\n{eggs}\n[Join this server]({joinlink})",
}

local HAS_FS = type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function"
local function saveCfg()
    if not HAS_FS then return end
    pcall(function() writefile(FILE, HttpService:JSONEncode(CFG)) end)
end
local function loadCfg()
    if not HAS_FS then return end
    pcall(function()
        if isfile(FILE) then
            local data = HttpService:JSONDecode(readfile(FILE))
            for k, v in pairs(data) do
                if CFG[k] ~= nil and type(v) == type(CFG[k]) then CFG[k] = v end
            end
        end
    end)
end
loadCfg()

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------
local function parseAmount(v)
    if type(v) == "number" then return v end
    if type(v) ~= "string" then return nil end
    local s = v:gsub(",", ""):gsub("%s", "")
    if s == "" then return nil end
    local num, suf = s:match("^(-?[%d%.]+)(%a*)$")
    local n = num and tonumber(num)
    if not n then return nil end
    local mult = ({ k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15, qa = 1e15, qi = 1e18 })[suf:lower()] or 1
    return n * mult
end

local function short(n)
    n = tonumber(n) or 0
    for _, u in ipairs({ { 1e18, "Qi" }, { 1e15, "Qa" }, { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }) do
        if n >= u[1] then return string.format("%.2f%s", n / u[1], u[2]) end
    end
    return string.format("%.0f", n)
end

local function countKeys(t)
    local n = 0
    for _ in pairs(t) do n += 1 end
    return n
end

--------------------------------------------------------------------
-- GAME DATA BINDINGS (read-only)
--------------------------------------------------------------------
local function tryModule(paths, field)
    for _, path in ipairs(paths) do
        local node = RS
        for seg in path:gmatch("[^%.]+") do node = node and node:FindFirstChild(seg) end
        if node and node:IsA("ModuleScript") then
            local ok, mod = pcall(require, node)
            if ok and type(mod) == "table" then
                local v = field and mod[field] or mod
                if type(v) == "table" then return v end
            end
        end
    end
end

local Assets    = tryModule({ "Data.Assets", "Directory.Assets" }, "Directory") or {}
local Mutations = tryModule({ "Shared.Modules.Mutations", "Library.Modules.Mutations" })

-- Fallback: if the known path is gone, search the Data/Directory folders for a module whose
-- entries look like eggs (they carry an `Egg` sub-table with WeightKg / GrowthTime).
if next(Assets) == nil then
    for _, folderName in ipairs({ "Data", "Directory" }) do
        local folder = RS:FindFirstChild(folderName)
        if folder and next(Assets) == nil then
            for _, m in ipairs(folder:GetDescendants()) do
                if m:IsA("ModuleScript") then
                    local ok, mod = pcall(require, m)
                    if ok and type(mod) == "table" then
                        local dir = type(mod.Directory) == "table" and mod.Directory or mod
                        for _, v in pairs(dir) do
                            if type(v) == "table" and type(v.Egg) == "table" then Assets = dir break end
                        end
                    end
                end
                if next(Assets) ~= nil then break end
            end
        end
    end
end

local function rarityOf(def)
    local r = pick(def, F.d_rarity)
    if type(r) == "table" then r = r.Name or r.name or r.DisplayName end
    if r == nil then return nil end
    return tostring(r)
end

-- the egg's own name ("Drilla Egg") lives in def.Egg.DisplayName; def.DisplayName is the pet ("Drilla")
local function eggNameOf(def, fallback)
    local egg = type(def) == "table" and def.Egg or nil
    local n = type(egg) == "table" and egg.DisplayName or nil
    if n == nil then n = pick(def, F.d_name) end
    return tostring(n or fallback)
end

-- Every egg name / rarity the dropdowns can offer. Filled from the game's data table at load,
-- and topped up with anything seen in live snapshots.
local OPTIONS = { names = {}, rarities = {} }
local function addOption(kind, v)
    if v ~= nil and v ~= "" and not OPTIONS[kind][v] then OPTIONS[kind][v] = true return true end
    return false
end

local function discoverOptions()
    local eggCount, total = 0, 0
    for id, def in pairs(Assets) do
        if type(def) == "table" then
            total += 1
            if type(def.Egg) == "table" then
                eggCount += 1
                addOption("names", eggNameOf(def, id))
                addOption("rarities", rarityOf(def))
            end
        end
    end
    if eggCount == 0 and total > 0 then -- no `Egg` marker found: offer every asset instead
        for id, def in pairs(Assets) do
            if type(def) == "table" then
                addOption("names", eggNameOf(def, id))
                addOption("rarities", rarityOf(def))
            end
        end
    end
    return eggCount, total
end
local EGGDEFS, ASSETDEFS = discoverOptions()

local function sortedOptions(kind, selected)
    local list, have = {}, {}
    for v in pairs(OPTIONS[kind]) do list[#list + 1] = v; have[v] = true end
    for v in pairs(selected) do if not have[v] then list[#list + 1] = v end end -- keep stale picks visible
    table.sort(list, function(a, b) return a:lower() < b:lower() end)
    return list
end

local function mutationMulti(muts)
    if type(muts) ~= "table" or next(muts) == nil then return 1 end
    if Mutations then
        local fn = Mutations.EarningsFor or Mutations.GetTotalMutationsEarningMulti
        if fn then
            local ok, m = pcall(fn, muts)
            if ok and type(m) == "number" and m > 0 then return m end
        end
    end
    local n = 0
    for _ in pairs(muts) do n += 1 end
    return 2.5 ^ n
end

local function mutationNames(muts)
    local out = {}
    if type(muts) == "table" then
        for k, v in pairs(muts) do
            out[#out + 1] = type(v) == "string" and v or tostring(k)
        end
    end
    return out
end

local function getRemote()
    local pkg  = RS:FindFirstChild("Packages")
    local root = (pkg and pkg:FindFirstChild("Networking")) or RS:FindFirstChild("Network")
    if not root then return nil end
    return root:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
        or root:FindFirstChild("Eggs: RequestAreaEggSnapshot")
end

local function fetchSnapshot()
    local remote = getRemote()
    if not remote then return nil, "snapshot remote not found (game updated?)" end
    local box = {}
    task.spawn(function()
        local ok, res = pcall(function() return remote:InvokeServer() end)
        box.done, box.ok, box.res = true, ok, res
    end)
    local t0 = os.clock()
    while not box.done and os.clock() - t0 < 8 do task.wait(0.05) end
    if not box.done then return nil, "snapshot timed out" end
    if not box.ok then return nil, tostring(box.res) end
    return box.res
end

-- walk the returned table (shape unknown) and gather anything that looks like an egg record
local function collect(t, out, area, depth)
    if type(t) ~= "table" or depth > 5 then return end
    if pick(t, F.uid) ~= nil and pick(t, F.category) ~= nil then
        out[#out + 1] = { rec = t, area = area }
        return
    end
    for k, v in pairs(t) do
        collect(v, out, type(k) == "string" and k or area, depth + 1)
    end
end

local warnedMissing = {}
local function buildEggs(snapshot)
    local raw = {}
    collect(snapshot, raw, nil, 0)

    -- per-category average scale (for SizeBaseline = FIELD)
    local sum, cnt = {}, {}
    for _, r in ipairs(raw) do
        local cat = tostring(pick(r.rec, F.category))
        local sc = tonumber(pick(r.rec, F.scale)) or 1
        sum[cat], cnt[cat] = (sum[cat] or 0) + sc, (cnt[cat] or 0) + 1
    end

    local eggs = {}
    for _, r in ipairs(raw) do
        local rec = r.rec
        local cat = tostring(pick(rec, F.category))
        local def = Assets[cat]
        if not def and not warnedMissing[cat] then warnedMissing[cat] = true end

        local scale = tonumber(pick(rec, F.scale)) or 1
        local rate  = tonumber(pick(def, F.d_rate)) or 0
        local muts  = pick(rec, F.muts)
        local money = rate * (scale ^ EXP) * mutationMulti(muts)

        local baseW = tonumber(pick(rec, F.weight))
        if not baseW and def then
            local egg = def.Egg or def
            baseW = tonumber(pick(egg, F.weight))
            if baseW then baseW = baseW * scale end -- ASSUMPTION: weight scales linearly with size
        end

        local avg = (CFG.SizeBaseline == "FIELD") and (sum[cat] / cnt[cat]) or 1
        local boost = (scale / (avg > 0 and avg or 1) - 1) * 100

        local rarity = rarityOf(def)
        addOption("names", eggNameOf(def, cat))
        addOption("rarities", rarity)

        eggs[#eggs + 1] = {
            uid    = tostring(pick(rec, F.uid)),
            cat    = cat,
            name   = eggNameOf(def, cat),
            pet    = tostring(pick(def, F.d_name) or cat),
            rarity = tostring(rarity or "Unknown"),
            area   = tostring(pick(rec, F.area) or r.area or "?"),
            scale  = scale,
            money  = money,
            weight = baseW,   -- may be nil
            boost  = boost,
            muts   = mutationNames(muts),
        }
    end
    return eggs
end

--------------------------------------------------------------------
-- FILTERS
--------------------------------------------------------------------
local function passes(e)
    local results = {}

    local minM = parseAmount(CFG.MinMoney)
    if minM then results[#results + 1] = e.money >= minM end

    local minW = parseAmount(CFG.MinWeight)
    if minW then results[#results + 1] = (e.weight or 0) >= minW end

    local minS = parseAmount(CFG.MinSize)
    if minS then results[#results + 1] = e.boost >= minS end
    local maxS = parseAmount(CFG.MaxSize)
    if maxS then results[#results + 1] = e.boost <= maxS end

    if next(CFG.Names) ~= nil then
        results[#results + 1] = CFG.Names[e.name] == true or CFG.Names[e.pet] == true or CFG.Names[e.cat] == true
    end
    if next(CFG.Rarities) ~= nil then
        results[#results + 1] = CFG.Rarities[e.rarity] == true
    end

    if #results == 0 then return true end -- no filters set = everything matches
    if CFG.MatchMode == "ANY" then
        for _, r in ipairs(results) do if r then return true end end
        return false
    end
    for _, r in ipairs(results) do if not r then return false end end
    return true
end

--------------------------------------------------------------------
-- WEBHOOK
--------------------------------------------------------------------
local httpReq = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)

local function validWebhook(u)
    return type(u) == "string" and u:match("^https://[%w%.]*discord%.com/api/webhooks/%d+/[%w%-_]+") ~= nil
        or (type(u) == "string" and u:match("^https://[%w%.]*discordapp%.com/api/webhooks/%d+/[%w%-_]+") ~= nil)
end

local function pingString()
    local id = tostring(CFG.UserId or ""):gsub("%s", "")
    if id == "" then return "", nil end
    local digits = id:match("^<@!?(%d+)>$") or id:match("^(%d+)$")
    if not digits then return "", nil end
    return "<@" .. digits .. ">", digits
end

local function eggLine(e)
    local parts = { string.format("• **%s** [%s]", e.name, e.rarity), "$" .. short(e.money) .. "/s" }
    if e.weight then parts[#parts + 1] = string.format("%.2fkg", e.weight) end
    parts[#parts + 1] = string.format("%+.0f%% size", e.boost)
    if #e.muts > 0 then parts[#parts + 1] = "✨" .. table.concat(e.muts, "/") end
    parts[#parts + 1] = "(" .. e.area .. ")"
    return table.concat(parts, " · ")
end

local function renderTemplate(eggs, total, includePing, noEggs)
    local lines = {}
    local sorted = table.clone(eggs)
    table.sort(sorted, function(a, b) return a.money > b.money end)
    local cap = math.max(1, tonumber(CFG.MaxLines) or 15)
    for i, e in ipairs(sorted) do
        if i > cap then lines[#lines + 1] = string.format("…and %d more", #sorted - cap) break end
        lines[#lines + 1] = eggLine(e)
    end
    local pingStr = includePing and select(1, pingString()) or ""
    local map = {
        ping     = pingStr,
        count    = #eggs,
        total    = total,
        eggs     = noEggs and "" or table.concat(lines, "\n"),
        joinlink = ("https://www.roblox.com/games/start?placeId=%d&gameInstanceId=%s"):format(game.PlaceId, game.JobId),
        server   = game.JobId,
        player   = LP.Name,
        time     = os.date("%H:%M:%S"),
        place    = game.PlaceId,
    }
    local out = tostring(CFG.Template):gsub("{(%w+)}", function(k)
        if map[k] ~= nil then return tostring(map[k]) end
        return "{" .. k .. "}"
    end)
    if noEggs then -- drop lines left empty by the missing {eggs}
        local kept = {}
        for line in (out .. "\n"):gmatch("(.-)\n") do
            if line:match("%S") then kept[#kept + 1] = line end
        end
        out = table.concat(kept, "\n")
    end
    return (out:gsub("^%s+", ""))
end

-- one card per egg (Discord allows 10 embeds per message)
local EMBED_TITLE  = "Egg spawned"
local EMBED_FOOTER = "CoastalHub"
local function eggCard(e, isTest)
    local mut = #e.muts > 0 and table.concat(e.muts, ", ") or "None"
    return {
        title  = isTest and ("🧪 TEST — " .. EMBED_TITLE) or EMBED_TITLE,
        color  = 0x57F287,
        fields = {
            { name = "Pet",       value = e.pet or e.name,                                              inline = true },
            { name = "Rarity",    value = e.rarity,                                                     inline = true },
            { name = "Scale",     value = string.format("x%.2f (%+.0f%%)", e.scale, e.boost),           inline = true },
            { name = "Weight",    value = e.weight and string.format("%.2f kg", e.weight) or "?",       inline = true },
            { name = "Income",    value = "$" .. short(e.money) .. "/s",                                inline = true },
            { name = "Mutations", value = mut,                                                          inline = true },
            { name = "Area",      value = e.area,                                                       inline = false },
        },
        footer    = { text = EMBED_FOOTER .. " | " .. LP.Name },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }
end

local logFn = print
local function sendWebhook(eggs, total, isTest)
    if not httpReq then return false, "executor has no http request function" end
    if not validWebhook(CFG.Webhook) then return false, "webhook URL is empty/invalid" end

    local pingStr, pingId = pingString()
    local payload = { username = tostring(CFG.Username ~= "" and CFG.Username or "Egg Watcher") }
    if CFG.UseEmbed then
        local sorted = table.clone(eggs)
        table.sort(sorted, function(x, y) return x.money > y.money end)
        local cap = math.min(10, math.max(1, tonumber(CFG.MaxLines) or 10))
        payload.embeds = {}
        for i, e in ipairs(sorted) do
            if i > cap then break end
            payload.embeds[#payload.embeds + 1] = eggCard(e, isTest)
        end
        -- text above the cards: your template (without {eggs}, since the cards show them)
        local text = renderTemplate(eggs, total, true, true)
        if pingStr ~= "" and not tostring(CFG.Template):find("{ping}", 1, true) then
            text = pingStr .. " " .. text
        end
        if #sorted > cap then text = text .. string.format("\n…and %d more not shown", #sorted - cap) end
        if isTest then text = "🧪 **TEST MESSAGE (not a real spawn)**\n" .. text end
        text = text:sub(1, 1990)
        payload.content = text:match("%S") and text or nil
    else
        payload.content = ((isTest and "🧪 **TEST MESSAGE (not a real spawn)**\n" or "") .. renderTemplate(eggs, total, true)):sub(1, 1990)
    end
    payload.allowed_mentions = { parse = {}, users = pingId and { pingId } or {} }

    local body = HttpService:JSONEncode(payload)
    for attempt = 1, 3 do
        local ok, res = pcall(httpReq, {
            Url = CFG.Webhook, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body,
        })
        if not ok then return false, tostring(res) end
        local code = res.StatusCode or res.status_code or 0
        if code >= 200 and code < 300 then return true end
        if code == 429 then
            local wait = 2
            pcall(function() wait = tonumber(HttpService:JSONDecode(res.Body).retry_after) or 2 end)
            task.wait(math.min(wait, 10) + 0.2)
        else
            return false, "HTTP " .. tostring(code) .. " " .. tostring(res.Body or ""):sub(1, 120)
        end
    end
    return false, "rate limited"
end

--------------------------------------------------------------------
-- UI
--------------------------------------------------------------------
local C = {
    bg = Color3.fromRGB(22, 22, 28), panel = Color3.fromRGB(32, 32, 40), box = Color3.fromRGB(42, 42, 52),
    text = Color3.fromRGB(235, 235, 240), dim = Color3.fromRGB(150, 150, 165), accent = Color3.fromRGB(245, 197, 66),
    good = Color3.fromRGB(80, 200, 120), bad = Color3.fromRGB(220, 80, 80),
}

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local guiParent
pcall(function() guiParent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not guiParent then guiParent = LP:WaitForChild("PlayerGui") end

local gui = new("ScreenGui", { Name = "EggWatcherUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, guiParent)
local win = new("Frame", { Size = UDim2.fromOffset(440, 440), Position = UDim2.new(0, 40, 0.5, -220), BackgroundColor3 = C.bg, BorderSizePixel = 0 }, gui)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, win)

local title = new("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.panel, BorderSizePixel = 0, Text = "  🥚 Egg Watcher", TextColor3 = C.accent,
    Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }, win)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, title)

-- dragging
do
    local dragging, start, startPos
    table.insert(conns, title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, start, startPos = true, i.Position, win.Position
        end
    end))
    table.insert(conns, UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    table.insert(conns, UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

local statusLbl = new("TextLabel", { Position = UDim2.new(0, 8, 0, 64), Size = UDim2.new(1, -16, 0, 18), BackgroundTransparency = 1, Text = "starting…",
    TextColor3 = C.dim, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, win)

local tabBar = new("Frame", { Position = UDim2.new(0, 8, 0, 36), Size = UDim2.new(1, -16, 0, 24), BackgroundTransparency = 1 }, win)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4) }, tabBar)

local pages, tabBtns = {}, {}
local function showPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do b.BackgroundColor3 = (n == name) and C.accent or C.box; b.TextColor3 = (n == name) and C.bg or C.text end
end
local function addPage(name)
    local sf = new("ScrollingFrame", { Position = UDim2.new(0, 8, 0, 88), Size = UDim2.new(1, -16, 1, -96), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false }, win)
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, sf)
    pages[name] = sf
    tabBtns[name] = new("TextButton", { Size = UDim2.fromOffset(100, 24), BackgroundColor3 = C.box, Text = name, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
        TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false }, tabBar)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, tabBtns[name])
    tabBtns[name].MouseButton1Click:Connect(function() showPage(name) end)
    return sf
end

local function label(page, text)
    return new("TextLabel", { Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, TextColor3 = C.dim,
        Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }, page)
end

local function field(page, titleText, key, placeholder, multiline, onChange)
    local row = new("Frame", { Size = UDim2.new(1, -6, 0, multiline and 110 or 48), BackgroundTransparency = 1 }, page)
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = titleText, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local box = new("TextBox", { Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, 0, 1, -20), BackgroundColor3 = C.box, BorderSizePixel = 0,
        Text = tostring(CFG[key] or ""), PlaceholderText = placeholder or "", PlaceholderColor3 = C.dim, TextColor3 = C.text, Font = Enum.Font.Code, TextSize = 12,
        ClearTextOnFocus = false, MultiLine = multiline or false, TextWrapped = multiline or false, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center }, row)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, box)
    new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) }, box)
    box.FocusLost:Connect(function()
        if type(CFG[key]) == "number" then
            local n = tonumber(box.Text)
            if n then CFG[key] = n else box.Text = tostring(CFG[key]) end
        else
            CFG[key] = box.Text
        end
        if onChange then onChange() end
        saveCfg()
    end)
    return box
end

local function button(page, text, fn, color)
    local b = new("TextButton", { Size = UDim2.new(1, -6, 0, 28), BackgroundColor3 = color or C.box, Text = text, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
        TextSize = 12, BorderSizePixel = 0 }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
    b.MouseButton1Click:Connect(function() task.spawn(fn, b) end)
    return b
end

local function toggle(page, text, key)
    local b
    local function refresh() b.Text = text .. ":  " .. (CFG[key] and "ON" or "OFF"); b.BackgroundColor3 = CFG[key] and C.good or C.box end
    b = button(page, text, function() CFG[key] = not CFG[key]; refresh(); saveCfg() end)
    refresh()
    return b
end

local function cycle(page, text, key, options)
    local b
    local function refresh() b.Text = text .. ":  " .. tostring(CFG[key]) end
    b = button(page, text, function()
        local idx = table.find(options, CFG[key]) or 0
        CFG[key] = options[(idx % #options) + 1]
        refresh(); saveCfg()
    end)
    refresh()
    return b
end

-- log page
local pLog = addPage("Log")
local logBox = new("TextLabel", { Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = "", TextColor3 = C.text,
    Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }, pLog)
local logLines = {}
logFn = function(msg)
    logLines[#logLines + 1] = os.date("[%H:%M:%S] ") .. tostring(msg)
    while #logLines > 60 do table.remove(logLines, 1) end
    logBox.Text = table.concat(logLines, "\n")
    print("[EggWatcher] " .. tostring(msg))
end

-- (tabs are created in display order, so rebuild order: Filters, Webhook, Message, Log)
for _, b in pairs(tabBtns) do b:Destroy() end
tabBtns = {}
local pFilters = addPage("Filters")
local pHook    = addPage("Webhook")
local pMsg     = addPage("Message")
pLog.Parent = nil; pLog.Parent = win; pages["Log"] = pLog
tabBtns["Log"] = new("TextButton", { Size = UDim2.fromOffset(100, 24), BackgroundColor3 = C.box, Text = "Log", TextColor3 = C.text, Font = Enum.Font.GothamMedium,
    TextSize = 12, BorderSizePixel = 0, AutoButtonColor = false }, tabBar)
new("UICorner", { CornerRadius = UDim.new(0, 5) }, tabBtns["Log"])
tabBtns["Log"].MouseButton1Click:Connect(function() showPage("Log") end)

-- FILTERS PAGE
toggle(pFilters, "Watching", "Enabled")
cycle(pFilters, "Match mode (ALL filters / ANY filter)", "MatchMode", { "ALL", "ANY" })
label(pFilters, "Leave a filter blank to ignore it. Money accepts suffixes: 500k, 10M, 2.5b, 1t.")
field(pFilters, "Min money / second", "MinMoney", "e.g. 10M")
field(pFilters, "Min weight (kg)", "MinWeight", "e.g. 2.5")
field(pFilters, "Min size boost (% vs average)", "MinSize", "e.g. 30   (negative = smaller)")
field(pFilters, "Max size boost (% vs average)", "MaxSize", "e.g. -10 to find tiny ones")
cycle(pFilters, "Size baseline (BASE = scale 1.0 / FIELD = server avg)", "SizeBaseline", { "BASE", "FIELD" })
-- click to expand, click an entry to select it, click again to unselect it
local function multiSelect(page, titleText, key, kind, emptyText)
    local holder = new("Frame", { Size = UDim2.new(1, -6, 0, 28), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, page)
    new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, holder)

    local head = new("TextButton", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.box, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
        TextSize = 12, BorderSizePixel = 0, Text = "", LayoutOrder = 1 }, holder)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, head)

    local panel = new("Frame", { Size = UDim2.new(1, 0, 0, 210), BackgroundColor3 = C.panel, BorderSizePixel = 0, Visible = false, LayoutOrder = 2 }, holder)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, panel)

    local search = new("TextBox", { Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(1, -70, 0, 24), BackgroundColor3 = C.box, BorderSizePixel = 0,
        Text = "", PlaceholderText = "search…", PlaceholderColor3 = C.dim, TextColor3 = C.text, Font = Enum.Font.Code, TextSize = 12,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, panel)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, search)
    new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, search)

    local clear = new("TextButton", { Position = UDim2.new(1, -62, 0, 4), Size = UDim2.fromOffset(58, 24), BackgroundColor3 = C.bad, Text = "Clear",
        TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 11, BorderSizePixel = 0 }, panel)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, clear)

    local list = new("ScrollingFrame", { Position = UDim2.new(0, 4, 0, 32), Size = UDim2.new(1, -8, 1, -36), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, panel)
    new("UIListLayout", { Padding = UDim.new(0, 2) }, list)

    local function refreshHead()
        local n = countKeys(CFG[key])
        head.Text = string.format("%s:  %s   %s", titleText, n == 0 and emptyText or (n .. " selected"), panel.Visible and "▲" or "▼")
        head.BackgroundColor3 = n > 0 and C.accent or C.box
        head.TextColor3 = n > 0 and C.bg or C.text
    end

    local function rebuild()
        for _, ch in ipairs(list:GetChildren()) do
            if not ch:IsA("UIListLayout") then ch:Destroy() end
        end
        local q = search.Text:lower()
        local shown = 0
        for _, opt in ipairs(sortedOptions(kind, CFG[key])) do
            if q == "" or opt:lower():find(q, 1, true) then
                shown += 1
                local function style(row)
                    local on = CFG[key][opt] == true
                    row.Text = (on and "☑  " or "☐  ") .. opt
                    row.BackgroundColor3 = on and C.good or C.box
                end
                local row = new("TextButton", { Size = UDim2.new(1, -6, 0, 22), TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 12,
                    BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, Text = "", AutoButtonColor = true }, list)
                new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, row)
                style(row)
                row.MouseButton1Click:Connect(function()
                    if CFG[key][opt] then CFG[key][opt] = nil else CFG[key][opt] = true end
                    style(row); refreshHead(); saveCfg()
                end)
            end
        end
        if shown == 0 then
            new("TextLabel", { Size = UDim2.new(1, -6, 0, 40), BackgroundTransparency = 1, TextColor3 = C.dim, Font = Enum.Font.Gotham, TextSize = 11,
                TextWrapped = true, Text = "Nothing to show. Options also fill in automatically as eggs spawn." }, list)
        end
    end

    head.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
        if panel.Visible then rebuild() end
        refreshHead()
    end)
    search:GetPropertyChangedSignal("Text"):Connect(rebuild)
    clear.MouseButton1Click:Connect(function()
        for k in pairs(CFG[key]) do CFG[key][k] = nil end
        saveCfg(); rebuild(); refreshHead()
    end)
    refreshHead()
    return function() if panel.Visible then rebuild() end refreshHead() end
end

local refreshNames  = multiSelect(pFilters, "Egg names", "Names", "names", "any")
local refreshRarity = multiSelect(pFilters, "Rarity", "Rarities", "rarities", "any")
button(pFilters, "Re-scan game data for egg names / rarities", function()
    local eggs, total = discoverOptions()
    refreshNames(); refreshRarity()
    logFn(("egg list: %d names, %d rarities (%d egg defs / %d assets in game data)"):format(
        countKeys(OPTIONS.names), countKeys(OPTIONS.rarities), eggs, total))
end, C.panel)
field(pFilters, "Scan interval (seconds, min 1.5)", "Interval", "3")
toggle(pFilters, "Also notify for eggs already present at start", "NotifyOnStart")

-- WEBHOOK PAGE
label(pHook, "⚠ Your webhook URL is a secret — anyone with it can post in your channel. Don't screen-share this tab.")
field(pHook, "Discord webhook URL", "Webhook", "https://discord.com/api/webhooks/…")
field(pHook, "User ID to ping (blank = no ping)", "UserId", "e.g. 123456789012345678  (Discord → Developer Mode → Copy User ID)")
field(pHook, "Bot display name", "Username", "Egg Watcher")
toggle(pHook, "Use embed (ping stays in plain content)", "UseEmbed")

-- MESSAGE PAGE
label(pMsg, "Placeholders: {ping} {count} {total} {eggs} {joinlink} {server} {player} {time} {place}")
field(pMsg, "Message template", "Template", "", true)
field(pMsg, "Max eggs listed per message", "MaxLines", "15")

--------------------------------------------------------------------
-- CORE LOOP
--------------------------------------------------------------------
local seen, firstScan, lastTotal, lastScanAt, lastBatch = {}, true, 0, 0, 0
local lastEggs = {}

local function setStatus()
    local state = CFG.Enabled and "watching" or "paused"
    local hook = validWebhook(CFG.Webhook) and "webhook ✓" or "webhook ✗"
    statusLbl.Text = string.format("%s · %d eggs · last batch matched %d · %s", state, lastTotal, lastBatch, hook)
    statusLbl.TextColor3 = CFG.Enabled and C.good or C.dim
end

local function scan()
    local snap, err = fetchSnapshot()
    if not snap then logFn("scan failed: " .. tostring(err)) return nil end
    local eggs = buildEggs(snap)
    lastEggs, lastTotal, lastScanAt = eggs, #eggs, os.clock()
    return eggs
end

local function newOnes(eggs)
    local fresh, now = {}, {}
    for _, e in ipairs(eggs) do
        now[e.uid] = true
        if not seen[e.uid] then fresh[#fresh + 1] = e end
    end
    seen = now -- stolen eggs drop out so the set never grows
    return fresh
end

local function process()
    local eggs = scan()
    if not eggs then return end

    local fresh = newOnes(eggs)
    if firstScan then
        firstScan = false
        logFn(("baseline: %d eggs in server (%d asset defs loaded)"):format(#eggs, (function() local n = 0 for _ in pairs(Assets) do n += 1 end return n end)()))
        if not CFG.NotifyOnStart then return end
    end
    if #fresh == 0 then return end

    -- a spawn wave can trickle in; wait briefly and merge anything else new
    task.wait(1.5)
    local again = scan()
    if again then
        for _, e in ipairs(newOnes(again)) do fresh[#fresh + 1] = e end
        eggs = again
    end

    local matches = {}
    for _, e in ipairs(fresh) do if passes(e) then matches[#matches + 1] = e end end
    lastBatch = #matches
    logFn(("new batch: %d eggs, %d match filters"):format(#fresh, #matches))
    if #matches == 0 then return end

    local ok, err = sendWebhook(matches, #eggs)
    logFn(ok and ("webhook sent (%d eggs)"):format(#matches) or ("webhook FAILED: " .. tostring(err)))
end

task.spawn(function()
    while ALIVE do
        if CFG.Enabled then
            local ok, err = pcall(process)
            if not ok then logFn("error: " .. tostring(err)) end
        end
        pcall(setStatus)
        task.wait(math.max(1.5, tonumber(CFG.Interval) or 3))
    end
end)

--------------------------------------------------------------------
-- UTILITY BUTTONS
--------------------------------------------------------------------
button(pFilters, "Preview: scan now & log matches (nothing is sent)", function()
    local eggs = scan()
    if not eggs then return end
    local n = 0
    for _, e in ipairs(eggs) do
        if passes(e) then n += 1; if n <= 10 then logFn(eggLine(e):gsub("%*%*", "")) end end
    end
    logFn(("preview: %d/%d eggs match"):format(n, #eggs))
    showPage("Log")
end, C.panel)

button(pHook, "Send test message", function()
    local sample = {}
    for i = 1, math.min(3, #lastEggs) do sample[i] = lastEggs[i] end
    if #sample == 0 then
        sample[1] = { uid = "test", cat = "TestEgg", name = "Test Egg", rarity = "Legendary", area = "Forest", scale = 1.3, money = 1.5e6,
            weight = 2.4, boost = 30, muts = {} }
    end
    local ok, err = sendWebhook(sample, lastTotal, true)
    logFn(ok and "test message sent" or ("test FAILED: " .. tostring(err)))
    showPage("Log")
end, C.panel)

button(pMsg, "Send test with this template", function()
    local sample = { { uid = "test", cat = "TestEgg", name = "Test Egg", rarity = "Legendary", area = "Forest", scale = 1.3, money = 1.5e6,
        weight = 2.4, boost = 30, muts = { "Golden" } } }
    local ok, err = sendWebhook(sample, lastTotal, true)
    logFn(ok and "test message sent" or ("test FAILED: " .. tostring(err)))
    showPage("Log")
end, C.panel)

button(pMsg, "Reset template to default", function(b)
    CFG.Template = "{ping} **{count}** matching egg(s) just spawned! ({total} eggs in the server)\n{eggs}\n[Join this server]({joinlink})"
    saveCfg()
    logFn("template reset — reopen the tab to see it")
end, C.panel)

button(pLog, "Debug: dump first egg's raw fields to console (F9)", function()
    local snap, err = fetchSnapshot()
    if not snap then logFn("dump failed: " .. tostring(err)) return end
    local raw = {}
    collect(snap, raw, nil, 0)
    if #raw == 0 then
        logFn("no egg-like records found. Top-level keys of snapshot:")
        for k, v in pairs(snap) do print("  ", k, typeof(v)) end
        return
    end
    local rec = raw[1].rec
    print("=== first egg record ===")
    for k, v in pairs(rec) do print("  ", k, "=", typeof(v) == "table" and "<table>" or tostring(v)) end
    local def = Assets[tostring(pick(rec, F.category))]
    print("=== its Assets definition ===")
    if def then for k, v in pairs(def) do print("  ", k, "=", typeof(v) == "table" and "<table>" or tostring(v)) end else print("  (none found)") end
    logFn("dumped to console — use it to fix the alias table at the top of the script if a field is wrong")
end, C.panel)

button(pLog, "Close & unload script", function() _G.__EGGWATCH.Stop() end, C.bad)

--------------------------------------------------------------------
-- HOTKEY / STOP
--------------------------------------------------------------------
table.insert(conns, UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightControl then win.Visible = not win.Visible end
end))

_G.__EGGWATCH = {
    Stop = function()
        ALIVE = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() gui:Destroy() end)
        _G.__EGGWATCH = nil
    end,
}

showPage("Filters")
setStatus()
if not httpReq then logFn("WARNING: your executor exposes no http request function — webhooks can't be sent") end
if next(Assets) == nil then
    logFn("WARNING: couldn't load the Assets table — money/s will be 0. Dropdowns will fill in as eggs spawn. Run EggDiscover.lua for details.")
else
    logFn(("egg list: %d names, %d rarities loaded (%d egg defs / %d assets)"):format(
        countKeys(OPTIONS.names), countKeys(OPTIONS.rarities), EGGDEFS, ASSETDEFS))
end
logFn("ready — RightCtrl hides/shows this window")
