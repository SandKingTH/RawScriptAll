loadstring(game:HttpGet("https://raw.githubusercontent.com/SandKingTH/RawScriptAll/refs/heads/main/logbs.lua"))()

local IP_Server = "https://nextplaymanager.nextplay.club"

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
task.wait(3)

local HttpService = game:GetService("HttpService")
local localPlayer = game:GetService("Players").LocalPlayer
local DataCore    = require(game:GetService("ReplicatedStorage").Modules.Core.Data)
local Request     = (syn and syn.request) or (http and http.request) or http_request or request
if not Request then warn("❌ HTTP Request function not found") end

local CONST1 = 1.1040895136738123
local CONST2 = 0.10408951367381225

local function level_to_xp(level)
    local expTerm = 2 ^ (level / 7)
    return math.floor(0.125 * (level ^ 2 - level + 600 * ((expTerm - CONST1) / CONST2)) + 0.5)
end

local function xp_to_level(targetXP)
    if not targetXP then return 0 end
    local low, high = 0, 100
    while low <= high do
        local mid = math.floor((low + high) / 2)
        if level_to_xp(mid) <= targetXP then
            low = mid + 1
        else
            high = mid - 1
        end
    end
    return high
end

local function getitems()
    local counts = {}
    local items = DataCore.items
    if not items then return "" end
    local skip = { car = true, bike = true }
    for categoryName, category in pairs(items) do
        if skip[categoryName] then continue end
        for itemName, container in pairs(category) do
            for _, item in pairs(container) do
                if item.guid and item.guid ~= "" then
                    counts[itemName] = (counts[itemName] or 0) + (item.amount or 1)
                end
            end
        end
    end
    local result = {}
    for itemName, total in pairs(counts) do
        table.insert(result, itemName .. ":" .. total)
    end
    return table.concat(result, ", ")
end

local function getVehicle()
    local result = {}
    local categories = { DataCore.items and DataCore.items.car, DataCore.items and DataCore.items.bike }
    for _, category in ipairs(categories) do
        if type(category) ~= "table" then continue end
        for name, data in pairs(category) do
            if type(data) == "table" and next(data) ~= nil then
                table.insert(result, name)
            end
        end
    end
    return table.concat(result, ", ")
end

local function updateStatusWebLog()
    local ok, response = pcall(function()
        return Request({
            Url     = IP_Server .. "/api/v1/blockspin/log",
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json", ["x-api-key"] = "wma_Kx9mP2nQ8rT4vW6j" },
            Body    = HttpService:JSONEncode({
                device                  = getgenv.NameDevice,
                username                = localPlayer.Name,
                jobid                   = tostring(game.JobId),
                ["Total Level"]         = xp_to_level(DataCore.xp["total_level"]),
                ["Stamina Level"]       = xp_to_level(DataCore.xp["stamina"]),
                ["Shelf Stocker Level"] = xp_to_level(DataCore.xp["shelf_stocker"]),
                ["Swiper Level"]        = xp_to_level(DataCore.xp["atm_hacker"]),
                ["Janitor Level"]       = xp_to_level(DataCore.xp["janitor"]),
                ["Cook Level"]          = xp_to_level(DataCore.xp["cook"]),
                ["Fishing Level"]       = xp_to_level(DataCore.xp["fishing"]),
                ["Farming Level"]       = xp_to_level(DataCore.xp["farmer"]),
                Cash                    = DataCore.money.hand or 0,
                Bank                    = DataCore.money.bank or 0,
                Vehicle                 = getVehicle(),
                iteminventory           = getitems(),
            }),
        })
    end)
    if ok and response.StatusCode == 200 then
        print("Log Updated : " .. localPlayer.Name)
    else
        warn("Failed Log API " .. (response and response.StatusCode or tostring(response)))
    end
end

local globalFunc = false

game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
    if v.Name ~= "ErrorPrompt" then return end
    pcall(function()
        repeat task.wait(0.5) until game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame:FindFirstChild("ErrorMessage")
        local errorMessage = game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text
        local errorCode = tonumber(errorMessage:split("\n")[2]:match("%d+"))
        if errorCode ~= 772 and errorCode ~= 773 then
            globalFunc = true
        end
    end)
end)

game.StarterGui:SetCore("SendNotification", {
    Title    = "NEXTPLAY SERVICES",
    Text     = "User : " .. localPlayer.Name,
    Duration = 25,
    Icon     = "rbxassetid://123023221387595",
})

local Round = 0
while true do
    print("Disconnected : ", globalFunc)
    print("API runs at : ", Round)
    if not globalFunc then
        updateStatusWebLog()
    end
    Round = Round + 1
    print("----------------------------------------")
    task.wait(15)
end
