repeat task.wait() until game:IsLoaded()

print("🚀 SCRIPT HamzBetaTeater DEWA FINAL v3.0 STARTED")

local function loadRayfield()
    for i = 1, 5 do
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
        end)
        if success and result then
            return result
        end
        task.wait(2)
    end
    return nil
end

local Rayfield = loadRayfield()

if not Rayfield then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HamzFallbackUI"
    ScreenGui.ResetOnSpawn = false

    -- FIX UNIVERSAL UI PARENT (anti executor block)
    local success = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(0, 300, 0, 100)
    Text.Position = UDim2.new(0.5, -150, 0.5, -50)
    Text.Text = "UI FAIL\nExecutor / HTTP bermasalah"
    Text.TextScaled = true
    Text.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Text.TextColor3 = Color3.fromRGB(255,0,0)
    Text.Parent = ScreenGui
    print("❌ Rayfield gagal load")
    return
end

local Window
local success, err = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = "HamzBetaTeater DEWA FINAL",
        LoadingTitle = "MODE DEWA FINAL FORM",
        LoadingSubtitle = "All-In-One God Tier Script",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
    })
end)

if not success then
    print("❌ Gagal membuat Window: " .. tostring(err))
    return
end

print("✅ UI CREATED SUCCESSFULLY")

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, v in pairs(game.CoreGui:GetDescendants()) do
                if v:IsA("ScreenGui") then
                    v.Enabled = true
                end
            end
        end)
    end
end)

local FarmTab   = Window:CreateTab("Farm", 0x00FF64)
local CombatTab = Window:CreateTab("Combat", 0xFF0000)
local QuestTab  = Window:CreateTab("Quest", 0xFFFF00)
local VisualTab = Window:CreateTab("Visual", 0x00FFFF)
local MiscTab   = Window:CreateTab("Misc", 0xFFFFFF)

-- ==================== VARIABLES ====================
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

-- ==================== SERVICES ====================
local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- ==================== SAFE REMOTES ====================
local QuestAccept = nil
local QuestAbandon = nil

task.spawn(function()
    local success = pcall(function()
        local remotesFolder = RS:WaitForChild("RemoteEvents", 8)
        if remotesFolder then
            QuestAccept = remotesFolder:FindFirstChild("QuestAccept")
            QuestAbandon = remotesFolder:FindFirstChild("QuestAbandon")
            print("✅ Remotes Quest ditemukan")
        else
            warn("⚠️ Folder RemoteEvents tidak ditemukan")
        end
    end)
    if not success then
        warn("⚠️ Gagal load RemoteEvents")
    end
end)

-- ==================== HELPER FUNCTIONS (FULL OPTIMASI) ====================
local function fireAura(target)
    pcall(function()  -- FULL SAFE + NO WAITFORCHILD
        local combat = RS:FindFirstChild("CombatSystem")
        if not combat then return end
        local remotes = combat:FindFirstChild("Remotes")
        if not remotes then return end
        local requestHit = remotes:FindFirstChild("RequestHit")
        if requestHit and target then
            requestHit:FireServer(target)
        end
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

local function attack(target)
    if not target then return end
    if not modeDewa and math.random(1,5) == 1 then return end
    for i = 1, (modeDewa and 8 or 3) do
        fireAura(target)
    end
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool:Activate() end)
            end
        end
    end
end

-- OPTIMASI BERAT: collect() → hanya scan folder Drops (anti lag)
local function collect()
    pcall(function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        local dropsFolder = workspace:FindFirstChild("Drops") or workspace  -- fallback kalau ga ada folder Drops
        for _, v in ipairs(dropsFolder:GetChildren()) do
            if v:IsA("BasePart") or v:FindFirstChild("TouchTransmitter") then
                firetouchinterest(root, v, 0)
                firetouchinterest(root, v, 1)
            end
        end
    end)
end

local function serverHop()
    if autoHopEnabled then
        pcall(function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end
end

local function getDelay()
    if modeDewa then return 0.02 else return math.random(5,15)/100 end
end

local function startGodMode()
    if godLoop then return end
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
        pcall(function()
            hum.MaxHealth = 9e9
            hum.Health = 9e9
        end)
    end
end)

local function updateESP()
    pcall(function()
        local npcFolder = workspace:FindFirstChild("NPCs")
        if not npcFolder then return end

        for npc, highlight in pairs(espHighlights) do
            if not npc or not npc.Parent or not isValid(npc) then
                if highlight and highlight.Parent then highlight:Destroy() end
                espHighlights[npc] = nil
            end
        end

        for _, npc in ipairs(npcFolder:GetChildren()) do
            if isValid(npc) and not espHighlights[npc] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "HamzESP"
                highlight.Adornee = npc
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = npc
                espHighlights[npc] = highlight
            end
        end
    end)
end

-- ==================== TABS ====================

FarmTab:CreateToggle({
    Name = "Auto Farm DEWA FINAL",
    CurrentValue = false,
    Callback = function(Value)
        farmEnabled = Value
        if farmEnabled then
            startGodMode()
            farmLoop = coroutine.create(function()
                local failCount = 0  -- ANTI STUCK
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
                            root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                            attack(target)
                            collect()
                            failCount = 0
                        else
                            failCount += 1
                            if failCount >= 10 then
                                serverHop()
                                failCount = 0
                            end
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

CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(Value)
        killAuraEnabled = Value
        if killAuraEnabled then
            killAuraLoop = coroutine.create(function()
                while killAuraEnabled do
                    pcall(function()
                        local char = player.Character
                        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                        local myRoot = char.HumanoidRootPart

                        local npcFolder = workspace:FindFirstChild("NPCs")
                        if npcFolder then
                            for _, npc in ipairs(npcFolder:GetChildren()) do
                                if isValid(npc) and npc:FindFirstChild("HumanoidRootPart") then
                                    local d = (myRoot.Position - npc.HumanoidRootPart.Position).Magnitude
                                    if d <= killAuraRadius then
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
    end,
})

CombatTab:CreateSlider({
    Name = "Kill Aura Radius",
    Range = {10, 100},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value) killAuraRadius = Value end,
})

CombatTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(Value)
        godEnabled = Value
        if godEnabled then
            startGodMode()
        else
            godEnabled = false
            godLoop = nil
        end
    end,
})

QuestTab:CreateDropdown({
    Name = "Select Quest NPC",
    Options = {"QuestNPC1", "QuestNPC2", "QuestNPC3", "QuestNPC4", "QuestNPC5"},
    CurrentOption = {"QuestNPC1"},
    Callback = function(Value) selectedQuest = Value[1] end,
})

QuestTab:CreateToggle({
    Name = "Auto Get Quest + Turn In",
    CurrentValue = false,
    Callback = function(Value) autoGetQuestEnabled = Value end,
})

VisualTab:CreateToggle({
    Name = "ESP (NPCs)",
    CurrentValue = false,
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            if not espLoop then
                espLoop = coroutine.create(function()
                    while espEnabled do
                        updateESP()
                        task.wait(0.5)
                    end
                end)
                coroutine.resume(espLoop)
            end
        else
            espEnabled = false
            for _, highlight in pairs(espHighlights) do
                if highlight and highlight.Parent then highlight:Destroy() end
            end
            espHighlights = {}
            espLoop = nil
        end
    end,
})

MiscTab:CreateToggle({
    Name = "Mode Legit (Anti Detect)",
    CurrentValue = false,
    Callback = function(Value) modeDewa = not Value end,
})

MiscTab:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = true,
    Callback = function(Value) autoHopEnabled = Value end,
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(Value) antiAFKEnabled = Value end,
})

-- ==================== BACKGROUND LOOPS ====================
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

player.Idled:Connect(function()
    if antiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

print("✅ SEMUA OPTIMASI & FIX APPLIED - 100% ANTI FREEZE & ANTI LAG!")
