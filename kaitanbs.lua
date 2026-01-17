repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
task.wait(3)

local SplashModule = require(game.ReplicatedStorage.Modules.Game.SplashScreen)
if SplashModule.in_loading_screen.get() then
    workspace:SetAttribute("SkipCreator", true)  -- <- แก้ Workspace -> workspace
    set_thread_identity(2)
    SplashModule.in_loading_screen.set(false)
    set_thread_identity(8)

    local splashGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SplashScreenGui")
    if splashGui then splashGui:Destroy() end

    local SoundService = game:GetService("SoundService")
    for _, s in ipairs(SoundService:GetChildren()) do
        if s:IsA("Sound") and s.SoundId == "rbxassetid://113169105768074" then
            local tween = game:GetService("TweenService"):Create(s, TweenInfo.new(1), { Volume = 0 })
            tween:Play()
            tween.Completed:Wait()
            s:Stop()
        end
    end
    task.wait(3)
end

local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local plr = game.Players.LocalPlayer
local Char = plr.Character or plr.CharacterAdded:Wait()
local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Request = (syn and syn.request) or request or (http and http.request) or http_request
local PlaceID = game.PlaceId

local runningTasks = {
    key2 = false,
    getmany = false,
    downhole = false,
    postmany = false,
    getmanyall = false,
}

local NetCore = require(ReplicatedStorage.Modules.Core.Net)
local Authenticate = debug.getupvalue(NetCore.get, 1)
local function Get(...)
    Authenticate.func += 1
    return game:GetService("ReplicatedStorage").Remotes.Get:InvokeServer(Authenticate.func, ...)
end

local Send = function(...)
	Authenticate.event += 1;
	game:GetService("ReplicatedStorage").Remotes.Send:FireServer(Authenticate.event, ...)
end

local function getTotalMoney()
    local hand = DataCore.money.hand or 0
    local bank = DataCore.money.bank or 0
    return hand + bank
end
local money_hand = DataCore.money.hand or 0
local money_bank = DataCore.money.bank or 0
local money = money_hand + money_bank or 0

local POS = {
    ATMCheck = Vector3.new(109.73040771484375, 255.2530059814453, 464.5361328125),
    OUTDOOR = Vector3.new(120.16957092285156, 255.1735076904297, 466.8861083984375),
    INDOOR = Vector3.new(133.01979064941406, 255.4764862060547, 489.3217468261719),
    ATMCheck = Vector3.new(109.73040771484375, 255.2530059814453, 464.5361328125),
    ATMSpot = Vector3.new(113.7680892944336, 255.1897430419922, 463.8665771484375),
}

local function getOwnedCars()
    local result = {}
    if not (DataCore.items and DataCore.items.car) then
        return result
    end
    for carName, carData in pairs(DataCore.items.car) do
        if type(carData) == "table" and next(carData) ~= nil then
            table.insert(result, carName)
        end
    end
    return result
end


local function getJobIdFromAPI()
    local API_URL = "http://110.164.203.137:2699/getjobid"
    if PlaceID ~= 104715542330896 then
        return nil
    end
    
    local ok, res = pcall(function()
        return Request({
            Url = API_URL,
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json"
            }
        })
    end)
    if not ok or not res then
        warn("Request failed")
        return nil
    end
    if tonumber(res.StatusCode) ~= 200 then
        warn("API error:", res.StatusCode, res.Body)
        return nil
    end
    local data
    local decodeOk, decodeErr = pcall(function()
        data = HttpService:JSONDecode(res.Body)
    end)
    if not decodeOk then
        warn("JSON decode failed:", decodeErr)
        return nil
    end
    if data.status ~= "ok" or not data.jobid then
        warn("Invalid API response:", res.Body)
        return nil
    end
    return data.jobid
end

task.spawn(function() 
	task.wait(6)
    local BASE = "http://110.164.203.137:2699/check-duplicate-jobid/"
    while true do
        local username = plr.Name
        local url = BASE .. HttpService:UrlEncode(username) .. "?threshold=3"

        local ok, res = pcall(function()
            return Request({
                Url = url,
                Method = "GET",
                Headers = { ["Accept"] = "application/json" }
            })
        end)
        if ok and res and tonumber(res.StatusCode) == 200 then
            local body = res.Body or "{}"
            local data = {}
            pcall(function()
                data = HttpService:JSONDecode(body)
            end)

            print(("check_duplicate_jobid OK | %s | count=%s | need_new=%s"):format(
                username,
                tostring(data.count),
                tostring(data.need_new_jobid)
            ))
            if data.need_new_jobid and data.new_jobid then
                print("NEW JOBID:", data.new_jobid)
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, data.new_jobid, game.Players.LocalPlayer)
            end
        else
            local code = (res and res.StatusCode) and tostring(res.StatusCode) or "NO_STATUS"
            local msg  = (res and res.Body) and tostring(res.Body) or "REQUEST_FAILED"
            warn(("Failed check_duplicate_jobid | %s | %s"):format(code, msg))
        end
        task.wait(10)
    end
end)

task.spawn(function() lookfps(fps)
    while true do 
        setfpscap(fps)
        task.wait(5)
    end
end)

task.spawn(function()
    getgenv().HermanosDevSetting = {
        Farming = {
            Job = "Swiper", -- Shelf Stocker, Cook, Janitor, Swiper, Fishing, Farming

            -- Cook
            Skillet = "Smart Select",
            BuySkillet = false,

            -- Janitor
            PaddleMode = "Nearest", -- Smart, Nearest
            Mop = "Smart Select",
            BuyMop = false,

            -- ATM Hacking
            HackTools = "Smart Select",
            HackToolsQuantity = 5,
            
            -- Fishing
            Rod = "Smart Select",
            Bait = "Smart Select",
            BaitQuantity = 10,
            FishAmount = 10,
            AutoSellFish = false,
            
            -- Farming
            IncludeFarming = true,

            -- Vehicle
            VehicleType = "Car", -- Bike, Car
            VehicleSpeed = 52,

            -- Auto Farm
            AutoFarm = true,
            AfkChecker = true,

            -- Deposit
            CashDeposit = 200,
            AutoDeposit = true
        },

        General = {
            HideName = true,
            AntiRagdoll = true,
            AntiKill = true,
            AutoRespawn = true,
        },
    }
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/28d9e130cb0559d30e2c20b5c851b7ef.lua"))()
end)

task.wait(10)
task.spawn(function()
    print("Start")
    local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)
    local lastMoney = DataCore.money.hand
    local lastChangeTime = os.time()
    local kickThreshold = 5 * 60
    while true do
        task.wait(1)
        local currentMoney = DataCore.money.hand
        if currentMoney ~= lastMoney then
            lastMoney = currentMoney
            lastChangeTime = os.time()
        else
            if os.time() - lastChangeTime >= kickThreshold then
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer or Players:GetPlayerFromCharacter(script.Parent)
                if player then
                    local jobid = getJobIdFromAPI()
                    if jobid then
                        print("NEW JOBID:", jobid)
                        local TeleportService = game:GetService("TeleportService")
                        TeleportService:TeleportToPlaceInstance(PlaceID, jobid, game.Players.LocalPlayer)
                    else
                        warn("No jobid received")
                        game:Shutdown()
                    end
                end
                break
            end
        end
    end
end)

task.spawn(function()
    local API_URL = "http://110.164.203.137:2699/player"
    while true do
        local bank = 0
        local hand = 0
        if DataCore and DataCore.money then
            bank = tonumber(DataCore.money.bank) or 0
            hand = tonumber(DataCore.money.hand) or 0
        end

        local payload = {
            username  = plr.Name,
            moneybank = bank,
            moneyhand = hand,
            car       = getOwnedCars(),
            jobid     = tostring(game.JobId),
            placeid   = tostring(game.PlaceId),
            time      = os.time()
        }
        local body = HttpService:JSONEncode(payload)
        local ok, res = pcall(function()
            return Request({
                Url = API_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)
        if ok and res and tonumber(res.StatusCode) == 200 then
            print("Status Updated API:", payload.username)
        else
            local code = (res and res.StatusCode) and tostring(res.StatusCode) or "NO_STATUS"
            local msg  = (res and res.Body) and tostring(res.Body) or "REQUEST_FAILED"
            warn(("Failed Update API | %s | %s"):format(code, msg))
        end
        task.wait(10)
    end
end)

task.spawn(function()
    local LIMIT_SECONDS = 90 * 60
    task.delay(LIMIT_SECONDS, function()
        if localPlayer and localPlayer.Parent then
            local jobid = getJobIdFromAPI()
            if jobid then
                print("NEW JOBID:", jobid)
                local TeleportService = game:GetService("TeleportService")
                TeleportService:TeleportToPlaceInstance(PlaceID, jobid, game.Players.LocalPlayer)
            else
                warn("No jobid received")
                game:Shutdown()
            end
        end
    end)
end)
