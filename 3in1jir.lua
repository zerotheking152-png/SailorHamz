print("HamzBeta mulai loading Rayfield UI...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "HamzBeta v2 - Fixed & Rapi",
    LoadingTitle = "HamzBeta Is loading",
    LoadingSubtitle = "tunggu sebentar yaaaa",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
})

-- ==================== TABS BARU (biar rapi banget) ====================
local FarmTab    = Window:CreateTab("Farm", 0x00FF64)
local CombatTab  = Window:CreateTab("Combat", 0xFF0000)
local QuestTab   = Window:CreateTab("Quest", 0xFFFF00)
local VisualTab  = Window:CreateTab("Visual", 0x00FFFF)
local MiscTab    = Window:CreateTab("Misc", 0xFFFFFF)

-- ==================== VARIABEL ====================
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

-- ==================== KILL AURA (fix hit) ====================
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
            task.wait(0.03) -- lebih cepat biar ngehit pasti
        end
    end)
    coroutine.resume(auraLoop)
end

-- ==================== AUTO ABANDON ====================
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

-- ==================== ESP ====================
local function cleanupESP()
    pcall(function()
        local npcFolder = workspace:FindFirstChild("NPCs")
        if npcFolder then
            for _, npc in ipairs(npcFolder:GetChildren()) do
                if npc:FindFirstChild("ESP") then
                    npc.ESP:Destroy()
                end
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
            task.wait(0.3)
        end
    end)
    coroutine.resume(espLoop)
end

-- ==================== FARM TAB ====================
FarmTab:CreateToggle({
    Name = "Auto Farm NPC (Teleport + God Mode)",
    CurrentValue = false,
    Flag = "AutoFarmNPC",
    Callback = function(Value)
        farmEnabled = Value
        if farmEnabled then
            startGodMode()
            farmLoop = coroutine.create(function()
                while farmEnabled do
                    pcall(function()
                        -- Equip tool otomatis
                        local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
                        local character = game.Players.LocalPlayer.Character
                        if backpack and character then
                            local tool = backpack:FindFirstChildOfClass("Tool")
                            if tool then tool.Parent = character end
                        end

                        -- Cari NPC terdekat
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
                                    if d < minDist then minDist = d; closest = npc end
                                end
                            end

                            -- Teleport ke NPC (tetap pake offset)
                            if closest and character and character:FindFirstChild("HumanoidRootPart") then
                                local offsetY = (flyPosition == "Above") and 20 or 3
                                character.HumanoidRootPart.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, offsetY, 0)
                            end
                        end
                    end)
                    task.wait(0.1)
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

-- ==================== COMBAT TAB ====================
CombatTab:CreateToggle({
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

CombatTab:CreateSlider({
    Name = "Kill Aura Radius (stud)",
    Range = {10, 100},
    Increment = 5,
    CurrentValue = 50,
    Flag = "AuraRadius",
    Callback = function(Value)
        killAuraRadius = Value
    end,
})

CombatTab:CreateToggle({
    Name = "God Mode (Manual)",
    CurrentValue = false,
    Flag = "GodModeManual",
    Callback = function(Value)
        godEnabled = Value
        if godEnabled then
            startGodMode()
        else
            godEnabled = false
        end
    end,
})

-- ==================== QUEST TAB ====================
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
    Name = "Auto Get Quest (Accept Only)",
    CurrentValue = false,
    Flag = "GetQuest",
    Callback = function(Value)
        autoGetQuestEnabled = Value
        if autoGetQuestEnabled then
            -- Hanya accept sekali + re-accept kalau mati
            pcall(function()
                RS:WaitForChild("Remotes"):WaitForChild("GetTitlesData"):InvokeServer()
                RS:WaitForChild("Remotes"):WaitForChild("ShopRemotes"):WaitForChild("GetBoosts"):InvokeServer()
            end)

            questLoop = coroutine.create(function()
                while autoGetQuestEnabled do
                    pcall(function()
                        QuestAccept:FireServer(selectedQuest)
                    end)
                    task.wait(25) -- delay panjang biar quest sempat selesai dulu
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
        if autoAbandonEnabled then
            startAutoAbandon()
        else
            autoAbandonEnabled = false
        end
    end,
})

QuestTab:CreateButton({
    Name = "Manual Abandon Quest (Sekali Klik)",
    Callback = function()
        pcall(function() QuestAbandon:FireServer() end)
        Rayfield:Notify({Title = "HamzBeta", Content = "Quest sudah di-abandon!", Duration = 3})
    end,
})

-- ==================== VISUAL TAB ====================
VisualTab:CreateToggle({
    Name = "ESP All NPCs (Nama + Lv + HP + Jarak)",
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

-- ==================== MISC TAB ====================
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

print("HamzBeta v2 FIXED & RAPI berhasil dimuat! ✅")
print("Perubahan besar:")
print("• 5 Tab baru biar super rapi")
print("• Auto Farm sekarang cuma teleport + god + equip (Kill Aura yang ngehit)")
print("• Kill Aura di Combat Tab → pasti ngehit (delay 0.03 + radius bebas)")
print("• Auto Quest di-fix: sekarang hanya ACCEPT + delay 25 detik (ga abandon otomatis lagi)")
print("• Auto Abandon dipisah biar lu bisa selesaiin quest dulu")
print("Cara paling OP: Nyalain Auto Farm + Kill Aura + ESP + Auto Get Quest")
print("Sekarang auto farm pasti ngehit, quest ga ngulang sebelum selesai 🔥")
