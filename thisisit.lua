-- Whitelister3000 - RAW VERSION
local Whitelister3000 = {}

-- CONFIG (CHANGE THESE)
Whitelister3000.HWIDLinks = "" -- RAW TXT FILE WITH 1 HWID PER LINE
Whitelister3000.SuccessMessage = "WHITELIST PASSED"
Whitelister3000.ErrorMessage = "NOT WHITELISTED"
Whitelister3000.Mapping = { -- EMOJI TO CHAR MAPPING

}

local cached = nil

-- DECODE EMOJI SHIT
local function decode(str)
    local output = ""
    for i = 1, #str do
        for char, emoji in pairs(Whitelister3000.Mapping) do
            if str:sub(i, i+#emoji-1) == emoji then
                output = output .. char
                break
            end
        end
    end
    return output
end

-- GET WHITELISTED HWIDS
local function get_list()
    if cached then return cached end
    local res = (request or httpget or http.get)(Whitelister3000.HWIDLinks)
    if not res or res.StatusCode ~= 200 then return {} end
    local hwids = {}
    for line in res.Body:gmatch("[^\r\n]+") do
        table.insert(hwids, decode(line))
    end
    cached = hwids
    return hwids
end

-- CHECK IF PLAYER IS WHITELISTED
function Whitelister3000.Check()
    local hwid = gethwid() -- YOUR FUNCTION HERE
    if not hwid then return false end
    for _, v in ipairs(get_list()) do
        if v == hwid then return true end
    end
    return false
end

-- SHOW NOTIFICATION
function Whitelister3000.Notify()
    if Whitelister3000.Check() then
        print(Whitelister3000.SuccessMessage)
        game.StarterGui:SetCore("SendNotification", {
            Title = "WHITELIST",
            Text = Whitelister3000.SuccessMessage,
            Duration = 5
        })
    else
        warn(Whitelister3000.ErrorMessage)
        game.StarterGui:SetCore("SendNotification", {
            Title = "WHITELIST",
            Text = Whitelister3000.ErrorMessage,
            Duration = 5
        })
    end
end

-- AUTO CHECK ON JOIN
game.Players.PlayerAdded:Connect(function(plr)
    if plr == game.Players.LocalPlayer then
        Whitelister3000.Notify()
    end
end)

-- INIT CHECK
if game:IsLoaded() and game.Players.LocalPlayer then
    Whitelister3000.Notify()
end

return Whitelister3000
