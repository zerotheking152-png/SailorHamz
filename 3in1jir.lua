-- ✅ HamzBeta by Grok - Rayfield UI TERBARU (2026)
-- Loading screen + Tab "Main" + Aura Kill + Auto Farm NPC (sesuai level)

print("🚀 HamzBeta mulai loading Rayfield UI...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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

local MainTab = Window:CreateTab("Main", 0x00FF64) -- Warna hijau neon

-- =============================================
-- VARIABEL & FUNGSI (sama seperti sebelumnya)
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
                    task.wait(0.01) -- SUPER CEPET
                end
            end)
            coroutine.resume(auraLoop)
        else
            enabled = false
        end
    end,
})

-- =============================================
-- AUTO FARM NPC TOGGLE (hanya NPC yang bisa di-hit + sesuai level)
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
                    
                    -- Hanya ambil dari folder NPCs (yang bener-bener mob)
                    local npcFolder = workspace:FindFirstChild("NPCs")
                    if npcFolder then
                        for _, obj in ipairs(npcFolder:GetChildren()) do
                            if obj:IsA("Model") 
                                and obj:FindFirstChild("Humanoid") 
                                and obj.Humanoid.Health > 0 
                                and obj:FindFirstChild("HumanoidRootPart") then
                                
                                -- Filter level (max +15 di atas level lu)
                                local npcLevel = 1
                                local levelVal = obj:FindFirstChild("Level") 
                                               or (obj.Humanoid:FindFirstChild("Level"))
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
                        -- Cari NPC terdekat
                        local closest = nil
                        local minDist = math.huge
                        local myRoot = game.Players.LocalPlayer.Character 
                                      and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
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
                        
                        -- Farm sampai mati
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
                    
                    task.wait(0.5) -- refresh setiap 0.5 detik
                end
            end)
            coroutine.resume(farmLoop)
            
        else
            farmEnabled = false
        end
    end,
})

-- Notification akhir
Rayfield:Notify({
    Title = "✅ HamzBeta Loaded!",
    Content = "Rayfield UI siap! Nyalain Aura Kill dulu baru Auto Farm NPC biar jalan bareng.",
    Duration = 6,
})

print("✅ HamzBeta Rayfield UI berhasil dimuat! Loading screen + Tab Main udah ada.")
