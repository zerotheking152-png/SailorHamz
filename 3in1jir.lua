print("HamzBeta mulai loading Rayfield UI...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "HamzBeta",
    LoadingTitle = "HamzBeta Is loading",
    LoadingSubtitle = "tunggu sebentar yaaaa",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
})

local MainTab = Window:CreateTab("Main", 0x00FF64)
local MiscTab = Window:CreateTab("Misc", 0x00FFFF)

-- ==================== VARIABEL BARU ====================
local farmEnabled = false
local farmLoop = nil
local godLoop = nil
local godEnabled = false

local autoGetQuestEnabled = false
local questLoop = nil
local selectedQuest = "QuestNPC1"

local flyPosition = "Above"

local killAuraEnabled = false
local killAuraRadius = 50
local auraLoop = nil

local abandonEnabled = false
local abandonLoop = nil

local espEnabled = false
local espLoop = nil

local RS = game:GetService("ReplicatedStorage")

-- Remote Quest
local QuestAccept = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept")
local QuestAbandon = RS:WaitForChild("RemoteEvents"):WaitForChild("QuestAbandon")

local function getMyLevel()
    local leaderstats = game.Players.LocalPlayer:WaitForChild("leaderstats", 5)
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
                local char = game.Players.LocalPlayer.Character
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

-- ==================== KILL AURA ====================
local function startKillAura()
    if auraLoop then return end
    auraLoop = coroutine.create(function()
        while killAuraEnabled do
            pcall(function()
                local char = game.Players.LocalPlayer.Character
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
            task.wait(0.05) -- super cepet biar aura nendang semua
        end
    end)
    coroutine.resume(auraLoop)
end

-- ==================== AUTO ABANDON ====================
local function startAutoAbandon()
    if abandonLoop then return end
    abandonLoop = coroutine.create(function()
        while abandonEnabled do
            pcall(function()
                QuestAbandon:FireServer()
            end)
            task.wait(6) -- delay aman, ga spam
        end
    end)
    coroutine.resume(abandonLoop)
end

-- ==================== ESP ALL NPC ====================
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

                local myRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myPos = myRoot and myRoot.Position or Vector3.new(0,0,0)

                for _, npc in ipairs(npcFolder:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
                        local root = npc.HumanoidRootPart
                        local hum = npc.Humanoid

                        -- Buat ESP kalau belum ada
                        if not npc:FindFirstChild("ESP") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "ESP"
                            billboard.Adornee = root
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 220, 0, 60)
                            billboard.StudsOffset = Vector3.new(0, 4, 0)
                            billboard.Parent = npc

                            local text = Instance.new("TextLabel")
                            text.Name = "Text"
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.TextStrokeTransparency = 0
                            text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            text.TextColor3 = Color3.fromRGB(0, 255, 100)
                            text.TextScaled = true
                            text.Font = Enum.Font.SourceSansBold
                            text.TextXAlignment = Enum.TextXAlignment.Center
                            text.TextYAlignment = Enum.TextYAlignment.Center
                            text.Parent = billboard
                        end

                        -- Update teks
                        local levelVal = npc:FindFirstChild("Level") or (npc.Humanoid:FindFirstChild("Level"))
                        local npcLevel = levelVal and levelVal.Value or 1
                        local dist = (myPos - root.Position).Magnitude

                        npc.ESP.Text.Text = string.format(
                            "%s\nLv.%d  |  HP: %.0f/%.0f\n%.0f stud",
                            npc.Name,
                            npcLevel,
                            hum.Health,
                            hum.MaxHealth,
                            dist
                        )
                    end
                end
            end)
            task.wait(0.25)
        end
    end)
    coroutine.resume(espLoop)
end

-- ==================== AUTO FARM (tetap sama) ====================
MainTab:CreateToggle({
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
                        local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
                        local character = game.Players.LocalPlayer.Character
                        if backpack and character then
                            local tool = backpack:FindFirstChildOfClass("Tool")
                            if tool then
                                tool.Parent = character
                            end
                        end
                    end)

                    local myLevel = getMyLevel()
                    local npcs = {}
                    local npcFolder = workspace:FindFirstChild("NPCs")
                    if npcFolder then
                        for _, obj in ipairs(npcFolder:GetChildren()) do
                            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
                                local npcLevel = 1
                                local levelVal = obj:FindFirstChild("Level") or (obj.Humanoid:FindFirstChild("Level"))
                                if levelVal and (levelVal:IsA("IntValue") or levelVal:IsA("NumberValue")) then
                                    npcLevel = levelVal.Value
                                end
                                if npcLevel <= myLevel + 15 then
                                    table.insert(npcs, obj)
                                end
                            end
                        end
                    end

                    if #npcs > 0 then
                        local closest = nil
                        local minDist = math.huge
                        local myRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            for _, npc in ipairs(npcs) do
                                local dist = (myRoot.Position - npc.HumanoidRootPart.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    closest = npc
                                end
                            end
                        else
                            closest = npcs[1]
                        end

                        if closest then
                            while closest.Humanoid.Health > 0 and farmEnabled do
                                local char = game.Players.LocalPlayer.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    local root = char.HumanoidRootPart
                                    local offsetY = (flyPosition == "Above") and 20 or 3
                                    root.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, offsetY, 0)
                                end

                                fireAura(closest)
                                task.wait(0.03)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
            coroutine.resume(farmLoop)
        else
            farmEnabled = false
            godEnabled = false
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Fly Position",
    Options = {"Above", "Below"},
    CurrentOption = {"Above"},
    Flag = "FlyPosition",
    Callback = function(Value)
        flyPosition = Value[1]
    end,
})

-- ==================== KILL AURA + RADIUS (baru) ====================
MainTab:CreateToggle({
    Name = "Kill Aura (Radius)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        killAuraEnabled = Value
        if killAuraEnabled then
            startKillAura()
        else
            killAuraEnabled = false
        end
    end,
})

MainTab:CreateSlider({
    Name = "Kill Aura Radius",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = 50,
    Flag = "AuraRadius",
    Callback = function(Value)
        killAuraRadius = Value
    end,
})

-- ==================== QUEST + ABANDON (baru) ====================
MainTab:CreateDropdown({
    Name = "Select Quest NPC",
    Options = {"QuestNPC1", "QuestNPC2", "QuestNPC3", "QuestNPC4", "QuestNPC5"},
    CurrentOption = {"QuestNPC1"},
    Flag = "SelectQuestNPC",
    Callback = function(Value)
        selectedQuest = Value[1]
    end,
})

MainTab:CreateToggle({
    Name = "Get Quest (Auto Accept)",
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
                        task.wait(0.5)
                        QuestAccept:FireServer(selectedQuest)
                    end)
                    task.wait(8)
                end
            end)
            coroutine.resume(questLoop)
        else
            autoGetQuestEnabled = false
        end
    end,
})

-- Fitur Abandon terpisah (baru)
MainTab:CreateToggle({
    Name = "Auto Abandon Quest",
    CurrentValue = false,
    Flag = "AutoAbandon",
    Callback = function(Value)
        abandonEnabled = Value
        if abandonEnabled then
            startAutoAbandon()
        else
            abandonEnabled = false
        end
    end,
})

MainTab:CreateButton({
    Name = "Manual Abandon Quest (Sekali Klik)",
    Callback = function()
        pcall(function()
            QuestAbandon:FireServer()
        end)
        Rayfield:Notify({
            Title = "HamzBeta",
            Content = "Quest berhasil di-abandon!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- ==================== MISC ====================
local antiAFKEnabled = false
local antiAFKLoop = nil

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        antiAFKEnabled = Value
        if antiAFKEnabled then
            antiAFKLoop = coroutine.create(function()
                while antiAFKEnabled do
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new(0, 0))
                    end)
                    task.wait(30)
                end
            end)
            coroutine.resume(antiAFKLoop)
        else
            antiAFKEnabled = false
        end
    end,
})

MiscTab:CreateToggle({
    Name = "ESP All NPCs (Nama + Level + HP + Jarak)",
    CurrentValue = false,
    Flag = "ESPNPC",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            startESP()
        else
            cleanupESP()
            espEnabled = false
        end
    end,
})

print("HamzBeta Rayfield UI berhasil dimuat! ✅")
print("✅ Auto Farm + Fly Position")
print("✅ Kill Aura + Radius (baru)")
print("✅ Auto Abandon Quest + Manual Abandon Button (baru)")
print("✅ ESP All NPCs (nama, level, HP, jarak) (baru)")
print("Coba nyalain semua sekaligus: Auto Farm + Kill Aura + ESP + Auto Abandon. Mulus banget bro 🔥")
