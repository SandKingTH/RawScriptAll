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

local Jobs = {"Shelf Stocker", "Cook", "Janitor", "Fishing"}
local AvailableJobs = {unpack(Jobs)}
local StorageFram = {}

if not isfolder(FolderName) then
    makefolder(FolderName)
end

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

local CONST1 = 1.1040895136738123
local CONST2 = 0.10408951367381225

local function level_to_xp(level)
	local expTerm = 2 ^ (level / 7)
	local xp = 0.125 * (level ^ 2 - level + 600 * ((expTerm - CONST1) / CONST2))
	return math.floor(xp + 0.5)
end

local function xp_to_level(targetXP)
	local low, high = 0, 100
	while low <= high do
		local mid = math.floor((low + high) / 2)
		local midXP = level_to_xp(mid)
		if midXP <= targetXP then
			low = mid + 1
		else
			high = mid - 1
		end
	end
	return high
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

local function getFishCount()
    local fishItems = DataCore.items.fish
    local totalCount = 0
    for _, category in pairs(fishItems) do
        for _ in pairs(category) do
            totalCount = totalCount + 1
        end
    end
    return totalCount
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


LoadProgress()

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
            IncludeFarming = true,
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
    setfpscap(10)
    getgenv().Hermanos_Settings = {
        ['key'] = 'bafd2512-771b-4091-b5fe-069e746eaf1f',
        ['PC'] = NAMEPC,


        ['Guns'] = {"G3","P226","AK47"},
        ['HackTools'] = {"HackToolBasic","HackToolPro","HackToolUltimate","HackToolQuantum"}

    }
    task.spawn(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/hermanos-dev/hermanos-script/main/bs-main.lua'))() end)
end)

task.spawn(function()
    task.wait(20) 
    if game.PlaceId ~= 104715542330896 then
        getgenv().HermanosFarm.Farming.Job = "Fishing"
        task.wait(400)
        local jobid = getJobIdFromAPI()
        if jobid then
            print("NEW JOBID:", jobid)
            local TeleportService = game:GetService("TeleportService")
            TeleportService:TeleportToPlaceInstance(104715542330896, jobid, game.Players.LocalPlayer)
        else
            warn("No jobid received")
            game:Shutdown()
        end
        return
    end
    local xp_fishing = DataCore.xp["fishing"]
    local level_fishing = xp_fishing and xp_to_level(xp_fishing) or 0

    while true do
        if #AvailableJobs == 0 then
            table.clear(StorageFram) 
            AvailableJobs = {unpack(Jobs)}
            SaveProgress()
            print("--- [Cycle Reset] JSON Cleared & Restarted ---")
        end
        local randomIndex = math.random(1, #AvailableJobs)
        local selectedJob = table.remove(AvailableJobs, randomIndex)
        table.insert(StorageFram, selectedJob)
        SaveProgress()
        pcall(function()
            getgenv().HermanosFarm.Farming.IncludeFarming = true
        end)
        if selectedJob == "Fishing" then
            pcall(function()
                getgenv().HermanosFarm.Farming.IncludeFarming = false
            end)

            Send("request_respawn")
            task.wait(2)
            pcall(function()
                getgenv().HermanosFarm.Farming.Job = selectedJob
            end)
            print("Job changed to: " .. selectedJob .. " | Saved to JSON")
            task.wait(600)
            while getFishCount() > 0 do
                task.wait(2)
            end
        elseif level_fishing > 40 then
            pcall(function()
                getgenv().HermanosFarm.Farming.Job = "Fishing"
                getgenv().HermanosFarm.Farming.VehicleType = "Car"
            end)
            print("Job changed to: Fishing (Level > 40) | Saved to JSON")
            return
        else
            pcall(function()
                getgenv().HermanosFarm.Farming.Job = selectedJob
            end)
            print("Job changed to: " .. selectedJob .. " | Saved to JSON")
            task.wait(300)
        end
    end
end)
