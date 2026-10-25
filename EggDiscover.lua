--[[
    Steal An Egg — Egg Discover  (read-only)
    Lists every egg the game knows about: id, display name, rarity, earning rate,
    plus the exact field names used in the data. Prints to the console (F9) and
    saves EggDump.txt to your executor workspace (also copies it to clipboard if supported).

    How it works: the game ships its asset table as a ModuleScript in ReplicatedStorage
    (Data.Assets). We require() it the same way the game's own client does, then keep the
    entries that have an `Egg` sub-table. No eggs need to be spawned for this to work.
]]

local RS = game:GetService("ReplicatedStorage")
local out = {}
local function P(...)
    local parts = {}
    for _, v in ipairs({ ... }) do parts[#parts + 1] = tostring(v) end
    local line = table.concat(parts, " ")
    out[#out + 1] = line
    print(line)
end

local function getPath(path)
    local node = RS
    for seg in path:gmatch("[^%.]+") do node = node and node:FindFirstChild(seg) end
    return node
end

local function load(path)
    local node = getPath(path)
    if node and node:IsA("ModuleScript") then
        local ok, mod = pcall(require, node)
        if ok and type(mod) == "table" then return mod, path end
    end
end

-- 1) locate the assets table
local Assets, source
for _, p in ipairs({ "Data.Assets", "Directory.Assets" }) do
    local mod, path = load(p)
    if mod then
        Assets = type(mod.Directory) == "table" and mod.Directory or mod
        source = path
        break
    end
end

-- 2) fallback: search Data/Directory for any module whose entries have an Egg sub-table
if not Assets then
    for _, folderName in ipairs({ "Data", "Directory" }) do
        local folder = RS:FindFirstChild(folderName)
        if folder then
            for _, m in ipairs(folder:GetDescendants()) do
                if m:IsA("ModuleScript") then
                    local ok, mod = pcall(require, m)
                    if ok and type(mod) == "table" then
                        local dir = type(mod.Directory) == "table" and mod.Directory or mod
                        for _, v in pairs(dir) do
                            if type(v) == "table" and type(v.Egg) == "table" then
                                Assets, source = dir, m:GetFullName()
                                break
                            end
                        end
                    end
                end
                if Assets then break end
            end
        end
        if Assets then break end
    end
end

P("==================== EGG DISCOVER ====================")
if not Assets then
    P("Could not find the assets table. Modules inside ReplicatedStorage.Data / .Directory:")
    for _, folderName in ipairs({ "Data", "Directory" }) do
        local folder = RS:FindFirstChild(folderName)
        if folder then
            for _, m in ipairs(folder:GetDescendants()) do
                if m:IsA("ModuleScript") then P("  ", m:GetFullName()) end
            end
        end
    end
    P("Send that list to whoever is helping you adapt the script.")
else
    P("Source: ReplicatedStorage." .. tostring(source))

    local NAME_KEYS   = { "DisplayName", "Name", "_id" }
    local RARITY_KEYS = { "Rarity", "RarityName", "Tier", "Grade" }
    local function first(t, keys)
        for _, k in ipairs(keys) do if t[k] ~= nil then return t[k], k end end
    end

    local rows, rarities, fieldSample = {}, {}, nil
    for id, def in pairs(Assets) do
        if type(def) == "table" and type(def.Egg) == "table" then
            local name = first(def, NAME_KEYS)
            local rar, rarKey = first(def, RARITY_KEYS)
            if type(rar) == "table" then rar = rar.Name or rar.name or rar.DisplayName end
            rows[#rows + 1] = {
                id = tostring(id), name = tostring(name or id), rarity = tostring(rar or "?"),
                rate = tonumber(def.EarningRate) or 0, weight = def.Egg.WeightKg, grow = def.Egg.GrowthTime,
            }
            rarities[tostring(rar or "?")] = (rarities[tostring(rar or "?")] or 0) + 1
            fieldSample = fieldSample or { id = id, def = def, rarKey = rarKey }
        end
    end
    table.sort(rows, function(a, b) return a.rate < b.rate end)

    P(("Found %d egg definitions:"):format(#rows))
    P("")
    P("ID | NAME | RARITY | EarningRate | WeightKg | GrowthTime")
    for _, r in ipairs(rows) do
        P(("%s | %s | %s | %s | %s | %s"):format(r.id, r.name, r.rarity, r.rate, tostring(r.weight), tostring(r.grow)))
    end

    P("")
    P("RARITIES (count of eggs):")
    local rl = {}
    for k, n in pairs(rarities) do rl[#rl + 1] = k .. " x" .. n end
    table.sort(rl)
    for _, s in ipairs(rl) do P("  " .. s) end

    if fieldSample then
        P("")
        P("FIELDS on one egg definition (" .. tostring(fieldSample.id) .. "):")
        for k, v in pairs(fieldSample.def) do
            P("  ", k, "=", typeof(v) == "table" and "<table>" or tostring(v))
        end
        P("  rarity field detected as:", tostring(fieldSample.rarKey))
        if type(fieldSample.def.Egg) == "table" then
            P("FIELDS inside .Egg:")
            for k, v in pairs(fieldSample.def.Egg) do P("  ", k, "=", typeof(v) == "table" and "<table>" or tostring(v)) end
        end
    end
end

-- 3) what's actually spawned right now (confirms the snapshot record format)
P("")
P("LIVE SNAPSHOT CHECK:")
do
    local pkg = RS:FindFirstChild("Packages")
    local root = (pkg and pkg:FindFirstChild("Networking")) or RS:FindFirstChild("Network")
    local remote = root and (root:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot") or root:FindFirstChild("Eggs: RequestAreaEggSnapshot"))
    if not remote then
        P("  snapshot remote not found")
    else
        local ok, snap = pcall(function() return remote:InvokeServer() end)
        if not ok or type(snap) ~= "table" then
            P("  snapshot call failed:", tostring(snap))
        else
            local function walk(t, depth)
                if type(t) ~= "table" or depth > 5 then return nil end
                if (t.Uid or t.UID or t.Id) and (t.AssetCategory or t.Category or t.Asset) then return t end
                for _, v in pairs(t) do
                    local r = walk(v, depth + 1)
                    if r then return r end
                end
            end
            local rec = walk(snap, 0)
            if rec then
                P("  first spawned egg record:")
                for k, v in pairs(rec) do P("    ", k, "=", typeof(v) == "table" and "<table>" or tostring(v)) end
            else
                P("  no egg-like record found; top-level keys:")
                for k, v in pairs(snap) do P("    ", k, typeof(v)) end
            end
        end
    end
end

-- save / copy
local text = table.concat(out, "\n")
if type(writefile) == "function" then
    pcall(writefile, "EggDump.txt", text)
    print("[EggDiscover] saved EggDump.txt")
end
if type(setclipboard) == "function" then
    pcall(setclipboard, text)
    print("[EggDiscover] copied to clipboard")
end
