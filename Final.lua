```lua
print("HamzBeta mulai loading Rayfield UI...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "HamzBetaTeater DEWA FINAL ☠️",
    LoadingTitle = "MODE DEWA FINAL FORM",
    LoadingSubtitle = "All-In-One God Tier Script",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
})

local FarmTab   = Window:CreateTab("Farm", 0x00FF64)
local CombatTab = Window:CreateTab("Combat", 0xFF0000)
local QuestTab  = Window:CreateTab("Quest", 0xFFFF00)
local VisualTab = Window:CreateTab("Visual", 0x00FFFF)
local MiscTab   = Window:CreateTab("Misc", 0xFFFFFF)

-- ==================== DEWA FINAL VARIABLES ====================
local farmEnabled = false
local farmLoop = nil

local godEnabled = false
local godLoop = nil

local killAuraEnabled = false
local killAuraRadius = 50
local auraLoop = nil

local autoGetQuestEnabled = false
local selectedQuest = "QuestNPC1"

local autoAbandonEnabled = false
local abandonLoop = nil

local espEnabled = false
local espLoop = nil

local antiAFKEnabled = false
local autoHopEnabled = true

local modeDewa = true   -- true = brutal speed | false = legit mode

local lastTarget = nil
local stuckTime = 0

local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local QuestAccept = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept")
local QuestAbandon = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAbandon")

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- ==================== DEWA CORE FUNCTIONS ====================

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

-- 🚫 SMART FILTER (no dummy)
local function isValid(npc)
    if not npc then return false end
    local hum = npc:FindFirstChild("Humanoid")
    local root = npc:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    if hum.Health <= 0 then return false end
    if string.find(npc.Name:lower(), "dummy") then return false end
    return true
end

-- 🧠 SMART TARGET (paling dekat)
local function getTarget()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    
    local best, dist = nil, math.huge
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if isValid(npc) then
            local d = (myRoot.Position - npc.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                best = npc
            end
        end
    end
    return best
end

-- 👑 BOSS PRIORITY
local function getBoss()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if isValid(npc) and string.find(npc.Name:lower(), "boss") then
            return npc
        end
    end
    return nil
end

-- ⚔️ SUPER ATTACK (hit + skill spam)
local function attack(target)
    if not target then return end
    
    -- 🕵️ Ghost hit (legit mode biar ga keliatan bot)
    if not modeDewa and math.random(1,5) == 1 then return end
    
    -- ⚡ Brutal spam
    for i = 1, (modeDewa and 8 or 3) do
        fireAura(target)
    end
    
    -- ⚔️ Auto skill semua tool
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool:Activate() end)
            end
        end
    end
end

-- 💎 SMART LOOT (Chest/Gem atau semua di dewa mode)
local wanted = { ["Chest"] = true, ["Gem"] = true }

local function collect()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("TouchTransmitter") then
                local name = v.Parent.Name
                if wanted[name] or modeDewa then
                    firetouchinterest(player.Character.HumanoidRootPart, v.Parent, 0)
                    firetouchinterest(player.Character.HumanoidRootPart, v.Parent, 1)
                end
            end
        end
    end)
end

-- 🚀 SERVER HOP
local function serverHop()
    if autoHopEnabled then
        TeleportService:Teleport(game.PlaceId)
    end
end

-- 🔥 ANTI DETECT DELAY
local function getDelay()
    if modeDewa then
        return 0.02
    else
        return math.random(5,15)/100
    end
end

-- ==================== GOD MODE & LAINNYA ====================

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
            task.wait(0.05)
        end
    end)
    coroutine.resume(auraLoop)
end

local function startAutoAbandon()
    if abandonLoop then return end
    abandonLoop = coroutine.create(function()
        while autoAbandonEnabled do
            pcall(function() QuestAbandon:FireServer() end)
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

-- ==================== FINAL FARM LOOP (INTI DEWA) ====================
FarmTab:CreateToggle({
    Name = "Auto Farm DEWA FINAL ☠️",
    CurrentValue = false,
    Flag = "AutoFarmDEWA",
    Callback = function(Value)
        farmEnabled = Value
        if farmEnabled then
            startGodMode()
            farmLoop = coroutine.create(function()
                while farmEnabled do
                    pcall(function()
                        local char = player.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end

                        -- Equip tool
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            local tool = backpack:FindFirstChildOfClass("Tool")
                            if tool then tool.Parent = char end
                        end

                        -- 👑 Boss priority dulu
                        local boss = getBoss()
                        local target = boss or getTarget()

                        if target and target:FindFirstChild("HumanoidRootPart") then
                            root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                            attack(target)
                            collect()
                        else
                            -- Ga ada target = auto server hop
                            serverHop()
                        end
                    end)
                    task.wait(getDelay())
                end
            end)
            coroutine.resume(farmLoop)
        else
            farmEnabled = false
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Farm Boss Priority",
    CurrentValue = false,
    Flag = "BossPriority",
    Callback = function(Value)
        -- (sudah dihandle di dalam loop)
    end,
})

-- ==================== COMBAT ====================
CombatTab:CreateToggle({
    Name = "Kill Aura",
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

-- ==================== QUEST ====================
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
    Name = "Auto Get Quest + Turn In",
    CurrentValue = false,
    Flag = "GetQuest",
    Callback = function(Value)
        autoGetQuestEnabled = Value
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

-- ==================== VISUAL ====================
VisualTab:CreateToggle({
    Name = "ESP All NPCs",
    CurrentValue = false,
    Flag = "ESPNPC",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then startESP() else cleanupESP() espEnabled = false end
    end,
})

-- ==================== MISC (SUPER RAPI) ====================
MiscTab:CreateToggle({
    Name = "Mode Legit (Anti Detect)",
    CurrentValue = false,
    Flag = "ModeLegit",
    Callback = function(Value)
        modeDewa = not Value
    end,
})

MiscTab:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = true,
    Flag = "AutoHop",
    Callback = function(Value)
        autoHopEnabled = Value
    end,
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        antiAFKEnabled = Value
    end,
})

-- ==================== BACKGROUND LOOPS ====================
-- Auto Quest
task.spawn(function()
    while true do
        if autoGetQuestEnabled then
            pcall(function()
                QuestAbandon:FireServer()
                task.wait(0.5)
                QuestAccept:FireServer(selectedQuest)
            end)
        end
        task.wait(20)
    end
end)

-- Anti AFK
player.Idled:Connect(function()
    if antiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

print("✅ HamzBetaTeater DEWA FINAL ☠️ FULLY LOADED!")
print("⚡ Super Speed | 👑 Boss Priority | 💎 Smart Loot | 🚀 Auto Server Hop | 🕵️ Legit Mode")
print("AFK = auto naik level + ganti server sendiri. Gas bro! 🔥")
```
