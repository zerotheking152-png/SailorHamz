-- ✅ HamzBeta by Grok - Rayfield UI TERBARU & STABIL (FIXED 2026)
-- Pakai link GitHub resmi (shlexware) biar ga down lagi
-- + Debug print + Loading screen persis sesuai request lu

print("🚀 HamzBeta mulai loading Rayfield UI... (debug 1)")

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

print("✅ Rayfield berhasil di-load! (debug 2)")

local Window = Rayfield:CreateWindow({
    Name = "HamzBeta",
    LoadingTitle = "HamzBeta Is loading",
    LoadingSubtitle = "tunggu sebentar yaaaa😘",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
})

print("✅ Window Rayfield dibuat! (debug 3)")

local MainTab = Window:CreateTab("Main", 0x00FF64) -- Warna hijau neon

-- =============================================
-- VARIABEL & FUNGSI
-- =============================================
local enabled = false
local auraLoop = nil

local farmEnabled = false
local farmLoop = nil

local function getMyLevel()
    local leaderstats = game.Players.LocalPlayer:WaitForChild("leaderstats", 5)
    if leaderstats and leaderstats:FindFirstChild("Level") then
        return leaderstats.Level.Value
    end
    return 1
end

-- =============================================
-- AURA KILL TOGGLE
-- =============================================
MainTab:CreateToggle({
    Name = "🔥 Aura Kill",
    CurrentValue = false,
    Flag = "AuraKill",
    Callback = function(Value)
        enabled = Value
        
        if enabled then
            auraLoop = coroutine.create(function()
                while enabled do
                    local combat = game:GetService("ReplicatedStorage"):WaitForChild("CombatSystem", 5)
                    if combat then
                        local remotes = combat:WaitForChild("Remotes", 5)
                        if remotes then
                            local requestHit = remotes:FindFirstChild("RequestHit")
                            if requestHit then
                                requestHit:FireServer()
                            end
                        end
                    end
                    task.wait(0.01)
                end
            end)
            coroutine.resume(auraLoop)
        else
            enabled = false
        end
    end,
})

-- =============================================
-- AUTO FARM NPC TOGGLE (hanya NPCs folder + level filter)
-- =============================================
MainTab:CreateToggle({
    Name = "🌾 Auto Farm NPC",
    CurrentValue = false,
    Flag = "AutoFarmNPC",
    Callback = function(Value)
        farmEnabled = Value
        
        if farmEnabled then
            farmLoop = coroutine.create(function()
                while farmEnabled do
                    local myLevel = getMyLevel()
                    local npcs = {}
                    
                    local npcFolder = workspace:FindFirstChild("NPCs")
                    if npcFolder then
                        for _, obj in ipairs(npcFolder:GetChildren()) do
                            if obj:IsA("Model") 
                                and obj:FindFirstChild("Humanoid") 
                                and obj.Humanoid.Health > 0 
                                and obj:FindFirstChild("HumanoidRootPart") then
                                
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
                                    root.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
                                end
                                task.wait(0.05)
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

-- Notification
Rayfield:Notify({
    Title = "✅ HamzBeta Loaded!",
    Content = "Rayfield UI siap bro! Cek tab Main → nyalain Aura Kill dulu baru Auto Farm NPC.",
    Duration = 6,
})

print("✅ HamzBeta Rayfield UI FULLY LOADED! (debug 4)")
print("   → Buka GUI dengan tombol RightShift kalau ga langsung keliatan")
