-- =============================================
-- HamzSailorBetaTester DEWA FINAL
-- FULL PREMIUM UI v2.0 (Polished + All Upgrades Applied)
-- =============================================

repeat task.wait() until game:IsLoaded()

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Cleanup old UI
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("HamzSailorBetaTester") or player.PlayerGui:FindFirstChild("HamzSailorBetaTester")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "HamzSailorBetaTester"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- ==================== MAIN FRAME ====================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 380)
main.Position = UDim2.new(0.5, -300, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- ==================== BLUR EFFECT (Premium Feel) ====================
local blur = Lighting:FindFirstChild("HamzBlur") or Instance.new("BlurEffect")
blur.Name = "HamzBlur"
blur.Size = 12
blur.Parent = Lighting

-- ==================== SIDEBAR KIRI ====================
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

local sidebarTitle = Instance.new("TextLabel", sidebar)
sidebarTitle.Size = UDim2.new(1, 0, 0, 50)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "   DEWA FINAL"
sidebarTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextSize = 18
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ==================== CONTENT AREA ====================
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -170, 1, -20)
content.Position = UDim2.new(0, 170, 0, 10)
content.BackgroundTransparency = 1

local pages = Instance.new("Frame", content)
pages.Size = UDim2.new(1, 0, 1, 0)
pages.BackgroundTransparency = 1

local currentPage = nil

-- ==================== CREATE PAGE (with padding + title) ====================
local function createPage(name)
    local page = Instance.new("Frame", pages)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Position = UDim2.new(0, 50, 0, 0)  -- untuk animasi

    -- Padding
    local padding = Instance.new("UIPadding", page)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 10)

    -- UIListLayout
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    return page
end

local function createPageTitle(page, text)
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Text = text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = -1
end

-- ==================== MODERN SIDEBAR BUTTON (Fixed + Smooth Hover + Active) ====================
local sideY = 65  -- manual positioning (fix bug GetChildren)

local function createSideButton(name, color, page)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, sideY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = "   " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    -- Active highlight bar
    local highlight = Instance.new("Frame", btn)
    highlight.Size = UDim2.new(0, 4, 1, 0)
    highlight.Position = UDim2.new(0, 0, 0, 0)
    highlight.BackgroundColor3 = color or Color3.fromRGB(0, 170, 255)
    highlight.BorderSizePixel = 0
    highlight.BackgroundTransparency = 1  -- default non-active

    sideY += 55

    -- Hover animation
    btn.MouseEnter:Connect(function()
        if btn \~= currentPage then
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if btn \~= currentPage then
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end
    end)

    -- Click
    btn.MouseButton1Click:Connect(function()
        if currentPage == page then return end

        -- Hide old page with animation
        if currentPage then
            TweenService:Create(currentPage, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 50, 0, 0)
            }):Play()
            task.wait(0.15)
            currentPage.Visible = false
        end

        -- Show new page with animation
        page.Position = UDim2.new(0, 50, 0, 0)
        page.Visible = true
        TweenService:Create(page, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        currentPage = page

        -- Reset all buttons
        for _, b in ipairs(sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                local hl = b:FindFirstChildWhichIsA("Frame")
                if hl then hl.BackgroundTransparency = 1 end
            end
        end

        -- Active style
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        highlight.BackgroundTransparency = 0
    end)

    return btn
end

-- ==================== MODERN SWITCH ====================
local function createSwitch(parent, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleFrame = Instance.new("Frame", frame)
    toggleFrame.Size = UDim2.new(0, 52, 0, 28)
    toggleFrame.Position = UDim2.new(1, -70, 0.5, -14)
    toggleFrame.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", toggleFrame)
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = default and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = default

    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
            }):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
            }):Play()
            callback(state)
        end
    end)
end

-- ==================== CREATE PAGES & TITLES ====================
local FarmPage   = createPage("Farm")
local CombatPage = createPage("Combat")
local QuestPage  = createPage("Quest")
local VisualPage = createPage("Visual")
local MiscPage   = createPage("Misc")

createPageTitle(FarmPage,   "Farming")
createPageTitle(CombatPage, "Combat")
createPageTitle(QuestPage,  "Quest")
createPageTitle(VisualPage, "Visual")
createPageTitle(MiscPage,   "Miscellaneous")

-- Default page
FarmPage.Visible = true
currentPage = FarmPage

-- ==================== SIDEBAR BUTTONS ====================
createSideButton("Farm",   Color3.fromRGB(0, 255, 100),   FarmPage)
createSideButton("Combat", Color3.fromRGB(255, 0, 0),     CombatPage)
createSideButton("Quest",  Color3.fromRGB(255, 255, 0),   QuestPage)
createSideButton("Visual", Color3.fromRGB(0, 255, 255),   VisualPage)
createSideButton("Misc",   Color3.fromRGB(255, 255, 255), MiscPage)

-- ==================== PAGE CONTENT (Switches + Upgraded Quest Buttons) ====================
createSwitch(FarmPage,   "Auto Farm DEWA FINAL", false, function(v) end)
createSwitch(CombatPage, "Kill Aura", false, function(v) end)
createSwitch(CombatPage, "God Mode", false, function(v) end)

-- Quest Page - Upgraded Buttons
local questList = {"QuestNPC1","QuestNPC2","QuestNPC3","QuestNPC4","QuestNPC5"}
for _, name in ipairs(questList) do
    local qBtn = Instance.new("TextButton", QuestPage)
    qBtn.Size = UDim2.new(1, 0, 0, 45)
    qBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    qBtn.Text = "   " .. name
    qBtn.TextXAlignment = Enum.TextXAlignment.Left
    qBtn.Font = Enum.Font.Gotham
    qBtn.TextSize = 15
    Instance.new("UICorner", qBtn).CornerRadius = UDim.new(0, 8)

    -- Hover animation
    qBtn.MouseEnter:Connect(function()
        TweenService:Create(qBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)
    qBtn.MouseLeave:Connect(function()
        TweenService:Create(qBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        }):Play()
    end)
end

createSwitch(QuestPage, "Auto Get Quest + Turn In", false, function(v) end)

-- ==================== DRAG + MINIMIZE + KEYBIND ====================
local dragging = false
local dragInput, dragStart, startPos

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 10

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

topBar.InputEnded:Connect(function() dragging = false end)

-- Minimize button
local minimizeBtn = Instance.new("TextButton", main)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 22
minimizeBtn.ZIndex = 10

local minimized = false
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 160, 0, 45)
openBtn.Position = UDim2.new(0, 20, 0, 20)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
openBtn.Text = "OPEN DEWA UI"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 15
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)
openBtn.Visible = false

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Visible = not minimized
    openBtn.Visible = minimized
end)

openBtn.MouseButton1Click:Connect(function()
    minimized = false
    main.Visible = true
    openBtn.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
        openBtn.Visible = not main.Visible
    end
end)

print("✅ HamzSailorBetaTester UI v2.0 PREMIUM Loaded! (10/10 polished)")
