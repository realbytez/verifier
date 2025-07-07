-- Whitelister3000 Library
local Whitelister3000 = {}
local HttpService = game:GetService("HttpService")

-- Default configuration
Whitelister3000.HWIDLinks = ""
Whitelister3000.SuccessMessage = "Success! You are whitelisted."
Whitelister3000.ErrorMessage = "Error: You are not whitelisted."
Whitelister3000.Mapping = "{}" -- Empty JSON object by default

-- Cache for decoded HWIDs
local cachedHWIDs = nil

local function decodeEmojis(encodedText, mappingJson)
    -- Parse the JSON mapping
    local success, mapping = pcall(function()
        return HttpService:JSONDecode(mappingJson)
    end)
    
    if not success then
        warn("[Whitelister3000] Error parsing mapping JSON:", mapping)
        return nil
    end
    
    -- Create reverse mapping (emoji to character)
    local reverseMapping = {}
    for char, emoji in pairs(mapping) do
        reverseMapping[emoji] = char
    end
    
    -- Split into lines and process each line
    local lines = {}
    for line in encodedText:gmatch("([^\n]*)\n?") do
        if line:gsub("%s", "") ~= "" then -- Skip empty lines
            table.insert(lines, line)
        end
    end
    
    local decodedResult = {}
    
    for _, line in ipairs(lines) do
        local decodedLine = ""
        local currentEmoji = ""
        
        for i = 1, #line do
            local char = line:sub(i, i)
            currentEmoji = currentEmoji .. char
            
            -- Check if we have a mapping for the current emoji
            if reverseMapping[currentEmoji] then
                decodedLine = decodedLine .. reverseMapping[currentEmoji]
                currentEmoji = ""
            elseif #currentEmoji > 4 then
                -- Skip unknown emojis
                currentEmoji = ""
            end
        end
        
        if decodedLine ~= "" then
            table.insert(decodedResult, decodedLine)
        end
    end
    
    return decodedResult
end

local function getDecodedHWIDs()
    if cachedHWIDs then
        return cachedHWIDs
    end
    
    if Whitelister3000.HWIDLinks == "" then
        warn("[Whitelister3000] No HWIDLinks configured")
        return {}
    end
    
    local success, encodedHWIDs = pcall(function()
        return HttpService:GetAsync(Whitelister3000.HWIDLinks)
    end)
    
    if not success then
        warn("[Whitelister3000] Failed to fetch HWIDs:", encodedHWIDs)
        return {}
    end
    
    local decoded = decodeEmojis(encodedHWIDs, Whitelister3000.Mapping)
    if decoded then
        cachedHWIDs = decoded
        return decoded
    end
    
    return {}
end

function Whitelister3000.CheckPlayer(player)
    if not player then
        player = game:GetService("Players").LocalPlayer
        if not player then
            warn("[Whitelister3000] No player available")
            return false
        end
    end
    
    local hwid
    local success, err = pcall(function()
        hwid = gethwid() or game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    
    if not success then
        warn("[Whitelister3000] Failed to get HWID:", err)
        return false
    end
    
    local whitelistedHWIDs = getDecodedHWIDs()
    for _, whitelistedHWID in ipairs(whitelistedHWIDs) do
        if whitelistedHWID == hwid then
            return true
        end
    end
    
    return false
end

function Whitelister3000.NotifyPlayer(player)
    local isWhitelisted = Whitelister3000.CheckPlayer(player)
    
    if isWhitelisted then
        print(Whitelister3000.SuccessMessage)
        -- You can replace this with your notification system
        if player then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Whitelist",
                Text = Whitelister3000.SuccessMessage,
                Duration = 5
            })
        end
        return true
    else
        warn(Whitelister3000.ErrorMessage)
        -- You can replace this with your notification system
        if player then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Whitelist",
                Text = Whitelister3000.ErrorMessage,
                Duration = 5
            })
        end
        return false
    end
end

-- Automatic check when a player joins (optional)
game:GetService("Players").PlayerAdded:Connect(function(player)
    Whitelister3000.NotifyPlayer(player)
end)

-- Check existing players (optional)
for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    Whitelister3000.NotifyPlayer(player)
end

return Whitelister3000
