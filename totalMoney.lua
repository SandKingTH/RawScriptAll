
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

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyDisplay"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999 -- ให้อยู่บนสุด
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0, 400, 0, 40)
moneyLabel.Position = UDim2.new(1, -410, 0, 0) -- ขวาบนสุด
moneyLabel.BackgroundTransparency = 1
moneyLabel.TextColor3 = Color3.new(1, 1, 1)
moneyLabel.TextStrokeTransparency = 0.5
moneyLabel.Font = Enum.Font.SourceSansBold
moneyLabel.TextSize = 22
moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
moneyLabel.ZIndex = 10 -- ให้อยู่หน้าสุด
moneyLabel.Parent = screenGui

-- อัปเดตเงินทุกเฟรม
RunService.RenderStepped:Connect(function()
	local bank = DataCore.money.bank or 0
	local hand = DataCore.money.hand or 0
	moneyLabel.Text = string.format("Server %s | 💰 Bank: %s  |  🖐 Hand: %s", game.PlaceId, bank, hand)
end)
-- LocalScript ใน StarterPlayerScripts หรือ StarterGui

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CopyJobIdGui"
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 400, 0, 40)
button.Position = UDim2.new(1, -410, 0, 50) -- อยู่ใต้ MoneyDisplay
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
button.TextColor3 = Color3.fromRGB(0, 0, 0)
button.Font = Enum.Font.GothamBold
button.Text = "Copy JobId"
button.TextSize = 22
button.BorderSizePixel = 0
button.AutoButtonColor = true
button.Parent = gui
button.ZIndex = 11
button.AnchorPoint = Vector2.new(0, 0)

local shadow = Instance.new("UICorner", button)
shadow.CornerRadius = UDim.new(0, 12)

button.MouseButton1Click:Connect(function()
    setclipboard(game.JobId)
    button.Text = "Copied!"
    wait(1.5)
    button.Text = "Copy JobId"
end)

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
		AgentRadius = 1.5,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentCanClimb = false,
		AgentMaxSlope = 45,
	})
	path:ComputeAsync(pos, targetPosition)
	local Humanoidd = Char.Humanoid
	Humanoidd.WalkSpeed = 60
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
    local targetPosition = Vector3.new(-514.9334106445312, 256.6272888183594, 174.13609313964844)
    walkTo(targetPosition)

    local getmany = true

    while getmany do
        local oldmany = DataCore.money.hand

        pcall(function()
            Get("transfer_funds", "hand", "bank", DataCore.money.hand)
        end)

        local newmany = DataCore.money.hand
        if newmany > oldmany or newmany == 0 then
            getmany = false
        end
    end
end

function Getmany()
    local getmany = true

    while getmany do
        local oldmany = DataCore.money.hand
        local oldmanys = DataCore.money.bank

        pcall(function()
            Get("transfer_funds", "bank", "hand", DataCore.money.bank)
        end)
        local newmany = DataCore.money.hand
        if newmany > oldmany or oldmanys == 0 then
            getmany = false
        end
        wait(1)
    end
    local targetPosition = Vector3.new(-543.4095458984375, 256.6272888183594, 128.74124145507812)
    walkTo(targetPosition)
end



function main()
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Two then
            local targetPosition = Vector3.new(-576.653748, 255.094421, 202.536896, 0.935429037, -2.34500619e-09, -0.353514463, 1.16942216e-08, 1, 2.43104843e-08, 0.353514463, -2.68748099e-08, 0.935429037)
            walkToTarget(targetPosition)
            local hitbox = workspace.Map.Tiles.ParkTile.CityHall.Exterior:FindFirstChild("Hitbox")
            if hitbox then
            hitbox:Destroy()
            else
            print("Hitbox not found")
            end

		    local newPosition = Vector3.new(-514.9334106445312, 256.6272888183594, 174.13609313964844)
            walkTo(newPosition)

        elseif input.KeyCode == Enum.KeyCode.Three then
            Getmany()
            
        elseif input.KeyCode == Enum.KeyCode.Four then
            Downhole()

        end
    end)
end
main()
