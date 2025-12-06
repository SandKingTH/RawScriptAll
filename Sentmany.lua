repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
task.wait(3)

-- ====== ปิด Splash / BGM ======
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


-- ====== Setup ======
local plr = game.Players.LocalPlayer
local Char = plr.Character or plr.CharacterAdded:Wait()
local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local DataCore = require(ReplicatedStorage.Modules.Core.Data)

local NetCore = require(ReplicatedStorage.Modules.Core.Net)
local Authenticate = debug.getupvalue(NetCore.get, 1)
local function Get(...)
    Authenticate.func += 1
    return game:GetService("ReplicatedStorage").Remotes.Get:InvokeServer(Authenticate.func, ...)
end

local runningTasks = {
    key2 = false,
    getmany = false,
    downhole = false,
    postmany = false,
    getmanyall = false,
}
local function updateStatusUI() end

local localPlayer = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyDisplay"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

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
moneyLabel.Parent = screenGui

RunService.RenderStepped:Connect(function()
    local bank = DataCore.money.bank or 0
    local hand = DataCore.money.hand or 0
    moneyLabel.Text = string.format("Server %s | 💰 Bank: %s  |  🖐 Hand: %s", game.PlaceId, bank, hand)
end)

local gui = Instance.new("ScreenGui")
gui.Name = "CopyJobIdGui"
gui.Parent = localPlayer.PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 400, 0, 40)
button.Position = UDim2.new(1, -410, 0, 50)
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
button.TextColor3 = Color3.fromRGB(0, 0, 0)
button.Font = Enum.Font.GothamBold
button.Text = "Copy JobId"
button.TextSize = 22
button.BorderSizePixel = 0
button.AutoButtonColor = true
button.Parent = gui
button.ZIndex = 11

local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(0, 12)

button.MouseButton1Click:Connect(function()
    setclipboard(game.JobId)
    button.Text = "Copied!"
    task.wait(1.5)
    button.Text = "Copy JobId"
end)

local statusGui = Instance.new("ScreenGui")
statusGui.Name = "TaskStatusUI"
statusGui.ResetOnSpawn = false
statusGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 220, 0, 170)
panel.Position = UDim2.new(1, -230, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = statusGui

local cornerP = Instance.new("UICorner", panel)
cornerP.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 26)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "🟢 Task Status"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local list = Instance.new("Frame")
list.Size = UDim2.new(1, -16, 1, -40)
list.Position = UDim2.new(0, 8, 0, 36)
list.BackgroundTransparency = 1
list.Parent = panel

local UIListLayout = Instance.new("UIListLayout", list)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- แถวสถานะแต่ละงาน
local rows = {
    { key = "key2",       label = "2) DoorRun"   },
    { key = "getmany",    label = "3) Getmany"   },
    { key = "downhole",   label = "4) Downhole"  },
    { key = "postmany",   label = "5) Postmany"  },
    { key = "getmanyall", label = "6) GetmanyAll"},
    -- ปุ่ม 7 เป็น one-shot ไม่ต้องโชว์ “กำลังรัน”
}

local rowMap = {} -- key -> {dot=Frame,label=TextLabel}

local function createRow(text)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 0, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(128,128,128) -- เทา=หยุด
    dot.BorderSizePixel = 0
    dot.Parent = row
    local dotCorner = Instance.new("UICorner", dot)
    dotCorner.CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. "  (stopped)"
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.Parent = row

    return row, dot, lbl
end

for _, cfg in ipairs(rows) do
    local row, dot, lbl = createRow(cfg.label)
    row.Parent = list
    rowMap[cfg.key] = { dot = dot, label = lbl, name = cfg.label }
end

-- ปุ่ม Toggle แผง (RightControl)
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        panel.Visible = not panel.Visible
    end
end)

-- ฟังก์ชันอัปเดต UI ตาม runningTasks
local function setRowState(key, running)
    local row = rowMap[key]
    if not row then return end
    if running then
        row.dot.BackgroundColor3 = Color3.fromRGB(0, 200, 100) -- เขียว=กำลังรัน
        row.label.Text = row.name .. "  (running)"
        row.label.TextColor3 = Color3.fromRGB(230,255,230)
    else
        row.dot.BackgroundColor3 = Color3.fromRGB(128,128,128) -- เทา=หยุด
        row.label.Text = row.name .. "  (stopped)"
        row.label.TextColor3 = Color3.fromRGB(220,220,220)
    end
end

function updateStatusUI()
    setRowState("key2",       runningTasks.key2)
    setRowState("getmany",    runningTasks.getmany)
    setRowState("downhole",   runningTasks.downhole)
    setRowState("postmany",   runningTasks.postmany)
    setRowState("getmanyall", runningTasks.getmanyall)
end

local vim = game:GetService("VirtualInputManager")
local runningShift = false  -- ตัวควบคุม loop ของการกด Shift

-- ฟังก์ชันกด Shift
local function startShiftPress()
    runningShift = true
    task.spawn(function()
        while runningShift do
            vim:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)  -- กด
            task.wait(1)
            vim:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) -- ปล่อย
        end
    end)
end

local function stopShiftPress()
    runningShift = false
end


-- ====== เดิน ======
local function walkToTarget(targetPosition)
    local plr_ = Players.LocalPlayer
    local Char_ = plr_.Character or plr_.CharacterAdded:Wait()
    if not Char_ or not Char_:FindFirstChild("HumanoidRootPart") or not Char_:FindFirstChild("Humanoid") then
        warn("Character หรือ Humanoid ยังไม่พร้อม")
        return
    end
    local Humanoid = Char_.Humanoid
    local fromPos = Char_.HumanoidRootPart.Position

    local path = game:GetService("PathfindingService"):CreatePath({
        AgentRadius = 2,
        AgentHeight = 3.7,
        AgentCanJump = false,
        AgentCanClimb = false,
        AgentMaxSlope = 45,
    })
    path:ComputeAsync(fromPos, targetPosition)

    Char_.Humanoid.WalkSpeed = 35
    if path.Status ~= Enum.PathStatus.Success then
        warn("Pathfinding ล้มเหลว: " .. tostring(path.Status))
        return
    end
    for i, wp in ipairs(path:GetWaypoints()) do
        local targetPos = wp.Position
        Humanoid:MoveTo(targetPos)
        local reached = false
        local conn = Humanoid.MoveToFinished:Connect(function() reached = true end)
        repeat task.wait() until reached
        conn:Disconnect()
        if (targetPos - Char_.HumanoidRootPart.Position).Magnitude > 10 then
            warn("ไปไม่ถึงเป้าหมาย waypoint", i)
            break
        end
    end
end

local function walkTo(targetPosition)
    local Char_ = plr.Character or plr.CharacterAdded:Wait()
    local Humanoid = Char_:WaitForChild("Humanoid")
    local HRP = Char_:WaitForChild("HumanoidRootPart")
    Humanoid.WalkSpeed = 30
    Humanoid:MoveTo(targetPosition)

    local finished = false
    local conn
    conn = Humanoid.MoveToFinished:Connect(function()
        finished = true
        if conn then conn:Disconnect() end
    end)
    while not finished and (targetPosition - HRP.Position).Magnitude > 2 do
        task.wait(0.1)
    end
end

-- ====== Detector รอบตัว (กันคนแปลกหน้า) ======
local function isStrangerNearby(excludeList)
    local radius = 60
    local me = Players.LocalPlayer
    local myChar = me.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = myChar.HumanoidRootPart.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= me and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local isFriend = false
            for _, name in ipairs(excludeList) do
                if p.Name == name then isFriend = true break end
            end
            if not isFriend then
                local pos = p.Character.HumanoidRootPart.Position
                local d = (pos - myPos).Magnitude
                if d <= radius then
                    print("🚨 พบผู้เล่นไม่รู้จัก:", p.Name, "ระยะ:", math.floor(d))
                    return true
                end
            end
        end
    end
    return false
end

-- ====== Check ATM พร้อมแฮ็ก ณ ตำแหน่ง ======
local function checkHackableATMAtPosition(targetPos, tolerance)
    tolerance = tolerance or 2
    for _, atm in ipairs(workspace.Map.Props.ATMs:GetChildren()) do
        for _, child in ipairs(atm:GetChildren()) do
            local screen = child:FindFirstChild("Screen")
            if screen then
                local pos = child.Position
                if (pos - targetPos).Magnitude <= tolerance then
                    if screen.Enabled == false then
                        return true, child, "ready"
                    else
                        return false, child, "not_ready"
                    end
                end
            end
        end
    end
    return false, nil, "not_found"
end

-- ====== ชุดตำแหน่งที่ใช้บ่อย ======
local POS = {
    Oldition = Vector3.new(1175.5975341796875, 255.39828491210938, -561.4488525390625),
    ATMSpot = Vector3.new(113.7680892944336, 255.1897430419922, 463.8665771484375),
    DoorRun = CFrame.new(1175.0489501953125, 255.33151245117188, -547.7031860351562),
    DownholeReady = Vector3.new(156.259171, 255.476334, 546.221863),
    DownholeDrop  = Vector3.new(142.8758087158203, 208.4701385498047, 561.4888305664062),
    ATMCheck = Vector3.new(109.73040771484375, 255.2530059814453, 464.5361328125),
}

-- ====== งานของแต่ละปุ่ม (เป็น Toggle) ======

-- Key 2: ทำลาย DoorSystem แล้วเดินตามเส้นทาง (ถ้ากดซ้ำ = หยุดก่อน)
local function DoKey2DoorRun()
    if runningTasks.key2 then
        runningTasks.key2 = false
        updateStatusUI()
        warn("⏹️ หยุด Key2 (DoorRun)")
        return
    end
    runningTasks.key2 = true
    updateStatusUI()
    startShiftPress()

    task.spawn(function()
        -- ขั้นตอนเป็นบล็อกสั้น ๆ และเช็ค flag ระหว่างทาง
        for _, v in pairs(game:GetDescendants()) do
            if not runningTasks.key2 then break end
            if v.Name == "DoorSystem" then v:Destroy() end
        end
        if not runningTasks.key2 then return end

        walkToTarget(POS.DoorRun.Position)
        if not runningTasks.key2 then return end

        walkTo(POS.Oldition)
        runningTasks.key2 = false
        updateStatusUI()
        print("✅ Key2 Done")
        startShiftPress()
    end)
end

local function moveToWithAbort(targetPos, abortCheck, taskFlagKey)
    local Char_ = plr.Character or plr.CharacterAdded:Wait()
    local Humanoid = Char_:WaitForChild("Humanoid")
    local HRP = Char_:WaitForChild("HumanoidRootPart")
    Humanoid.WalkSpeed = 30

    -- เดินแบบเป็นช่วงสั้น ๆ พร้อมเช็ค abort ระหว่างทาง
    while runningTasks[taskFlagKey] and (targetPos - HRP.Position).Magnitude > 2 do
        Humanoid:MoveTo(targetPos)

        -- ตรวจทุก ๆ ~0.2-0.3 วิ ว่าเงื่อนไขยกเลิกเกิดขึ้นไหม
        local t0 = os.clock()
        while runningTasks[taskFlagKey] and (os.clock() - t0) < 0.3 do
            task.wait(0.1)
            if abortCheck and abortCheck() then
                -- ยกเลิกการเดิน
                return false
            end
        end
    end
    return runningTasks[taskFlagKey] -- true ถ้ายังไม่ถูกปิดงานกลางทาง
end

local function Getmany()
    if runningTasks.getmany then
        runningTasks.getmany = false
        updateStatusUI()
        warn("⏹️ หยุด Getmany")
        return
    end
    runningTasks.getmany = true
    updateStatusUI()
    startShiftPress()
    task.spawn(function()
        while runningTasks.getmany do
            local ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
            if not ok then
                task.wait(0.5)
                continue
            end
            local oldmany = DataCore.money.hand or 0
            if not runningTasks.getmany then break end
            walkTo(POS.Oldition)
            local aborted = not moveToWithAbort(
                POS.ATMSpot,
                function()
                    local _ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
                    return not _ok
                end,
                "getmany"
            )

            if not runningTasks.getmany then break end

            if aborted then
                warn("⤴️ ATM เปลี่ยนสถานะระหว่างเดิน: เดินกลับฐาน")
                walkTo(POS.Oldition)
                task.wait(0.5)
                continue
            end
            ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
            if not ok then
                warn("⚠️ ถึงจุดแล้วแต่ ATM ไม่พร้อม: เดินกลับฐาน")
                walkTo(POS.Oldition)
                task.wait(0.5)
                continue
            end
            local getmonay = 118500 - oldmany
            pcall(function()
                return Get("transfer_funds", "bank", "hand", getmonay)
            end)
            walkTo(POS.DownholeReady)
            task.wait(2)
            local newmany = DataCore.money.hand or 0
            if newmany > oldmany then
                runningTasks.getmany = false
                updateStatusUI()
            else
                walkTo(POS.Oldition)
                task.wait(0.5)
            end
        end

        print("✅ Getmany Done")
        stopShiftPress()
    end)
end

-- Key 4: Downhole (พร้อมเช็คคนแปลกหน้า)
local function Downhole()
    if runningTasks.downhole then
        runningTasks.downhole = false
        updateStatusUI()
        warn("⏹️ หยุด Downhole")
        return
    end
    runningTasks.downhole = true
    updateStatusUI()
    startShiftPress()
    task.spawn(function()
        walkTo(POS.DownholeReady)
        runningTasks.downhole = false
        updateStatusUI()
        print("✅ Downhole Done")
        stopShiftPress()
    end)
end

-- Key 5: postmany (เช็ค ATM ตำแหน่งเจาะจง + โอนเงิน)
local function Postmany()
    if runningTasks.postmany then
        runningTasks.postmany = false
        updateStatusUI()
        warn("⏹️ หยุด Postmany")
        return
    end
    runningTasks.postmany = true
    updateStatusUI()
    startShiftPress()
    task.spawn(function()
        while runningTasks.postmany do
            local ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
            if not ok then
                task.wait(0.5)
                continue
            end
            local oldmany = DataCore.money.bank or 0
            if not runningTasks.postmany then break end
            walkTo(POS.Oldition)
            local aborted = not moveToWithAbort(
                POS.ATMSpot,
                function()
                    local _ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
                    return not _ok
                end,
                "postmany"
            )
            if not runningTasks.postmany then break end

            if aborted then
                warn("⤴️ ATM ไม่พร้อมระหว่างทาง: เดินกลับ Oldition")
                walkTo(POS.Oldition)
                task.wait(0.5)
                continue
            end
            ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
            if not ok then
                warn("⚠️ ถึงจุดแล้วแต่ ATM ไม่พร้อม: เดินกลับ Oldition")
                walkTo(POS.Oldition)
                task.wait(0.5)
                continue
            end
            pcall(function()
                return Get("transfer_funds", "hand", "bank", DataCore.money.hand or 0)
            end)
            walkTo(POS.Oldition)
            task.wait(2)
            local newmany = DataCore.money.bank or 0
            if newmany > oldmany then
                runningTasks.postmany = false
                updateStatusUI()
            end
        end
        print("✅ Postmany Done")
        stopShiftPress()
    end)
end


-- ฟังก์ชัน Getmanyall
local function Getmanyall()
    if runningTasks.getmanyall then
        runningTasks.getmanyall = false
        updateStatusUI()
        warn("⏹️ หยุด Getmanyall")
        stopShiftPress()  -- ปิด loop Shift
        return
    end
    runningTasks.getmanyall = true
    updateStatusUI()

    -- เริ่มกด Shift ตอนเริ่มงาน
    startShiftPress()

    task.spawn(function()
        while runningTasks.getmanyall do
            local ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
            if not ok then
                task.wait(0.5)
                continue
            end

            local oldmany = DataCore.money.hand or 0
            if not runningTasks.getmanyall then break end
            walkTo(POS.Oldition)

            local aborted = not moveToWithAbort(
                POS.ATMSpot,
                function()
                    local _ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
                    return not _ok
                end,
                "getmanyall"
            )
            if not runningTasks.getmanyall then break end

            if aborted then
                warn("⤴️ ATM เปลี่ยนสถานะระหว่างเดิน: เดินกลับฐาน")
                walkTo(POS.Oldition)
                task.wait(0.5)
                continue
            end

            ok = select(1, checkHackableATMAtPosition(POS.ATMCheck, 2))
            if not ok then
                warn("⚠️ ถึงจุดแล้วแต่ ATM ไม่พร้อม: เดินกลับฐาน")
                walkTo(POS.Oldition)
                task.wait(0.5)
                continue
            end

            pcall(function()
                return Get("transfer_funds", "bank", "hand", DataCore.money.bank or 0)
            end)

            walkTo(POS.DownholeReady)
            task.wait(2)
            local newmany = DataCore.money.hand or 0
            if newmany > oldmany then
                runningTasks.getmanyall = false
                updateStatusUI()
                stopShiftPress() -- ปิด loop Shift ตอนเสร็จ
            end
        end

        print("✅ Getmanyall Done")
        stopShiftPress() -- กันพลาด ถ้าออก loop ด้วยสาเหตุอื่น
    end)
end

-- Key 7: Shutdown (คำสั่งหนึ่งครั้ง ไม่ต้อง toggle)
local function Shutdown()
    local Net_upvr = require(game.ReplicatedStorage.Modules.Core.Net)
    local validity_check = getupvalue(Net_upvr.send, 2)
    if getinfo(validity_check).name == "validity_check" then
        setconstant(validity_check, 3, "getgenv789")
    end
    Net_upvr.send("request_respawn")
    task.wait(3)
    game:Shutdown()
end

-- ====== Keybinds ======
local function main()
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Two then
            DoKey2DoorRun()
        elseif input.KeyCode == Enum.KeyCode.Three then
            Getmany()
        elseif input.KeyCode == Enum.KeyCode.Four then
            Downhole()
        elseif input.KeyCode == Enum.KeyCode.Five then
            Postmany()
        elseif input.KeyCode == Enum.KeyCode.Six then
            Getmanyall()
        elseif input.KeyCode == Enum.KeyCode.Seven then
            Shutdown()
        end
    end)
end

updateStatusUI()
main()
