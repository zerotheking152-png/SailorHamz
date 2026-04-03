-- HamzBeta by Grok (for Sailor Piece) - UPDATED
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HamzBeta"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame (diperbesar biar muat 2 tombol)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 280, 0, 280)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Corner
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "HamzBeta"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Toggle Aura Kill
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 60)
toggleBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
toggleBtn.Text = "Aura Kill: OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

-- Auto Farm NPC Button
local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(0.8, 0, 0, 60)
farmBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
farmBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
farmBtn.Text = "Auto Farm NPC: OFF"
farmBtn.TextColor3 = Color3.new(1,1,1)
farmBtn.TextScaled = true
farmBtn.Font = Enum.Font.GothamSemibold
farmBtn.Parent = mainFrame

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 10)
farmCorner.Parent = farmBtn

-- Variables
local enabled = false
local auraLoop = nil
local farmEnabled = false
local farmLoop = nil

-- Draggable (diperbaiki biar lebih smooth)
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle Aura Kill (SEKARANG LEBIH CEPAT)
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        toggleBtn.Text = "Aura Kill: ON"
        
        auraLoop = coroutine.create(function()
            while enabled and task.wait() do
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
                task.wait(0.01) -- <<<< CEPET BANGET BRO
            end
        end)
        coroutine.resume(auraLoop)
        
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        toggleBtn.Text = "Aura Kill: OFF"
        enabled = false
    end
end)

-- Auto Farm NPC Logic
farmBtn.MouseButton1Click:Connect(function()
    farmEnabled = not farmEnabled
    
    if farmEnabled then
        farmBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        farmBtn.Text = "Auto Farm NPC: ON"
        
        farmLoop = coroutine.create(function()
            while farmEnabled do
                -- Cari semua NPC yang hidup (bukan player)
                local npcs = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") 
                        and obj:FindFirstChild("Humanoid") 
                        and obj.Humanoid.Health > 0 
                        and obj:FindFirstChild("HumanoidRootPart") then
                        
                        local isPlayerChar = false
                        for _, plr in ipairs(game.Players:GetPlayers()) do
                            if plr.Character == obj then
                                isPlayerChar = true
                                break
                            end
                        end
                        if not isPlayerChar then
                            table.insert(npcs, obj)
                        end
                    end
                end
                
                if #npcs > 0 then
                    -- Ambil NPC terdekat
                    local closest = nil
                    local minDist = math.huge
                    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    
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
                            local char = player.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local root = char.HumanoidRootPart
                                -- Teleport ke atas NPC
                                root.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
                            end
                            task.wait(0.05)
                        end
                    end
                end
                
                task.wait(0.5) -- refresh list NPC
            end
        end)
        coroutine.resume(farmLoop)
        
    else
        farmBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        farmBtn.Text = "Auto Farm NPC: OFF"
        farmEnabled = false
    end
end)

print("✅ HamzBeta UPDATED loaded! Aura Kill lebih kenceng + Auto Farm NPC siap. Nyalain keduanya biar auto farm jalan.")
