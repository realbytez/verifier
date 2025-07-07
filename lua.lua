-- Whitelister3000 Simple Version
local Whitelister3000 = {}
Whitelister3000.__index = Whitelister3000

-- Default settings
Whitelister3000.HWIDLinks = ""
Whitelister3000.SuccessMessage = "Success! You are whitelisted."
Whitelister3000.ErrorMessage = "Error: You are not whitelisted."
Whitelister3000.Mapping = [[
{

}
]]

-- Internal emoji decoder
function Whitelister3000._decode(text, mapping)
    local reverse = {}
    for k,v in pairs(game:GetService("HttpService"):JSONDecode(mapping)) do
        reverse[v] = k
    end
    
    local result = ""
    local buffer = ""
    
    for i = 1, #text do
        buffer = buffer .. text:sub(i,i)
        if reverse[buffer] then
            result = result .. reverse[buffer]
            buffer = ""
        elseif #buffer > 4 then
            buffer = ""
            result = result .. "?"
        end
    end
    
    return result
end

-- Main whitelist check
function Whitelister3000.Check()
    if Whitelister3000.HWIDLinks == "" then
        error("HWIDLinks not set")
    end

    -- Get current HWID
    local hwid = gethwid())
    if not hwid or hwid == "" then
        error("Failed to get HWID")
    end

    -- Fetch encrypted HWIDs
    local encrypted = game:HttpGet(Whitelister3000.HWIDLinks, true)
    if not encrypted or encrypted == "" then
        error("Failed to fetch HWIDs")
    end

    -- Decode HWIDs
    local decoded = Whitelister3000._decode(encrypted, Whitelister3000.Mapping)
    for line in decoded:gmatch("[^\r\n]+") do
        if line == hwid then
            print(Whitelister3000.SuccessMessage)
            return true
        end
    end

    print(Whitelister3000.ErrorMessage)
    return false
end

return Whitelister3000
