repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
task.wait(3)

local SplashModule = require(game.ReplicatedStorage.Modules.Game.SplashScreen)
local isFirstRun = SplashModule.in_loading_screen.get()
if isFirstRun then
    workspace:SetAttribute("SkipCreator", true)
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


local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local plr = game.Players.LocalPlayer
local Char = plr.Character or plr.CharacterAdded:Wait()
local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Request = (syn and syn.request) or request or (http and http.request) or http_request
local PlaceID = game.PlaceId
local JobId = game.JobId
local TweenService = game:GetService("TweenService")

local IP_Server = "https://nextplaymanager.nextplay.club"
local WMA_KEY   = "wma_Kx9mP2nQ8rT4vW6j"

getgenv().neebJobs = {"Shelf Stocker", "Cook", "Swiper"}
getgenv().curjob = ""

local FolderName = "NextPlayBS"
local FileName = FolderName .. "/NPframbs_" .. Player.Name .. ".json"

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

local function CheckHackTool()
    local items = DataCore.items and DataCore.items.misc
    if not items then
        return false
    end
    local targetTools = {
        ["HackToolBasic"] = true,
        ["HackToolPro"] = true,
        ["HackToolUltimate"] = true,
        ["HackToolQuantum"] = true
    }
    for toolName, toolList in pairs(items) do
        if targetTools[toolName] then
            for _, itemData in pairs(toolList) do
                if itemData.guid and itemData.guid ~= "" then
                    return true
                end
            end
        end
    end
    return false
end

local function loadPool()
    if isfile(FileName) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(FileName))
        end)
        if ok and type(data) == "table" then
            return data
        end
    end
    return {}
end

local function savePool(pool)
    writefile(FileName, HttpService:JSONEncode(pool))
end

local function randomjob()
    if not isfolder(FolderName) then
        makefolder(FolderName)
    end
    if not isfile(FileName) then
        savePool(getgenv().neebJobs)
    end
    local pool = loadPool()
    if #pool == 0 then
        pool = {unpack(getgenv().neebJobs)}
    end
    local job = table.remove(pool, math.random(1, #pool))
    savePool(pool)
    getgenv().curjob = job
    return job
end

local function getJobIdFromAPI()
    if PlaceID ~= 104715542330896 then
        return nil
    end
    local ok, res = pcall(function()
        return Request({
            Url = IP_Server .. "/api/v1/blockspin/getjobid",
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json",
                ["x-api-key"] = WMA_KEY
            }
        })
    end)
    if not ok or not res then
        warn("Request failed")
        return nil
    end
    if tonumber(res.StatusCode) ~= 200 then
        warn("API error:", res.StatusCode, res.Body)  -- 503 = no jobid available
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
	task.wait(40)
    if PlaceID ~= 104715542330896 then
        return nil
    end

    while true do
        local username = plr.Name
        local url = IP_Server .. "/api/v1/blockspin/check-duplicate-jobid?username="
                    .. HttpService:UrlEncode(username) .. "&threshold=3"

        local ok, res = pcall(function()
            return Request({
                Url = url,
                Method = "GET",
                Headers = { ["Accept"] = "application/json", ["x-api-key"] = WMA_KEY }
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

getgenv().HermanosDevSetting = {
    Farming = {
        Job = randomjob(), -- Shelf Stocker, Cook, Janitor, Swiper, Fishing, Farming

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

        -- Farming
        IncludeFarming = true,

        -- Vehicle
        VehicleType = "Bike", -- Bike, Car
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
task.spawn(function()
    local firstrun = true
    while true do
        if game.PlaceId ~= 104715542330896 then
            task.wait(400)
            TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
        end

        if getgenv().curjob == "Swiper" then

            pcall(function()
                getgenv().HermanosFarm.Farming.IncludeFarming = true
            end)
            if firstrun == false then
                Send("request_respawn")
                task.wait(2)
            end

            local xp_swiper = DataCore.xp["atm_hacker"]
            local level_swiper = xp_swiper and xp_to_level(xp_swiper) or 0
            local hackToolCount = 2

            if level_swiper < 45 then
                hackToolCount = 2
            else
                hackToolCount = 5
                pcall(function()
                    getgenv().HermanosFarm.Farming.VehicleType = "Car"
                end)
            end
            pcall(function()
                getgenv().HermanosFarm.Farming.HackToolsQuantity = hackToolCount
            end)

            task.wait(waitTime)
            while CheckHackTool() do
                task.wait(2)
            end
        end
        local waitTime = math.random(360, 720)
        task.wait(waitTime)
        local jobnow = randomjob()
        pcall(function()
            getgenv().HermanosFarm.Farming.Job = jobnow
        end)
        firstrun = false
    end
end)

loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/28d9e130cb0559d30e2c20b5c851b7ef.lua"))()
