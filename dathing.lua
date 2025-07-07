-- Whitelister3000 - Simple HWID Whitelisting System
local Whitelister3000 = { _version = "1.0" }

-- Configuration (set these before using)
Whitelister3000.HWIDLinks = ""          -- Raw GitHub URL with encrypted HWIDs (one per line)
Whitelister3000.SuccessMessage = "Whitelist check passed!"
Whitelister3000.ErrorMessage = "Not whitelisted!"
Whitelister3000.Mapping = {}            -- {["A"] = "😀", ["B"] = "😎"} etc.

local cachedHWIDs = nil

-- Simple emoji decoder
local function decodeHWID(encoded, mapping)
    local decoded = ""
    local i = 1
    while i <= #encoded do
        local found = false
        for char, emoji in pairs(mapping) do
            if encoded:sub(i, i + #emoji - 1) == emoji then
                decoded = decoded .. char
                i = i + #emoji
                found = true
                break
            end
        end
        if not found then i = i + 1 end -- Skip invalid chars
    end
    return decoded
end

-- Get HWIDs from GitHub (uses request/httpget)
local function fetchHWIDs()
    if cachedHWIDs then return cachedHWIDs end
    if Whitelister3000.HWIDLinks == "" then return {} end

    local success, response = pcall(function()
        return (request or httpget or http.get)(Whitelister3000.HWIDLinks)
    end)

    if not success or not response or response.StatusCode ~= 200 then
        print("[Whitelister3000] Failed to fetch HWIDs")
        return {}
    end

    local hwids = {}
    for line in response.Body:gmatch("[^\r\n]+") do
        local decoded = decodeHWID(line, Whitelister3000.Mapping)
        if decoded ~= "" then table.insert(hwids, decoded) end
    end

    cachedHWIDs = hwids
    return hwids
end

-- Check if player is whitelisted
function Whitelister3000.Check(player)
    player = player or game:GetService("Players").LocalPlayer
    if not player then return false end

    local hwid
    local success, err = pcall(function()
        gethwid()
    end)

    if not success or not hwid then
        print("[Whitelister3000] Failed to get HWID:", err)
        return false
    end

    for _, whitelisted in ipairs(fetchHWIDs()) do
        if whitelisted == hwid then return true end
    end

    return false
end

-- Show notification
function Whitelister3000.Notify(player)
    if Whitelister3000.Check(player) then
        print(Whitelister3000.SuccessMessage)
        -- Example notification (replace with your system):
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Whitelist",
            Text = Whitelister3000.SuccessMessage,
            Duration = 5
        })
        return true
    else
        warn(Whitelister3000.ErrorMessage)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Whitelist",
            Text = Whitelister3000.ErrorMessage,
            Duration = 5
        })
        return false
    end
end

-- Auto-check players (optional)
game:GetService("Players").PlayerAdded:Connect(Whitelister3000.Notify)
for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    Whitelister3000.Notify(player)
end

return Whitelister3000
