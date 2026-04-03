print("HamzBeta mulai loading Rayfield UI...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "HamzBetaTeater",
    LoadingTitle = "HamzBeta Is loading",
    LoadingSubtitle = "tunggu sebentar yaaaa",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
})

local FarmTab = Window:CreateTab("Farm", 0x00FF64)
local CombatTab = Window:CreateTab("Combat", 0xFF0000)
local QuestTab = Window:CreateTab("Quest", 0xFFFF00)
local VisualTab = Window:CreateTab("Visual", 0x00FFFF)
local MiscTab = Window:CreateTab("Misc", 0xFFFFFF)

local farmEnabled = false
local farmLoop = nil
local godEnabled = false
local godLoop = nil

local killAuraEnabled = false
local killAuraRadius = 50
local auraLoop = nil

local autoGetQuestEnabled = false
local questLoop = nil
local selectedQuest = "QuestNPC1"

local autoAbandonEnabled = false
local abandonLoop = nil

local espEnabled = false
local espLoop = nil

local flyPosition = "Above"

local RS = game:GetService("ReplicatedStorage")
local QuestAccept = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept")
local QuestAbandon = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAbandon")

local player = game.Players.LocalPlayer

local function getMyLevel()
    local leaderstats = player:WaitForChild("leaderstats", 5)
    if leaderstats and leaderstats:FindFirstChild("Level") then
        return leaderstats.Level.Value
    end
    return 1
end

local function fireAura(target)
    local combat = RS:WaitForChild("CombatSystem", 5)
    if combat then
        local remotes = combat:WaitForChild("Remotes", 5)
        if remotes then
            local requestHit = remotes:FindFirstChild("RequestHit")
            if requestHit and target then
                requestHit:FireServer(target)
            end
        end
    end
end

local function startGodMode()
    if godLoop then return end
    godEnabled = true
    godLoop = coroutine.create(function()
        while godEnabled do
            pcall(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.MaxHealth = 9e9
                        hum.Health = 9e9
                    end
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
        hum.MaxHealth = 9e9
        hum.Health = 9e9
    end
end)

local function startKillAura()
    if auraLoop then return end
    auraLoop = coroutine.create(function()
        while killAuraEnabled do
            pcall(function()
                local char = player.Character
                local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                local npcFolder = workspace:FindFirstChild("NPCs")
                if npcFolder then
                    for _, npc in ipairs(npcFolder:GetChildren()) do
                        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
                            local hum = npc.Humanoid
                            if hum.Health > 0 then
                                local dist = (myRoot.Position - npc.HumanoidRootPart.Position).Magnitude
                                if dist <= killAuraRadius then
                                    fireAura(npc)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.03)
        end
    end)
    coroutine.resume(auraLoop)
end

local function startAutoAbandon()
    if abandonLoop then return end
    abandonLoop = coroutine.create(function()
        while autoAbandonEnabled do
            pcall(function()
                QuestAbandon:FireServer()
            end)
            task.wait(7)
        end
    end)
    coroutine.resume(abandonLoop)
end

local function cleanupESP()
    pcall(function()
        local npcFolder = workspace:FindFirstChild("NPCs")
        if npcFolder then
            for _, npc in ipairs(npcFolder:GetChildren()) do
                local esp = npc:FindFirstChild("ESP")
                if esp then esp:Destroy() end
            end
        end
    end)
end

local function startESP()
    if espLoop then return end
    espLoop = coroutine.create(function()
        while espEnabled do
            pcall(function()
                local npcFolder = workspace:FindFirstChild("NPCs")
                if not npcFolder then return end
                local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local myPos = myRoot and myRoot.Position or Vector3.new()
                for _, npc in ipairs(npcFolder:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
                        local root = npc.HumanoidRootPart
                        local hum = npc.Humanoid
                        if not npc:FindFirstChild("ESP") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "ESP"
                            billboard.Adornee = root
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 200, 0, 70)
                            billboard.StudsOffset = Vector3.new(0, 5, 0)
                            billboard.Parent = npc
                            local text = Instance.new("TextLabel")
                            text.Name = "Text"
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.TextStrokeTransparency = 0
                            text.TextStrokeColor3 = Color3.new(0,0,0)
                            text.TextColor3 = Color3.fromRGB(0, 255, 100)
                            text.TextScaled = true
                            text.Font = Enum.Font.SourceSansBold
                            text.TextXAlignment = Enum.TextXAlignment.Center
                            text.TextYAlignment = Enum.TextYAlignment.Center
                            text.Parent = billboard
                        end
                        local levelVal = npc:FindFirstChild("Level") or npc.Humanoid:FindFirstChild("Level")
                        local npcLevel = levelVal and levelVal.Value or 1
                        local dist = (myPos - root.Position).Magnitude
                        npc.ESP.Text.Text = string.format("%s\nLv.%d  |  HP: %.0f/%.0f\n%.0f stud", npc.Name, npcLevel, hum.Health, hum.MaxHealth, dist)
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
    coroutine.resume(espLoop)
end

FarmTab:CreateToggle({
    Name = "Auto Farm NPC",
    CurrentValue = false,
    Flag = "AutoFarmNPC",
    Callback = function(Value)
        farmEnabled = Value
        if farmEnabled then
            startGodMode()
            farmLoop = coroutine.create(function()
                while farmEnabled do
                    pcall(function()
                        local backpack = player:FindFirstChild("Backpack")
                        local character = player.Character
                        if backpack and character then
                            local tool = backpack:FindFirstChildOfClass("Tool")
                            if tool then tool.Parent = character end
                        end
                        local myLevel = getMyLevel()
                        local npcs = {}
                        local npcFolder = workspace:FindFirstChild("NPCs")
                        if npcFolder then
                            for _, obj in ipairs(npcFolder:GetChildren()) do
                                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
                                    local lvl = 1
                                    local lv = obj:FindFirstChild("Level") or obj.Humanoid:FindFirstChild("Level")
                                    if lv and (lv:IsA("IntValue") or lv:IsA("NumberValue")) then lvl = lv.Value end
                                    if lvl <= myLevel + 15 then
                                        table.insert(npcs, obj)
                                    end
                                end
                            end
                        end
                        if #npcs > 0 then
                            local closest = npcs[1]
                            local minDist = math.huge
                            local myRoot = character and character:FindFirstChild("HumanoidRootPart")
                            if myRoot then
                                for _, npc in ipairs(npcs) do
                                    local d = (myRoot.Position - npc.HumanoidRootPart.Position).Magnitude
                                    if d < minDist then minDist = d closest = npc end
                                end
                            end
                            if closest and character and character:FindFirstChild("HumanoidRootPart") then
                                local offsetY = (flyPosition == "Above") and 20 or 3
                                character.HumanoidRootPart.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, offsetY, 0)
                                fireAura(closest)
                            end
                        end
                    end)
                    task.wait(0.08)
                end
            end)
            coroutine.resume(farmLoop)
        else
            farmEnabled = false
            godEnabled = false
        end
    end,
})

FarmTab:CreateDropdown({
    Name = "Fly Position",
    Options = {"Above", "Below"},
    CurrentOption = {"Above"},
    Flag = "FlyPosition",
    Callback = function(Value)
        flyPosition = Value[1]
    end,
})

CombatTab:CreateToggle({
    Name = "Kill Aura Radius",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        killAuraEnabled = Value
        if killAuraEnabled then startKillAura() else killAuraEnabled = false end
    end,
})

CombatTab:CreateSlider({
    Name = "Kill Aura Radius",
    Range = {10, 100},
    Increment = 5,
    CurrentValue = 50,
    Flag = "AuraRadius",
    Callback = function(Value)
        killAuraRadius = Value
    end,
})

CombatTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        godEnabled = Value
        if godEnabled then startGodMode() else godEnabled = false end
    end,
})

QuestTab:CreateDropdown({
    Name = "Select Quest NPC",
    Options = {"QuestNPC1", "QuestNPC2", "QuestNPC3", "QuestNPC4", "QuestNPC5"},
    CurrentOption = {"QuestNPC1"},
    Flag = "SelectQuestNPC",
    Callback = function(Value)
        selectedQuest = Value[1]
    end,
})

QuestTab:CreateToggle({
    Name = "Auto Get Quest",
    CurrentValue = false,
    Flag = "GetQuest",
    Callback = function(Value)
        autoGetQuestEnabled = Value
        if autoGetQuestEnabled then
            pcall(function()
                RS:WaitForChild("Remotes"):WaitForChild("GetTitlesData"):InvokeServer()
                RS:WaitForChild("Remotes"):WaitForChild("ShopRemotes"):WaitForChild("GetBoosts"):InvokeServer()
            end)
            questLoop = coroutine.create(function()
                while autoGetQuestEnabled do
                    pcall(function()
                        QuestAbandon:FireServer()
                        task.wait(1)
                        QuestAccept:FireServer(selectedQuest)
                    end)
                    task.wait(30)
                end
            end)
            coroutine.resume(questLoop)
        else
            autoGetQuestEnabled = false
        end
    end,
})

QuestTab:CreateToggle({
    Name = "Auto Abandon Quest",
    CurrentValue = false,
    Flag = "AutoAbandon",
    Callback = function(Value)
        autoAbandonEnabled = Value
        if autoAbandonEnabled then startAutoAbandon() else autoAbandonEnabled = false end
    end,
})

QuestTab:CreateButton({
    Name = "Manual Abandon Quest",
    Callback = function()
        pcall(function() QuestAbandon:FireServer() end)
    end,
})

VisualTab:CreateToggle({
    Name = "ESP All NPCs",
    CurrentValue = false,
    Flag = "ESPNPC",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then startESP() else cleanupESP() espEnabled = false end
    end,
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        if Value then
            local antiAFKLoop = coroutine.create(function()
                while true do
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new(0, 0))
                    end)
                    task.wait(30)
                end
            end)
            coroutine.resume(antiAFKLoop)
        end
    end,
})
