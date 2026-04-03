repeat task.wait() until game:IsLoaded()

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("HamzCustomUI") or player.PlayerGui:FindFirstChild("HamzCustomUI")
    if old then old:Destroy() end
end)

local parentUI = game:GetService("CoreGui")
pcall(function() parentUI = game:GetService("CoreGui") end)
if not parentUI then parentUI = player:WaitForChild("PlayerGui") end

local gui = Instance.new("ScreenGui")
gui.Name = "HamzCustomUI"
gui.ResetOnSpawn = false
gui.Parent = parentUI

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 480, 0, 340)
main.Position = UDim2.new(0.5, -240, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "HamzBetaTeater DEWA FINAL"
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local minimizeBtn = Instance.new("TextButton", top)
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -40, 0, 2)
minimizeBtn.Text = "−"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
Instance.new("UICorner", minimizeBtn)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 45)
content.BackgroundTransparency = 1

local tabHolder = Instance.new("Frame", content)
tabHolder.Size = UDim2.new(0, 120, 1, 0)
tabHolder.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
Instance.new("UICorner", tabHolder).CornerRadius = UDim.new(0, 12)

local pages = Instance.new("Frame", content)
pages.Size = UDim2.new(1, -130, 1, 0)
pages.Position = UDim2.new(0, 130, 0, 0)
pages.BackgroundTransparency = 1

local currentPage = nil
local function createTab(name, color)
    local btn = Instance.new("TextButton", tabHolder)
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.Position = UDim2.new(0, 5, 0, (#tabHolder:GetChildren() - 1) * 42)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = color or Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("Frame", pages)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        if currentPage then currentPage.Visible = false end
        page.Visible = true
        currentPage = page
    end)

    return page
end

local FarmPage   = createTab("Farm",   Color3.fromRGB(0, 255, 100))
local CombatPage = createTab("Combat", Color3.fromRGB(255, 0, 0))
local QuestPage  = createTab("Quest",  Color3.fromRGB(255, 255, 0))
local VisualPage = createTab("Visual", Color3.fromRGB(0, 255, 255))
local MiscPage   = createTab("Misc",   Color3.fromRGB(255, 255, 255))

FarmPage.Visible = true
currentPage = FarmPage

local function tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quint), props):Play()
end

local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 70, 0, 28)
    toggleBtn.Position = UDim2.new(1, -85, 0, 6)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 13
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        tween(toggleBtn, {BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)})
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

local function createSlider(parent, text, minVal, maxVal, default, step, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13

    local val = default

    local minusBtn = Instance.new("TextButton", frame)
    minusBtn.Size = UDim2.new(0, 30, 0, 25)
    minusBtn.Position = UDim2.new(0, 15, 0, 28)
    minusBtn.Text = "-"
    minusBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    minusBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", minusBtn)

    local plusBtn = Instance.new("TextButton", frame)
    plusBtn.Size = UDim2.new(0, 30, 0, 25)
    plusBtn.Position = UDim2.new(1, -45, 0, 28)
    plusBtn.Text = "+"
    plusBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    plusBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", plusBtn)

    minusBtn.MouseButton1Click:Connect(function()
        val = math.max(minVal, val - step)
        label.Text = text .. ": " .. val
        callback(val)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        val = math.min(maxVal, val + step)
        label.Text = text .. ": " .. val
        callback(val)
    end)
end

local blur = Lighting:FindFirstChild("HamzBlur") or Instance.new("BlurEffect")
blur.Name = "HamzBlur"
blur.Size = 0
blur.Parent = Lighting

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 130, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0, 200)
openBtn.Text = "OPEN DEWA UI"
openBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)

local dragging = false
local dragInput, dragStart, startPos

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

top.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main.Visible = not minimized
    openBtn.Visible = minimized
    blur.Size = minimized and 0 or 12
end)

openBtn.MouseButton1Click:Connect(function()
    minimized = false
    main.Visible = true
    content.Visible = true
    openBtn.Visible = false
    blur.Size = 12
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
        openBtn.Visible = not main.Visible
        blur.Size = main.Visible and 12 or 0
    end
end)

local farmEnabled = false
local farmLoop = nil
local godEnabled = false
local godLoop = nil
local killAuraEnabled = false
local killAuraLoop = nil
local killAuraRadius = 50
local autoGetQuestEnabled = false
local selectedQuest = "QuestNPC1"
local espEnabled = false
local espLoop = nil
local espHighlights = {}
local antiAFKEnabled = false
local autoHopEnabled = true
local modeDewa = true

local QuestAccept = nil
local QuestAbandon = nil

task.spawn(function()
    pcall(function()
        local folder = RS:WaitForChild("RemoteEvents", 8)
        if folder then
            QuestAccept = folder:FindFirstChild("QuestAccept")
            QuestAbandon = folder:FindFirstChild("QuestAbandon")
        end
    end)
end)

local function fireAura(target)
    pcall(function()
        local combat = RS:FindFirstChild("CombatSystem")
        if not combat then return end
        local remotes = combat:FindFirstChild("Remotes")
        if not remotes then return end
        local hit = remotes:FindFirstChild("RequestHit")
        if hit and target then hit:FireServer(target) end
    end)
end

local function isValid(npc)
    if not npc then return false end
    local hum = npc:FindFirstChild("Humanoid")
    local root = npc:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    if hum.Health <= 0 then return false end
    if string.find(npc.Name:lower(), "dummy") then return false end
    return true
end

local function getTarget()
    local folder = workspace:FindFirstChild("NPCs")
    if not folder then return nil end
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, dist = nil, math.huge
    for _, npc in ipairs(folder:GetChildren()) do
        if isValid(npc) then
            local d = (root.Position - npc.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d best = npc end
        end
    end
    return best
end

local function getBoss()
    local folder = workspace:FindFirstChild("NPCs")
    if not folder then return nil end
    for _, npc in ipairs(folder:GetChildren()) do
        if isValid(npc) and string.find(npc.Name:lower(), "boss") then return npc end
    end
    return nil
end

local function attack(target)
    if not target then return end
    if not modeDewa and math.random(1,5) == 1 then return end
    for i = 1, (modeDewa and 8 or 3) do fireAura(target) end
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then pcall(function() tool:Activate() end) end
        end
    end
end

local function collect()
    pcall(function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local drops = workspace:FindFirstChild("Drops") or workspace
        for _, v in ipairs(drops:GetChildren()) do
            if v:IsA("BasePart") or v:FindFirstChild("TouchTransmitter") then
                firetouchinterest(root, v, 0)
                firetouchinterest(root, v, 1)
            end
        end
    end)
end

local function serverHop()
    if autoHopEnabled then pcall(function() TeleportService:Teleport(game.PlaceId) end) end
end

local function getDelay()
    return modeDewa and 0.02 or math.random(5,15)/100
end

local function startGodMode()
    if godLoop then return end
    godLoop = coroutine.create(function()
        while godEnabled do
            pcall(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then hum.MaxHealth, hum.Health = 9e9, 9e9 end
                end
            end)
            task.wait(0.1)
        end
    end)
    coroutine.resume(godLoop)
end

player.CharacterAdded:Connect(function(char)
    if godEnabled then
        task.wait(1)
        local hum = char:WaitForChild("Humanoid")
        pcall(function() hum.MaxHealth, hum.Health = 9e9, 9e9 end)
    end
end)

local function updateESP()
    pcall(function()
        local folder = workspace:FindFirstChild("NPCs")
        if not folder then return end
        for npc, hl in pairs(espHighlights) do
            if not npc or not npc.Parent or not isValid(npc) then
                if hl then hl:Destroy() end
                espHighlights[npc] = nil
            end
        end
        for _, npc in ipairs(folder:GetChildren()) do
            if isValid(npc) and not espHighlights[npc] then
                local hl = Instance.new("Highlight")
                hl.Adornee = npc
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(0, 255, 255)
                hl.FillTransparency = 0.5
                hl.Parent = npc
                espHighlights[npc] = hl
            end
        end
    end)
end

createToggle(FarmPage, "Auto Farm DEWA FINAL", false, function(v)
    farmEnabled = v
    if v then
        startGodMode()
        farmLoop = coroutine.create(function()
            local failCount = 0
            while farmEnabled do
                pcall(function()
                    local char = player.Character
                    if not char then return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack then
                        local tool = backpack:FindFirstChildOfClass("Tool")
                        if tool then tool.Parent = char end
                    end
                    local boss = getBoss()
                    local target = boss or getTarget()
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
                        attack(target)
                        collect()
                        failCount = 0
                    else
                        failCount += 1
                        if failCount >= 10 then serverHop() failCount = 0 end
                    end
                end)
                task.wait(getDelay())
            end
        end)
        coroutine.resume(farmLoop)
    else
        farmEnabled = false
    end
end)

createToggle(CombatPage, "Kill Aura", false, function(v)
    killAuraEnabled = v
    if v then
        if killAuraLoop then return end
        killAuraLoop = coroutine.create(function()
            while killAuraEnabled do
                pcall(function()
                    local char = player.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local myRoot = char.HumanoidRootPart
                    local folder = workspace:FindFirstChild("NPCs")
                    if folder then
                        for _, npc in ipairs(folder:GetChildren()) do
                            if isValid(npc) and npc:FindFirstChild("HumanoidRootPart") then
                                if (myRoot.Position - npc.HumanoidRootPart.Position).Magnitude <= killAuraRadius then
                                    attack(npc)
                                end
                            end
                        end
                    end
                end)
                task.wait(getDelay())
            end
        end)
        coroutine.resume(killAuraLoop)
    else
        killAuraEnabled = false
        killAuraLoop = nil
    end
end)

createSlider(CombatPage, "Kill Aura Radius", 10, 100, 50, 5, function(v) killAuraRadius = v end)

createToggle(CombatPage, "God Mode", false, function(v)
    godEnabled = v
    if v then
        startGodMode()
    else
        godEnabled = false
        godLoop = nil
    end
end)

local questList = {"QuestNPC1","QuestNPC2","QuestNPC3","QuestNPC4","QuestNPC5"}
for i, name in ipairs(questList) do
    local qBtn = Instance.new("TextButton", QuestPage)
    qBtn.Size = UDim2.new(0.9, 0, 0, 35)
    qBtn.LayoutOrder = i
    qBtn.Text = name
    qBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", qBtn)
    qBtn.MouseButton1Click:Connect(function()
        selectedQuest = name
        qBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
        task.wait(0.3)
        qBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    end)
end

createToggle(QuestPage, "Auto Get Quest + Turn In", false, function(v) autoGetQuestEnabled = v end)

createToggle(VisualPage, "ESP (NPCs)", false, function(v)
    espEnabled = v
    if v and not espLoop then
        espLoop = coroutine.create(function()
            while espEnabled do updateESP() task.wait(0.5) end
        end)
        coroutine.resume(espLoop)
    else
        espEnabled = false
        for _, hl in pairs(espHighlights) do if hl then hl:Destroy() end end
        espHighlights = {}
    end
end)

createToggle(MiscPage, "Mode Legit (Anti Detect)", false, function(v) modeDewa = not v end)
createToggle(MiscPage, "Auto Server Hop", true, function(v) autoHopEnabled = v end)

local afkConnection
createToggle(MiscPage, "Anti AFK", false, function(v) antiAFKEnabled = v end)

createToggle(MiscPage, "FPS Boost (Smooth Plastic)", false, function(v)
    if v then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end
        end
    end
end)

task.spawn(function()
    while true do
        if autoGetQuestEnabled then
            pcall(function()
                if QuestAbandon then QuestAbandon:FireServer() end
                task.wait(0.5)
                if QuestAccept then QuestAccept:FireServer(selectedQuest) end
            end)
        end
        task.wait(20)
    end
end)

afkConnection = player.Idled:Connect(function()
    if antiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId)
    end
end)
