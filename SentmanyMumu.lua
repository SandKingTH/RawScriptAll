
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
wait(5)


local plr = game.Players.LocalPlayer
local Char = plr.Character or plr.CharacterAdded:Wait()
local HumanoidRootPart = Char.HumanoidRootPart
local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)

local NetCore = require(game:GetService("ReplicatedStorage").Modules.Core.Net)
local Authenticate = debug.getupvalue(NetCore.get, 1)
local Get = function (...)
	Authenticate.func += 1;
	game:GetService("ReplicatedStorage").Remotes.Get:InvokeServer(Authenticate.func,...)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataCore = require(ReplicatedStorage.Modules.Core.Data)
local localPlayer = Players.LocalPlayer

local function walkToTarget(targetPosition)
	local plr = game.Players.LocalPlayer
	local Char = plr.Character or plr.CharacterAdded:Wait()
	if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then
		warn("Character หรือ Humanoid ยังไม่พร้อม")
		return
	end
	local Humanoid = Char.Humanoid
	local pos = Char.HumanoidRootPart.Position
	local path = game:GetService("PathfindingService"):CreatePath({
		AgentRadius = 2,
		AgentHeight = 3.7,
		AgentCanJump = false,
		AgentCanClimb = false,
		AgentMaxSlope = 45,
	})
	path:ComputeAsync(pos, targetPosition)
	local Humanoidd = Char.Humanoid
	Humanoidd.WalkSpeed = 35

	if path.Status ~= Enum.PathStatus.Success then
		warn("Pathfinding ล้มเหลว: " .. tostring(path.Status))
		return
	end
	local waypoints = path:GetWaypoints()
	for i, v in ipairs(waypoints) do
		local targetPos = v.Position
		local humRoot = Char.HumanoidRootPart
		local distance = (targetPos - humRoot.Position).Magnitude
		Humanoid:MoveTo(targetPos)
		local reached = false
		local event = Humanoid.MoveToFinished:Connect(function(success)
			reached = true
		end)
		repeat
			task.wait()
		until reached
		event:Disconnect()
		if (targetPos - humRoot.Position).Magnitude > 10 then
			warn("ไปไม่ถึงเป้าหมาย waypoint", i)
			break
		end
	end
end

function walkTo(targetPosition)
    print("Going to:", targetPosition)
    local Char = plr.Character
    local Humanoid = Char:WaitForChild("Humanoid")
    local HRP = Char:WaitForChild("HumanoidRootPart")
    Humanoid.WalkSpeed = 30
    Humanoid:MoveTo(targetPosition)

    -- รอ MoveTo เสร็จ หรือตรวจระยะเอง
    local connection
    local finished = false
    connection = Humanoid.MoveToFinished:Connect(function(reached)
        finished = true
        connection:Disconnect()
    end)
    -- fallback เผื่อ MoveToFinished ไม่ถูกเรียก
    while not finished and (targetPosition - HRP.Position).Magnitude > 2 do
        task.wait(0.1)
    end	
end

local function isStrangerNearby(excludeList)
    local radius = 60
    local localPlayer = game.Players.LocalPlayer
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

    local myPos = myChar.HumanoidRootPart.Position

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local isFriend = false
            for _, name in ipairs(excludeList) do
                if player.Name == name then
                    isFriend = true
                    break
                end
            end

            if not isFriend then
                local targetPos = player.Character.HumanoidRootPart.Position
                local distance = (targetPos - myPos).Magnitude
                if distance <= radius then
                    print("🚨 พบผู้เล่นไม่รู้จัก:", player.Name, "ระยะ:", math.floor(distance))
                    return true
                end
            end
        end
    end
    return false
end

function Downhole()
    local newPosition = Vector3.new(156.259171, 255.476334, 546.221863) -- พร้อมลงหลุม
    walkTo(newPosition)
    local friendNames = {"ชื่อเพื่อน1", "ชื่อเพื่อน2"}
    local isNear = isStrangerNearby(friendNames)
    if isNear then
        wait(10)
    else
        local newPosition = Vector3.new(142.8758087158203, 208.4701385498047, 561.4888305664062) -- ลงหลุม
        walkTo(newPosition)
    end
end

function Getmany()
    local getmany = true

    while getmany do
        local oldmany = DataCore.money.hand
        local oldition = Vector3.new(132.82102966308594, 255.47634887695312, 492.4247131347656)
        walkTo(oldition)
        local targetPosition = Vector3.new(113.7680892944336, 255.1897430419922, 463.8665771484375)
        walkTo(targetPosition)
        pcall(function()
            return Get("transfer_funds", "hand", "bank", DataCore.money.hand)
        end)
        wait(1.5)
        pcall(function()
            return Get("transfer_funds", "bank", "hand", 118500)
        end)
        walkTo(oldition)
        wait(2)
        local newmany = DataCore.money.hand
        if newmany > oldmany then
            getmany = false
        end
    end
end

function Getmanyall()
    local getmany = true
    while getmany do
        local oldmany = DataCore.money.hand
        local oldition = Vector3.new(132.82102966308594, 255.47634887695312, 492.4247131347656)
        walkTo(oldition)
        local targetPosition = Vector3.new(113.7680892944336, 255.1897430419922, 463.8665771484375)
        walkTo(targetPosition)
        pcall(function()
            return Get("transfer_funds", "bank", "hand", DataCore.money.bank)
        end)
        walkTo(oldition)
        wait(2)
        local newmany = DataCore.money.hand
        if newmany > oldmany then
            getmany = false
        end
    end
end

function postmany()
    local getmany = true
    while getmany do
        local oldmany = DataCore.money.hand
        local oldition = Vector3.new(132.82102966308594, 255.47634887695312, 492.4247131347656)
        walkTo(oldition)
        local targetPosition = Vector3.new(113.7680892944336, 255.1897430419922, 463.8665771484375)
        walkTo(targetPosition)
        pcall(function()
            return Get("transfer_funds", "hand", "bank", DataCore.money.hand)
        end)  
        walkTo(oldition)
        wait(2)
        local newmany = DataCore.money.hand
        if newmany > oldmany then
            getmany = false
        end
    end
end

function TeleportByJobId(jobid)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobid, game.Players.LocalPlayer)
end
-- ✅ ทำ UI เดียวให้คงอยู่ข้ามการตาย/รีสปอน
local rootGuiName = "NP_UI"
local existing = localPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild(rootGuiName)
if existing then existing:Destroy() end

local rootGui = Instance.new("ScreenGui")
rootGui.Name = rootGuiName
rootGui.ResetOnSpawn = false    -- สำคัญ!
rootGui.DisplayOrder = 999
rootGui.IgnoreGuiInset = false
rootGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- ========== Money Display ==========
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0, 400, 0, 40)
moneyLabel.Position = UDim2.new(1, -410, 0, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.TextColor3 = Color3.new(1, 1, 1)
moneyLabel.TextStrokeTransparency = 0.5
moneyLabel.Font = Enum.Font.SourceSansBold
moneyLabel.TextSize = 22
moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
moneyLabel.ZIndex = 10
moneyLabel.Parent = rootGui

-- อัปเดตเงินทุกเฟรม
RunService.RenderStepped:Connect(function()
    local bank = DataCore.money.bank or 0
    local hand = DataCore.money.hand or 0
    moneyLabel.Text = string.format("Server %s | 💰 Bank: %s  |  🖐 Hand: %s", game.PlaceId, bank, hand)
end)

-- ========== Copy JobId Button ==========
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 400, 0, 40)
copyBtn.Position = UDim2.new(1, -410, 0, 50)
copyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Text = "Copy JobId"
copyBtn.TextSize = 22
copyBtn.BorderSizePixel = 0
copyBtn.AutoButtonColor = true
copyBtn.ZIndex = 11
copyBtn.Parent = rootGui

local copyCorner = Instance.new("UICorner", copyBtn)
copyCorner.CornerRadius = UDim.new(0, 12)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(game.JobId)
        copyBtn.Text = "Copied!"
        task.delay(1.5, function() copyBtn.Text = "Copy JobId" end)
    else
        copyBtn.Text = "No setclipboard"
        task.delay(1.5, function() copyBtn.Text = "Copy JobId" end)
    end
end)

-- ========== ปุ่ม Action ต่าง ๆ ==========
local function createButton(name, text, positionY, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(1, -210, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextSize = 20
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.ZIndex = 11
    button.Parent = rootGui
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.MouseButton1Click:Connect(function() pcall(callback) end)
end

createButton("Btn2", "🚪 Remove Door + Walk", 100, function()
    for _, v in pairs(game:GetDescendants()) do
        if v.Name == "DoorSystem" then v:Destroy() end
    end
    walkToTarget(Vector3.new(120.244728, 255.189713, 467.631744))
    walkTo(Vector3.new(132.82102966308594, 255.47634887695312, 492.4247131347656))
end)

createButton("Btn3", "💰 Getmany", 150, function() Getmany() end)
createButton("Btn4", "⬇️ Downhole", 200, function() Downhole() end)
createButton("Btn5", "📤 Postmany", 250, function() postmany() end)
createButton("Btn6", "💸 GetmanyAll", 300, function() Getmanyall() end)

-- ========== Teleport by JobId ==========
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = rootGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Teleport by JobId"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 30)
textBox.Position = UDim2.new(0, 10, 0, 30)
textBox.PlaceholderText = "ใส่ JobId ที่นี่"
textBox.Text = ""
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 16
textBox.Parent = frame
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1, -20, 0, 30)
tpBtn.Position = UDim2.new(0, 10, 0, 65)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 16
tpBtn.Text = "Teleport"
tpBtn.Parent = frame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

local function TeleportByJobId(jobid)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobid, localPlayer)
end

tpBtn.MouseButton1Click:Connect(function()
    local jobid = textBox.Text
    if jobid ~= "" then
        TeleportByJobId(jobid)
    else
        tpBtn.Text = "⚠️ ใส่ JobId ก่อน"
        task.delay(1.5, function() tpBtn.Text = "Teleport" end)
    end
end)

-- setclipboard(game.JobId)
