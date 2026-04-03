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

local farmEnabled = false
local farmLoop = nil

local autoGetQuestEnabled = false
local questLoop = nil
local selectedQuest = "GetQuest1"

local function getMyLevel()
    local leaderstats = game.Players.LocalPlayer:WaitForChild("leaderstats", 5)
    if leaderstats and leaderstats:FindFirstChild("Level") then
        return leaderstats.Level.Value
    end
    return 1
end

local function fireAura(target)
    local combat = game:GetService("ReplicatedStorage"):WaitForChild("CombatSystem", 5)
    if combat then
        local remotes = combat:WaitForChild("Remotes", 5)
        if remotes then
            local requestHit = remotes:FindFirstChild("RequestHit")
            if requestHit and target then
                requestHit:FireServer(target)  -- sekarang kirim target NPC biar server nerima damage
            end
        end
    end
end

MainTab:CreateToggle({
    Name = "Auto Farm NPC",
    CurrentValue = false,
    Flag = "AutoFarmNPC",
    Callback = function(Value)
        farmEnabled = Value
        
        if farmEnabled then
            farmLoop = coroutine.create(function()
                while farmEnabled do
                    -- Auto equip weapon (biar bisa ngehit)
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
                                    root.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)  -- lebih deket lagi (Y=2)
                                end

                                -- God mode
                                pcall(function()
                                    local hum = char and char:FindFirstChild("Humanoid")
                                    if hum then
                                        hum.MaxHealth = 9e9
                                        hum.Health = 9e9
                                    end
                                end)

                                -- FIRE AURA DENGAN TARGET (ini yang bikin damage nyala)
                                fireAura(closest)

                                task.wait(0.03)  -- cepet tapi stabil
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
            coroutine.resume(farmLoop)
        else
            farmEnabled = false
        end
    end,
})

-- Fitur Get Quest (tetap seperti sebelumnya)
MainTab:CreateDropdown({
    Name = "Select Option",
    Options = {"GetQuest1"},
    CurrentOption = {"GetQuest1"},
    Flag = "SelectGetQuest",
    Callback = function(Value)
        selectedQuest = Value[1]
    end,
})

MainTab:CreateToggle({
    Name = "Get Quest",
    CurrentValue = false,
    Flag = "GetQuest",
    Callback = function(Value)
        autoGetQuestEnabled = Value
        if autoGetQuestEnabled then
            questLoop = coroutine.create(function()
                while autoGetQuestEnabled do
                    pcall(function()
                        local args = {
                            selectedQuest
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("QuestAccept"):FireServer(unpack(args))
                    end)
                    task.wait(2)
                end
            end)
            coroutine.resume(questLoop)
        else
            autoGetQuestEnabled = false
        end
    end,
})

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

Rayfield:Notify({
    Title = "HamzBeta Loaded! (2026 Update)",
    Content = "Rayfield UI siap bro!\nAuto Farm NPC sekarang udah di-fix total:\n• RequestHit kirim target NPC (damage pasti nyala)\n• Teleport lebih deket (Y=2)\n• Auto equip weapon\n• Aura + farm digabung jadi 1 loop\nGet Quest & Anti AFK tetap ada.\nNyalain Auto Farm aja, NPC bakal mati brutal sekarang.",
    Duration = 8,
})

print("HamzBeta Rayfield UI berhasil dimuat! Auto Farm udah di-fix (RequestHit pake target + equip weapon + teleport deket).")
