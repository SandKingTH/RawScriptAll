task.spawn(function()
    getgenv().HermanosDevSetting = {
        Farming = {
            Job = "", 
            Skillet = "Smart Select",
            BuySkillet = true,
            PaddleMode = "Nearest",
            Mop = "Smart Select",
            BuyMop = true,
            HackTools = "Smart Select",
            HackToolsQuantity = 5,
            Rod = "Smart Select",
            Bait = "Smart Select",
            BaitQuantity = 10,
            FishAmount = 10,
            IncludeFarming = false,
            VehicleType = "Bike",
            VehicleSpeed = 52,
            AutoFarm = true,
            AfkChecker = true,
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

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
task.wait(3)

local FLOAT_HEIGHT = 4
local SPEED = 34
getgenv().money_random = 0
getgenv().Farmnow = ""

local Player = game.Players.LocalPlayer
local FolderName = "NextPlayFF"
local FileName = FolderName .. "/" .. Player.Name .. "_StorageFram.json"

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
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local Jobs = {"Shelf Stocker", "Cook", "Janitor"}
local AvailableJobs = {unpack(Jobs)}
local StorageFram = {}

if not isfolder(FolderName) then
    makefolder(FolderName)
end


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

local function SaveProgress()
    local Data = {
        Available = AvailableJobs,
        History = StorageFram
    }
    writefile(FileName, HttpService:JSONEncode(Data))
end

local function LoadProgress()
    if isfile(FileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(FileName))
        end)
        if success and result then
            AvailableJobs = result.Available or AvailableJobs
            StorageFram = result.History or StorageFram
            print("--- Loaded existing progress from JSON ---")
        end
    end
end

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

LoadProgress()

task.spawn(function() 
	task.wait(20)
    local BASE = "http://110.164.203.137:2699/check-duplicate-jobid/"
    if PlaceID ~= 104715542330896 then
        return nil
    end

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

task.spawn(function()
    while true do 
        setfpscap(10)
        task.wait(5)
    end
end)

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
    repeat wait() until game:IsLoaded()
    repeat wait() until game.Players.LocalPlayer.Character
    local HttpService = game:GetService("HttpService")
    local Request = (syn and syn.request) or request or (http and http.request) or http_request
    local username = game.Players.LocalPlayer.Name
    local globalFunc = false
    local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)

    game.StarterGui:SetCore("SendNotification", {
        Title = 'API SERVICES',
        Text = 'User : ' .. username,
        Duration = 25,
        Icon = 'rbxassetid://18976336309'
    })

    local function checkForError()
        game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
            if v.Name == "ErrorPrompt" then
                pcall(function()
                    repeat task.wait(0.5) until game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame:FindFirstChild("ErrorMessage")

                    local errorMessage = game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text
                    local errorCode = tonumber(errorMessage:split("\n")[2]:match("%d+"))

                    if errorCode ~= 772 and errorCode ~= 773 then
                        globalFunc = true
                    end
                end)
            end
        end)
        return globalFunc
    end

    local function updateStatus()
        local currentMoney = (DataCore.money and DataCore.money.bank) or 0
        local url  = "http://127.0.0.1:14781"
        local data = "username=" .. HttpService:UrlEncode(username)
                .. "&money=" .. tostring(currentMoney)
        if not Request then
            warn("HTTP request function not available")
            return
        end
        local requestData = {
            Url    = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded"
            },
            Body = data
        }
        local ok, response = pcall(function()
            return Request(requestData)
        end)
        if ok and response.StatusCode == 200 then
            print(("Status Updated API : %s | Money : %s"):format(username, currentMoney))
        else
            warn("Failed Update API " .. (response and response.StatusCode or "Request failed"))
        end
    end

    local Round = 0
    while true do
        globalFunc = checkForError()
        print("Disconnected : ", globalFunc)
        print("API runs at : ", Round)
        if not globalFunc then
            updateStatus()
        end
        Round = Round + 1
        print("----------------------------------------")
        wait(15)
    end
end)

task.spawn(function()
    task.wait(20) 

    if game.PlaceId ~= 104715542330896 then
        getgenv().HermanosFarm.Farming.Job = "Shelf Stocker"
        task.wait(400)
        game:Shutdown()
        return
    end

    while true do
        if #AvailableJobs == 0 then
            table.clear(StorageFram) 
            AvailableJobs = {unpack(Jobs)}
            SaveProgress()
        end

        local randomIndex = math.random(1, #AvailableJobs)
        getgenv().Farmnow = table.remove(AvailableJobs, randomIndex)
        table.insert(StorageFram, getgenv().Farmnow)
        SaveProgress()
        pcall(function()
            getgenv().HermanosFarm.Farming.Job = getgenv().Farmnow
        end)
        task.wait(600)
    end
end)
