print("HamzBeta mulai loading Rayfield UI...")

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
end)

if not success then
    warn("Rayfield gagal load!")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "HamzBetaTeater DEWA FINAL",
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
local modeDewa = true

local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local QuestAccept = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept")
local QuestAbandon = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAbandon")
local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

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

local function serverHop()
    if autoHopEnabled then
        TeleportService:Teleport(game.PlaceId)
    end
end

local function getDelay()
    if modeDewa then return 0.02 else return math.random(5,15)/100 end
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

FarmTab:CreateToggle({
    Name = "Auto Farm DEWA FINAL",
    CurrentValue = false,
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
                        else
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
    CurrentValue = true,
    Callback = function() end,
})

CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(Value)
        killAuraEnabled = Value
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
        if godEnabled then startGodMode() end
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

player.Idled:Connect(function()
    if antiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

print("HamzBetaTeater DEWA FINAL LOADED")
