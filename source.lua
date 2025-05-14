--[[
    RedGlow UI Library
    A sleek, modern UI library for Roblox with smooth animations and red glowing accents
    
    Features:
    - Smooth grey UI with red glowing edges
    - Animated UI elements with sound effects
    - Comprehensive set of UI components
    - Easy to use API
    
    Author: v0
]]

local RedGlowUI = {}
RedGlowUI.__index = RedGlowUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Constants
local TWEEN_TIME = 0.3
local EASING_STYLE = Enum.EasingStyle.Quart
local EASING_DIRECTION = Enum.EasingDirection.Out

-- Colors
local COLORS = {
    Background = Color3.fromRGB(40, 40, 40),
    DarkBackground = Color3.fromRGB(30, 30, 30),
    LightBackground = Color3.fromRGB(50, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(255, 50, 50),
    AccentDark = Color3.fromRGB(200, 40, 40),
    Glow = Color3.fromRGB(255, 0, 0),
    Success = Color3.fromRGB(50, 200, 50),
    Warning = Color3.fromRGB(255, 200, 50),
    Error = Color3.fromRGB(255, 50, 50),
    Highlight = Color3.fromRGB(60, 60, 60),
    Shadow = Color3.fromRGB(20, 20, 20)
}

-- Sounds
local SOUNDS = {
    Click = "rbxassetid://6895079853",
    Hover = "rbxassetid://6895079733",
    Toggle = "rbxassetid://6895079773",
    Notification = "rbxassetid://6895079813",
    Slider = "rbxassetid://6895079893"
}

-- Utility Functions
local function createTween(instance, properties, time, style, direction)
    time = time or TWEEN_TIME
    style = style or EASING_STYLE
    direction = direction or EASING_DIRECTION
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(time, style, direction),
        properties
    )
    
    return tween
end

local function playSound(soundId, volume)
    volume = volume or 0.5
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = workspace
    
    sound:Play()
    
    game:GetService("Debris"):AddItem(sound, sound.TimeLength + 0.1)
end

local function createShadow(parent, size, position, radius)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.SliceScale = 1
    shadow.Size = size or UDim2.new(1, 10, 1, 10)
    shadow.Position = position or UDim2.new(0, -5, 0, -5)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    
    return shadow
end

local function createGlow(parent, size, position, radius)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5554236805"
    glow.ImageColor3 = COLORS.Glow
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(23, 23, 277, 277)
    glow.SliceScale = 1
    glow.Size = size or UDim2.new(1, 20, 1, 20)
    glow.Position = position or UDim2.new(0, -10, 0, -10)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    
    -- Add animation
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(glow, tweenInfo, {ImageTransparency = 0.7})
    tween:Play()
    
    return glow
end

local function createRipple(parent)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = parent.ZIndex + 1
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    ripple.Parent = parent
    
    local targetSize = UDim2.new(0, parent.AbsoluteSize.X * 1.5, 0, parent.AbsoluteSize.X * 1.5)
    local tween = createTween(ripple, {Size = targetSize, BackgroundTransparency = 1}, 0.5)
    tween:Play()
    
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Main UI Creation
function RedGlowUI.new(title, draggable)
    local self = setmetatable({}, RedGlowUI)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "RedGlowUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Set parent based on environment
    if RunService:IsStudio() then
        self.ScreenGui.Parent = LocalPlayer.PlayerGui
    else
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Create main frame
    self.Main = Instance.new("Frame")
    self.Main.Name = "Main"
    self.Main.BackgroundColor3 = COLORS.Background
    self.Main.BorderSizePixel = 0
    self.Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.Main.Size = UDim2.new(0, 500, 0, 350)
    self.Main.ZIndex = 2
    self.Main.ClipsDescendants = true
    self.Main.Parent = self.ScreenGui
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Main
    
    -- Add shadow
    createShadow(self.Main)
    
    -- Add glow
    self.Glow = createGlow(self.Main)
    
    -- Create title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.BackgroundColor3 = COLORS.DarkBackground
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.ZIndex = 3
    self.TitleBar.Parent = self.Main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar
    
    -- Fix corner overlap
    local titleFix = Instance.new("Frame")
    titleFix.Name = "Fix"
    titleFix.BackgroundColor3 = COLORS.DarkBackground
    titleFix.BorderSizePixel = 0
    titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleFix.ZIndex = 3
    titleFix.Parent = self.TitleBar
    
    -- Create title
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.BackgroundTransparency = 1
    self.Title.Position = UDim2.new(0, 15, 0, 0)
    self.Title.Size = UDim2.new(1, -40, 1, 0)
    self.Title.ZIndex = 4
    self.Title.Font = Enum.Font.GothamSemibold
    self.Title.Text = title or "RedGlow UI"
    self.Title.TextColor3 = COLORS.Text
    self.Title.TextSize = 16
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Parent = self.TitleBar
    
    -- Create close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Position = UDim2.new(1, -40, 0, 0)
    self.CloseButton.Size = UDim2.new(0, 40, 1, 0)
    self.CloseButton.ZIndex = 4
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = COLORS.TextDark
    self.CloseButton.TextSize = 24
    self.CloseButton.Parent = self.TitleBar
    
    -- Close button hover effect
    self.CloseButton.MouseEnter:Connect(function()
        createTween(self.CloseButton, {TextColor3 = COLORS.Accent}):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        createTween(self.CloseButton, {TextColor3 = COLORS.TextDark}):Play()
    end)
    
    -- Close button click
    self.CloseButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createTween(self.Main, {Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 0), Position = UDim2.new(self.Main.Position.X.Scale, self.Main.Position.X.Offset, self.Main.Position.Y.Scale, self.Main.Position.Y.Offset + self.Main.AbsoluteSize.Y/2)}, 0.5):Play()
        createTween(self.Main, {BackgroundTransparency = 1}, 0.5):Play()
        createTween(self.TitleBar, {BackgroundTransparency = 1}, 0.5):Play()
        createTween(self.Title, {TextTransparency = 1}, 0.5):Play()
        createTween(self.CloseButton, {TextTransparency = 1}, 0.5):Play()
        createTween(self.Glow, {ImageTransparency = 1}, 0.5):Play()
        
        wait(0.5)
        self.ScreenGui:Destroy()
    end)
    
    -- Create content frame
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.BackgroundTransparency = 1
    self.Content.Position = UDim2.new(0, 0, 0, 40)
    self.Content.Size = UDim2.new(1, 0, 1, -40)
    self.Content.ZIndex = 3
    self.Content.Parent = self.Main
    
    -- Create tab system
    self.TabButtons = Instance.new("Frame")
    self.TabButtons.Name = "TabButtons"
    self.TabButtons.BackgroundColor3 = COLORS.DarkBackground
    self.TabButtons.BorderSizePixel = 0
    self.TabButtons.Position = UDim2.new(0, 0, 0, 0)
    self.TabButtons.Size = UDim2.new(0, 120, 1, 0)
    self.TabButtons.ZIndex = 3
    self.TabButtons.Parent = self.Content
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = self.TabButtons
    
    -- Fix corner overlap
    local tabFix = Instance.new("Frame")
    tabFix.Name = "Fix"
    tabFix.BackgroundColor3 = COLORS.DarkBackground
    tabFix.BorderSizePixel = 0
    tabFix.Position = UDim2.new(0.5, 0, 0, 0)
    tabFix.Size = UDim2.new(0.5, 0, 1, 0)
    tabFix.ZIndex = 3
    tabFix.Parent = self.TabButtons
    
    -- Create tab button list
    self.TabButtonList = Instance.new("ScrollingFrame")
    self.TabButtonList.Name = "TabButtonList"
    self.TabButtonList.BackgroundTransparency = 1
    self.TabButtonList.Position = UDim2.new(0, 0, 0, 10)
    self.TabButtonList.Size = UDim2.new(1, 0, 1, -10)
    self.TabButtonList.ZIndex = 4
    self.TabButtonList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabButtonList.ScrollBarThickness = 2
    self.TabButtonList.ScrollBarImageColor3 = COLORS.Accent
    self.TabButtonList.BorderSizePixel = 0
    self.TabButtonList.Parent = self.TabButtons
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.Parent = self.TabButtonList
    
    -- Create tab content frame
    self.TabContent = Instance.new("Frame")
    self.TabContent.Name = "TabContent"
    self.TabContent.BackgroundTransparency = 1
    self.TabContent.Position = UDim2.new(0, 130, 0, 10)
    self.TabContent.Size = UDim2.new(1, -140, 1, -20)
    self.TabContent.ZIndex = 3
    self.TabContent.Parent = self.Content
    
    -- Make UI draggable if specified
    if draggable ~= false then
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        
        self.TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = self.Main.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        self.TitleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    
    -- Initialize tabs
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Play open animation
    self.Main.Size = UDim2.new(0, 500, 0, 0)
    self.Main.Position = UDim2.new(0.5, -250, 0.5, 0)
    createTween(self.Main, {Size = UDim2.new(0, 500, 0, 350), Position = UDim2.new(0.5, -250, 0.5, -175)}, 0.5):Play()
    
    return self
end

-- Create a new tab
function RedGlowUI:AddTab(name, icon)
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Button"
    tabButton.BackgroundColor3 = COLORS.Background
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.ZIndex = 4
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = name
    tabButton.TextColor3 = COLORS.TextDark
    tabButton.TextSize = 14
    tabButton.Parent = self.TabButtonList
    
    -- Create tab indicator
    local tabIndicator = Instance.new("Frame")
    tabIndicator.Name = "Indicator"
    tabIndicator.BackgroundColor3 = COLORS.Accent
    tabIndicator.BorderSizePixel = 0
    tabIndicator.Position = UDim2.new(0, 0, 0.5, -1)
    tabIndicator.Size = UDim2.new(0, 2, 0, 0)
    tabIndicator.ZIndex = 5
    tabIndicator.Parent = tabButton
    
    -- Create tab content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.ZIndex = 3
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.ScrollBarThickness = 2
    tabContent.ScrollBarImageColor3 = COLORS.Accent
    tabContent.Visible = false
    tabContent.Parent = self.TabContent
    
    -- Add padding
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = tabContent
    
    -- Add list layout
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent
    
    -- Auto-size canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab button hover effect
    tabButton.MouseEnter:Connect(function()
        if self.ActiveTab ~= name then
            createTween(tabButton, {TextColor3 = COLORS.Text}):Play()
            createTween(tabIndicator, {Size = UDim2.new(0, 2, 0, 10)}):Play()
            playSound(SOUNDS.Hover, 0.2)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            createTween(tabButton, {TextColor3 = COLORS.TextDark}):Play()
            createTween(tabIndicator, {Size = UDim2.new(0, 2, 0, 0)}):Play()
        end
    end)
    
    -- Tab button click
    tabButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        self:SelectTab(name)
    end)
    
    -- Add tab to tabs table
    self.Tabs[name] = {
        Button = tabButton,
        Content = tabContent,
        Indicator = tabIndicator
    }
    
    -- Select this tab if it's the first one
    if not self.ActiveTab then
        self:SelectTab(name)
    end
    
    -- Return tab content for chaining
    return {
        Tab = self.Tabs[name],
        
        -- Add section to tab
        AddSection = function(_, title)
            return self:AddSection(name, title)
        end
    }
end

-- Select a tab
function RedGlowUI:SelectTab(name)
    -- Deselect current tab
    if self.ActiveTab then
        local currentTab = self.Tabs[self.ActiveTab]
        createTween(currentTab.Button, {TextColor3 = COLORS.TextDark}):Play()
        createTween(currentTab.Indicator, {Size = UDim2.new(0, 2, 0, 0)}):Play()
        currentTab.Content.Visible = false
    end
    
    -- Select new tab
    local newTab = self.Tabs[name]
    createTween(newTab.Button, {TextColor3 = COLORS.Accent}):Play()
    createTween(newTab.Indicator, {Size = UDim2.new(0, 2, 0, 20)}):Play()
    newTab.Content.Visible = true
    
    -- Set active tab
    self.ActiveTab = name
end

-- Add a section to a tab
function RedGlowUI:AddSection(tabName, title)
    local tab = self.Tabs[tabName]
    if not tab then return end
    
    -- Create section frame
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.BackgroundColor3 = COLORS.LightBackground
    section.BorderSizePixel = 0
    section.Size = UDim2.new(1, 0, 0, 40)
    section.ZIndex = 4
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = tab.Content
    
    -- Add corner
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = section
    
    -- Create section title
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "Title"
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Position = UDim2.new(0, 10, 0, 0)
    sectionTitle.Size = UDim2.new(1, -20, 0, 30)
    sectionTitle.ZIndex = 5
    sectionTitle.Font = Enum.Font.GothamSemibold
    sectionTitle.Text = title
    sectionTitle.TextColor3 = COLORS.Text
    sectionTitle.TextSize = 14
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section
    
    -- Create section content
    local sectionContent = Instance.new("Frame")
    sectionContent.Name = "Content"
    sectionContent.BackgroundTransparency = 1
    sectionContent.Position = UDim2.new(0, 10, 0, 30)
    sectionContent.Size = UDim2.new(1, -20, 0, 0)
    sectionContent.ZIndex = 5
    sectionContent.AutomaticSize = Enum.AutomaticSize.Y
    sectionContent.Parent = section
    
    -- Add list layout
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = sectionContent
    
    -- Auto-size section
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sectionContent.Size = UDim2.new(1, -20, 0, contentLayout.AbsoluteContentSize.Y)
        section.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
    end)
    
    -- Return section for chaining
    return {
        Section = section,
        Content = sectionContent,
        
        -- Add label
        AddLabel = function(_, text)
            return self:AddLabel(sectionContent, text)
        end,
        
        -- Add button
        AddButton = function(_, text, callback)
            return self:AddButton(sectionContent, text, callback)
        end,
        
        -- Add toggle
        AddToggle = function(_, text, default, callback)
            return self:AddToggle(sectionContent, text, default, callback)
        end,
        
        -- Add slider
        AddSlider = function(_, text, min, max, default, callback)
            return self:AddSlider(sectionContent, text, min, max, default, callback)
        end,
        
        -- Add textbox
        AddTextbox = function(_, text, placeholder, default, callback)
            return self:AddTextbox(sectionContent, text, placeholder, default, callback)
        end,
        
        -- Add dropdown
        AddDropdown = function(_, text, options, default, callback)
            return self:AddDropdown(sectionContent, text, options, default, callback)
        end,
        
        -- Add color picker
        AddColorPicker = function(_, text, default, callback)
            return self:AddColorPicker(sectionContent, text, default, callback)
        end,
        
        -- Add keybind
        AddKeybind = function(_, text, default, callback)
            return self:AddKeybind(sectionContent, text, default, callback)
        end
    }
end

-- Add a label
function RedGlowUI:AddLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.ZIndex = parent.ZIndex
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    -- Return label for chaining
    return {
        Instance = label,
        
        -- Set text
        SetText = function(_, newText)
            label.Text = newText
        end
    }
end

-- Add a button
function RedGlowUI:AddButton(parent, text, callback)
    callback = callback or function() end
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.BackgroundColor3 = COLORS.Background
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 32)
    button.ZIndex = parent.ZIndex
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = COLORS.Text
    button.TextSize = 14
    button.ClipsDescendants = true
    button.Parent = parent
    
    -- Add corner
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    -- Button hover effect
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.Highlight}):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.Background}):Play()
    end)
    
    -- Button click effect
    button.MouseButton1Down:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.DarkBackground}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.Highlight}):Play()
    end)
    
    -- Button click
    button.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createRipple(button)
        callback()
    end)
    
    -- Return button for chaining
    return {
        Instance = button,
        
        -- Set text
        SetText = function(_, newText)
            button.Text = newText
        end
    }
end

-- Add a toggle
function RedGlowUI:AddToggle(parent, text, default, callback)
    callback = callback or function() end
    default = default or false
    
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Size = UDim2.new(1, 0, 0, 32)
    toggleContainer.ZIndex = parent.ZIndex
    toggleContainer.Parent = parent
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.Size = UDim2.new(1, -50, 1, 0)
    toggleLabel.ZIndex = parent.ZIndex
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Text = text
    toggleLabel.TextColor3 = COLORS.Text
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleContainer
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "Toggle"
    toggleButton.BackgroundColor3 = default and COLORS.Accent or COLORS.Background
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.ZIndex = parent.ZIndex
    toggleButton.Parent = toggleContainer
    
    -- Add corner
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    -- Create toggle indicator
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "Indicator"
    toggleIndicator.BackgroundColor3 = COLORS.Text
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    toggleIndicator.ZIndex = parent.ZIndex + 1
    toggleIndicator.Parent = toggleButton
    
    -- Add corner to indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = toggleIndicator
    
    -- Create hitbox
    local toggleHitbox = Instance.new("TextButton")
    toggleHitbox.Name = "Hitbox"
    toggleHitbox.BackgroundTransparency = 1
    toggleHitbox.Size = UDim2.new(1, 0, 1, 0)
    toggleHitbox.ZIndex = parent.ZIndex + 2
    toggleHitbox.Text = ""
    toggleHitbox.Parent = toggleContainer
    
    -- Toggle state
    local enabled = default
    
    -- Toggle function
    local function updateToggle()
        enabled = not enabled
        
        -- Update visuals
        if enabled then
            createTween(toggleButton, {BackgroundColor3 = COLORS.Accent}):Play()
            createTween(toggleIndicator, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            createTween(toggleButton, {BackgroundColor3 = COLORS.Background}):Play()
            createTween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        
        -- Play sound
        playSound(SOUNDS.Toggle)
        
        -- Call callback
        callback(enabled)
    end
    
    -- Toggle click
    toggleHitbox.MouseButton1Click:Connect(updateToggle)
    
    -- Return toggle for chaining
    return {
        Instance = toggleContainer,
        
        -- Set state
        SetState = function(_, state)
            if state ~= enabled then
                updateToggle()
            end
        end,
        
        -- Get state
        GetState = function()
            return enabled
        end
    }
end

-- Add a slider
function RedGlowUI:AddSlider(parent, text, min, max, default, callback)
    callback = callback or function() end
    min = min or 0
    max = max or 100
    default = default or min
    
    -- Clamp default value
    default = math.clamp(default, min, max)
    
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = "SliderContainer"
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Size = UDim2.new(1, 0, 0, 50)
    sliderContainer.ZIndex = parent.ZIndex
    sliderContainer.Parent = parent
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "Label"
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.ZIndex = parent.ZIndex
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Text = text
    sliderLabel.TextColor3 = COLORS.Text
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderContainer
    
    local sliderValue = Instance.new("TextLabel")
    sliderValue.Name = "Value"
    sliderValue.BackgroundTransparency = 1
    sliderValue.Position = UDim2.new(1, -40, 0, 0)
    sliderValue.Size = UDim2.new(0, 40, 0, 20)
    sliderValue.ZIndex = parent.ZIndex
    sliderValue.Font = Enum.Font.Gotham
    sliderValue.Text = tostring(default)
    sliderValue.TextColor3 = COLORS.Accent
    sliderValue.TextSize = 14
    sliderValue.TextXAlignment = Enum.TextXAlignment.Right
    sliderValue.Parent = sliderContainer
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.BackgroundColor3 = COLORS.Background
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.Size = UDim2.new(1, 0, 0, 10)
    sliderFrame.ZIndex = parent.ZIndex
    sliderFrame.Parent = sliderContainer
    
    -- Add corner
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    -- Create slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.BackgroundColor3 = COLORS.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.ZIndex = parent.ZIndex + 1
    sliderFill.Parent = sliderFrame
    
    -- Add corner to fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    -- Create slider indicator
    local sliderIndicator = Instance.new("Frame")
    sliderIndicator.Name = "Indicator"
    sliderIndicator.BackgroundColor3 = COLORS.Text
    sliderIndicator.BorderSizePixel = 0
    sliderIndicator.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    sliderIndicator.Size = UDim2.new(0, 12, 0, 12)
    sliderIndicator.ZIndex = parent.ZIndex + 2
    sliderIndicator.Parent = sliderFrame
    
    -- Add corner to indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = sliderIndicator
    
    -- Create hitbox
    local sliderHitbox = Instance.new("TextButton")
    sliderHitbox.Name = "Hitbox"
    sliderHitbox.BackgroundTransparency = 1
    sliderHitbox.Size = UDim2.new(1, 0, 1, 0)
    sliderHitbox.ZIndex = parent.ZIndex + 3
    sliderHitbox.Text = ""
    sliderHitbox.Parent = sliderFrame
    
    -- Slider state
    local value = default
    local dragging = false
    
    -- Update slider function
    local function updateSlider(input)
        local sizeX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(min + ((max - min) * sizeX))
        
        -- Update visuals
        sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
        sliderIndicator.Position = UDim2.new(sizeX, -6, 0.5, -6)
        sliderValue.Text = tostring(newValue)
        
        -- Update value if changed
        if newValue ~= value then
            value = newValue
            callback(value)
        end
    end
    
    -- Slider input
    sliderHitbox.MouseButton1Down:Connect(function(input)
        dragging = true
        updateSlider(input)
        playSound(SOUNDS.Slider, 0.3)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    -- Return slider for chaining
    return {
        Instance = sliderContainer,
        
        -- Set value
        SetValue = function(_, newValue)
            newValue = math.clamp(newValue, min, max)
            local sizeX = (newValue - min) / (max - min)
            
            -- Update visuals
            createTween(sliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}):Play()
            createTween(sliderIndicator, {Position = UDim2.new(sizeX, -6, 0.5, -6)}):Play()
            sliderValue.Text = tostring(newValue)
            
            -- Update value
            value = newValue
            callback(value)
        end,
        
        -- Get value
        GetValue = function()
            return value
        end
    }
end

-- Add a textbox
function RedGlowUI:AddTextbox(parent, text, placeholder, default, callback)
    callback = callback or function() end
    default = default or ""
    placeholder = placeholder or "Enter text..."
    
    local textboxContainer = Instance.new("Frame")
    textboxContainer.Name = "TextboxContainer"
    textboxContainer.BackgroundTransparency = 1
    textboxContainer.Size = UDim2.new(1, 0, 0, 50)
    textboxContainer.ZIndex = parent.ZIndex
    textboxContainer.Parent = parent
    
    local textboxLabel = Instance.new("TextLabel")
    textboxLabel.Name = "Label"
    textboxLabel.BackgroundTransparency = 1
    textboxLabel.Position = UDim2.new(0, 0, 0, 0)
    textboxLabel.Size = UDim2.new(1, 0, 0, 20)
    textboxLabel.ZIndex = parent.ZIndex
    textboxLabel.Font = Enum.Font.Gotham
    textboxLabel.Text = text
    textboxLabel.TextColor3 = COLORS.Text
    textboxLabel.TextSize = 14
    textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textboxLabel.Parent = textboxContainer
    
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Name = "TextboxFrame"
    textboxFrame.BackgroundColor3 = COLORS.Background
    textboxFrame.BorderSizePixel = 0
    textboxFrame.Position = UDim2.new(0, 0, 0, 25)
    textboxFrame.Size = UDim2.new(1, 0, 0, 25)
    textboxFrame.ZIndex = parent.ZIndex
    textboxFrame.Parent = textboxContainer
    
    -- Add corner
    local textboxCorner = Instance.new("UICorner")
    textboxCorner.CornerRadius = UDim.new(0, 4)
    textboxCorner.Parent = textboxFrame
    
    -- Create textbox
    local textbox = Instance.new("TextBox")
    textbox.Name = "Textbox"
    textbox.BackgroundTransparency = 1
    textbox.Position = UDim2.new(0, 10, 0, 0)
    textbox.Size = UDim2.new(1, -20, 1, 0)
    textbox.ZIndex = parent.ZIndex + 1
    textbox.Font = Enum.Font.Gotham
    textbox.PlaceholderText = placeholder
    textbox.Text = default
    textbox.TextColor3 = COLORS.Text
    textbox.TextSize = 14
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.ClearTextOnFocus = false
    textbox.Parent = textboxFrame
    
    -- Textbox focus
    textbox.Focused:Connect(function()
        createTween(textboxFrame, {BackgroundColor3 = COLORS.Highlight}):Play()
    end)
    
    textbox.FocusLost:Connect(function(enterPressed)
        createTween(textboxFrame, {BackgroundColor3 = COLORS.Background}):Play()
        callback(textbox.Text, enterPressed)
    end)
    
    -- Return textbox for chaining
    return {
        Instance = textboxContainer,
        
        -- Set text
        SetText = function(_, newText)
            textbox.Text = newText
            callback(newText, false)
        end,
        
        -- Get text
        GetText = function()
            return textbox.Text
        end
    }
end

-- Add a dropdown
function RedGlowUI:AddDropdown(parent, text, options, default, callback)
    callback = callback or function() end
    options = options or {}
    default = default or options[1] or ""
    
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Name = "DropdownContainer"
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Size = UDim2.new(1, 0, 0, 50)
    dropdownContainer.ZIndex = parent.ZIndex
    dropdownContainer.Parent = parent
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "Label"
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
    dropdownLabel.Size = UDim2.new(1, 0, 0, 20)
    dropdownLabel.ZIndex = parent.ZIndex
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.Text = text
    dropdownLabel.TextColor3 = COLORS.Text
    dropdownLabel.TextSize = 14
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownContainer
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "DropdownFrame"
    dropdownFrame.BackgroundColor3 = COLORS.Background
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Position = UDim2.new(0, 0, 0, 25)
    dropdownFrame.Size = UDim2.new(1, 0, 0, 25)
    dropdownFrame.ZIndex = parent.ZIndex
    dropdownFrame.Parent = dropdownContainer
    
    -- Add corner
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdownFrame
    
    -- Create dropdown text
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Name = "Text"
    dropdownText.BackgroundTransparency = 1
    dropdownText.Position = UDim2.new(0, 10, 0, 0)
    dropdownText.Size = UDim2.new(1, -40, 1, 0)
    dropdownText.ZIndex = parent.ZIndex + 1
    dropdownText.Font = Enum.Font.Gotham
    dropdownText.Text = default
    dropdownText.TextColor3 = COLORS.Text
    dropdownText.TextSize = 14
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.TextTruncate = Enum.TextTruncate.AtEnd
    dropdownText.Parent = dropdownFrame
    
    -- Create dropdown arrow
    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Name = "Arrow"
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
    dropdownArrow.Size = UDim2.new(0, 25, 1, 0)
    dropdownArrow.ZIndex = parent.ZIndex + 1
    dropdownArrow.Font = Enum.Font.Gotham
    dropdownArrow.Text = "▼"
    dropdownArrow.TextColor3 = COLORS.TextDark
    dropdownArrow.TextSize = 12
    dropdownArrow.Parent = dropdownFrame
    
    -- Create dropdown list
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "List"
    dropdownList.BackgroundColor3 = COLORS.Background
    dropdownList.BorderSizePixel = 0
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.ZIndex = parent.ZIndex + 3
    dropdownList.Visible = false
    dropdownList.ClipsDescendants = true
    dropdownList.Parent = dropdownFrame
    
    -- Add corner to list
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = dropdownList
    
    -- Create list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 0)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList
    
    -- Create hitbox
    local dropdownHitbox = Instance.new("TextButton")
    dropdownHitbox.Name = "Hitbox"
    dropdownHitbox.BackgroundTransparency = 1
    dropdownHitbox.Size = UDim2.new(1, 0, 1, 0)
    dropdownHitbox.ZIndex = parent.ZIndex + 2
    dropdownHitbox.Text = ""
    dropdownHitbox.Parent = dropdownFrame
    
    -- Dropdown state
    local value = default
    local open = false
    
    -- Populate dropdown list
    local function populateList()
        -- Clear existing options
        for _, child in pairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Add options
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = "Option_" .. i
            optionButton.BackgroundTransparency = 1
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.ZIndex = parent.ZIndex + 4
            optionButton.Font = Enum.Font.Gotham
            optionButton.Text = option
            optionButton.TextColor3 = option == value and COLORS.Accent or COLORS.Text
            optionButton.TextSize = 14
            optionButton.Parent = dropdownList
            
            -- Option hover effect
            optionButton.MouseEnter:Connect(function()
                if option ~= value then
                    createTween(optionButton, {BackgroundTransparency = 0.9, BackgroundColor3 = COLORS.Highlight}):Play()
                end
                playSound(SOUNDS.Hover, 0.2)
            end)
            
            optionButton.MouseLeave:Connect(function()
                if option ~= value then
                    createTween(optionButton, {BackgroundTransparency = 1}):Play()
                end
            end)
            
            -- Option click
            optionButton.MouseButton1Click:Connect(function()
                playSound(SOUNDS.Click)
                
                -- Update value
                value = option
                dropdownText.Text = option
                
                -- Update visuals
                for _, child in pairs(dropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        createTween(child, {TextColor3 = child.Text == value and COLORS.Accent or COLORS.Text}):Play()
                    end
                end
                
                -- Close dropdown
                toggleDropdown()
                
                -- Call callback
                callback(value)
            end)
        end
    end
    
    -- Toggle dropdown function
    function toggleDropdown()
        open = not open
        
        -- Update visuals
        if open then
            populateList()
            dropdownList.Visible = true
            createTween(dropdownArrow, {Rotation = 180}):Play()
            createTween(dropdownList, {Size = UDim2.new(1, 0, 0, math.min(#options * 25, 150))}):Play()
        else
            createTween(dropdownArrow, {Rotation = 0}):Play()
            createTween(dropdownList, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            
            wait(TWEEN_TIME)
            if not open then
                dropdownList.Visible = false
            end
        end
    end
    
    -- Dropdown click
    dropdownHitbox.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        toggleDropdown()
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownPos = dropdownFrame.AbsolutePosition
            local dropdownSize = dropdownFrame.AbsoluteSize
            local listPos = dropdownList.AbsolutePosition
            local listSize = dropdownList.AbsoluteSize
            
            if open and not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) and not (mousePos.X >= listPos.X and mousePos.X <= listPos.X + listSize.X and mousePos.Y >= listPos.Y and mousePos.Y <= listPos.Y + listSize.Y) then
                toggleDropdown()
            end
        end
    end)
    
    -- Return dropdown for chaining
    return {
        Instance = dropdownContainer,
        
        -- Set value
        SetValue = function(_, newValue)
            for _, option in ipairs(options) do
                if option == newValue then
                    value = newValue
                    dropdownText.Text = newValue
                    callback(value)
                    return
                end
            end
        end,
        
        -- Get value
        GetValue = function()
            return value
        end,
        
        -- Refresh options
        RefreshOptions = function(_, newOptions)
            options = newOptions or options
            
            -- Update value if it's not in the new options
            local valueExists = false
            for _, option in ipairs(options) do
                if option == value then
                    valueExists = true
                    break
                end
            end
            
            if not valueExists and #options > 0 then
                value = options[1]
                dropdownText.Text = value
                callback(value)
            elseif #options == 0 then
                value = ""
                dropdownText.Text = ""
            end
            
            -- Update list if open
            if open then
                populateList()
                dropdownList.Size = UDim2.new(1, 0, 0, math.min(#options * 25, 150))
            end
        end
    }
end

-- Add a color picker
function RedGlowUI:AddColorPicker(parent, text, default, callback)
    callback = callback or function() end
    default = default or Color3.fromRGB(255, 255, 255)
    
    local colorPickerContainer = Instance.new("Frame")
    colorPickerContainer.Name = "ColorPickerContainer"
    colorPickerContainer.BackgroundTransparency = 1
    colorPickerContainer.Size = UDim2.new(1, 0, 0, 50)
    colorPickerContainer.ZIndex = parent.ZIndex
    colorPickerContainer.Parent = parent
    
    local colorPickerLabel = Instance.new("TextLabel")
    colorPickerLabel.Name = "Label"
    colorPickerLabel.BackgroundTransparency = 1
    colorPickerLabel.Position = UDim2.new(0, 0, 0, 0)
    colorPickerLabel.Size = UDim2.new(1, -40, 0, 20)
    colorPickerLabel.ZIndex = parent.ZIndex
    colorPickerLabel.Font = Enum.Font.Gotham
    colorPickerLabel.Text = text
    colorPickerLabel.TextColor3 = COLORS.Text
    colorPickerLabel.TextSize = 14
    colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorPickerLabel.Parent = colorPickerContainer
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Name = "ColorDisplay"
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Position = UDim2.new(1, -30, 0, 0)
    colorDisplay.Size = UDim2.new(0, 30, 0, 20)
    colorDisplay.ZIndex = parent.ZIndex
    colorDisplay.Parent = colorPickerContainer
    
    -- Add corner
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = colorDisplay
    
    -- Create color picker button
    local colorPickerButton = Instance.new("TextButton")
    colorPickerButton.Name = "Button"
    colorPickerButton.BackgroundColor3 = COLORS.Background
    colorPickerButton.BorderSizePixel = 0
    colorPickerButton.Position = UDim2.new(0, 0, 0, 25)
    colorPickerButton.Size = UDim2.new(1, 0, 0, 25)
    colorPickerButton.ZIndex = parent.ZIndex
    colorPickerButton.Font = Enum.Font.Gotham
    colorPickerButton.Text = "Pick a color"
    colorPickerButton.TextColor3 = COLORS.Text
    colorPickerButton.TextSize = 14
    colorPickerButton.Parent = colorPickerContainer
    
    -- Add corner
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = colorPickerButton
    
    -- Button hover effect
    colorPickerButton.MouseEnter:Connect(function()
        createTween(colorPickerButton, {BackgroundColor3 = COLORS.Highlight}):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    colorPickerButton.MouseLeave:Connect(function()
        createTween(colorPickerButton, {BackgroundColor3 = COLORS.Background}):Play()
    end)
    
    -- Create color picker popup
    local colorPickerPopup = Instance.new("Frame")
    colorPickerPopup.Name = "ColorPickerPopup"
    colorPickerPopup.BackgroundColor3 = COLORS.Background
    colorPickerPopup.BorderSizePixel = 0
    colorPickerPopup.Position = UDim2.new(0, 0, 1, 10)
    colorPickerPopup.Size = UDim2.new(1, 0, 0, 200)
    colorPickerPopup.ZIndex = parent.ZIndex + 10
    colorPickerPopup.Visible = false
    colorPickerPopup.Parent = colorPickerContainer
    
    -- Add corner
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 6)
    popupCorner.Parent = colorPickerPopup
    
    -- Create color picker UI
    -- This is a simplified color picker for demonstration
    -- A full implementation would include HSV color selection
    
    -- Create RGB sliders
    local function createColorSlider(name, color, value, yPos)
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Name = name .. "Container"
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.Position = UDim2.new(0, 10, 0, yPos)
        sliderContainer.Size = UDim2.new(1, -20, 0, 30)
        sliderContainer.ZIndex = parent.ZIndex + 11
        sliderContainer.Parent = colorPickerPopup
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Position = UDim2.new(0, 0, 0, 0)
        sliderLabel.Size = UDim2.new(0, 20, 1, 0)
        sliderLabel.ZIndex = parent.ZIndex + 11
        sliderLabel.Font = Enum.Font.GothamBold
        sliderLabel.Text = name
        sliderLabel.TextColor3 = color
        sliderLabel.TextSize = 14
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderContainer
        
        local sliderValue = Instance.new("TextLabel")
        sliderValue.Name = "Value"
        sliderValue.BackgroundTransparency = 1
        sliderValue.Position = UDim2.new(1, -30, 0, 0)
        sliderValue.Size = UDim2.new(0, 30, 1, 0)
        sliderValue.ZIndex = parent.ZIndex + 11
        sliderValue.Font = Enum.Font.Gotham
        sliderValue.Text = tostring(value)
        sliderValue.TextColor3 = COLORS.Text
        sliderValue.TextSize = 14
        sliderValue.TextXAlignment = Enum.TextXAlignment.Right
        sliderValue.Parent = sliderContainer
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = "SliderFrame"
        sliderFrame.BackgroundColor3 = COLORS.DarkBackground
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Position = UDim2.new(0, 25, 0.5, -2)
        sliderFrame.Size = UDim2.new(1, -65, 0, 4)
        sliderFrame.ZIndex = parent.ZIndex + 11
        sliderFrame.Parent = sliderContainer
        
        -- Add corner
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(1, 0)
        sliderCorner.Parent = sliderFrame
        
        -- Create slider fill
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "Fill"
        sliderFill.BackgroundColor3 = color
        sliderFill.BorderSizePixel = 0
        sliderFill.Size = UDim2.new(value / 255, 0, 1, 0)
        sliderFill.ZIndex = parent.ZIndex + 12
        sliderFill.Parent = sliderFrame
        
        -- Add corner to fill
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = sliderFill
        
        -- Create slider indicator
        local sliderIndicator = Instance.new("Frame")
        sliderIndicator.Name = "Indicator"
        sliderIndicator.BackgroundColor3 = COLORS.Text
        sliderIndicator.BorderSizePixel = 0
        sliderIndicator.Position = UDim2.new(value / 255, -6, 0.5, -6)
        sliderIndicator.Size = UDim2.new(0, 12, 0, 12)
        sliderIndicator.ZIndex = parent.ZIndex + 13
        sliderIndicator.Parent = sliderFrame
        
        -- Add corner to indicator
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = sliderIndicator
        
        -- Create hitbox
        local sliderHitbox = Instance.new("TextButton")
        sliderHitbox.Name = "Hitbox"
        sliderHitbox.BackgroundTransparency = 1
        sliderHitbox.Size = UDim2.new(1, 0, 1, 0)
        sliderHitbox.ZIndex = parent.ZIndex + 14
        sliderHitbox.Text = ""
        sliderHitbox.Parent = sliderFrame
        
        -- Slider state
        local dragging = false
        
        -- Update slider function
        local function updateSlider(input)
            local sizeX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local newValue = math.floor(sizeX * 255)
            
            -- Update visuals
            sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
            sliderIndicator.Position = UDim2.new(sizeX, -6, 0.5, -6)
            sliderValue.Text = tostring(newValue)
            
            return newValue
        end
        
        -- Slider input
        sliderHitbox.MouseButton1Down:Connect(function(input)
            dragging = true
            local newValue = updateSlider(input)
            
            -- Update color
            local r = name == "R" and newValue or tonumber(colorPickerPopup.RContainer.Value.Text)
            local g = name == "G" and newValue or tonumber(colorPickerPopup.GContainer.Value.Text)
            local b = name == "B" and newValue or tonumber(colorPickerPopup.BContainer.Value.Text)
            
            local newColor = Color3.fromRGB(r, g, b)
            colorDisplay.BackgroundColor3 = newColor
            callback(newColor)
            
            playSound(SOUNDS.Slider, 0.3)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local newValue = updateSlider(input)
                
                -- Update color
                local r = name == "R" and newValue or tonumber(colorPickerPopup.RContainer.Value.Text)
                local g = name == "G" and newValue or tonumber(colorPickerPopup.GContainer.Value.Text)
                local b = name == "B" and newValue or tonumber(colorPickerPopup.BContainer.Value.Text)
                
                local newColor = Color3.fromRGB(r, g, b)
                colorDisplay.BackgroundColor3 = newColor
                callback(newColor)
            end
        end)
        
        return sliderContainer
    end
    
    -- Create RGB sliders
    local r, g, b = math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)
    createColorSlider("R", Color3.fromRGB(255, 50, 50), r, 20)
    createColorSlider("G", Color3.fromRGB(50, 255, 50), g, 60)
    createColorSlider("B", Color3.fromRGB(50, 50, 255), b, 100)
    
    -- Create apply button
    local applyButton = Instance.new("TextButton")
    applyButton.Name = "ApplyButton"
    applyButton.BackgroundColor3 = COLORS.Accent
    applyButton.BorderSizePixel = 0
    applyButton.Position = UDim2.new(0.5, -50, 1, -40)
    applyButton.Size = UDim2.new(0, 100, 0, 30)
    applyButton.ZIndex = parent.ZIndex + 11
    applyButton.Font = Enum.Font.GothamSemibold
    applyButton.Text = "Apply"
    applyButton.TextColor3 = COLORS.Text
    applyButton.TextSize = 14
    applyButton.Parent = colorPickerPopup
    
    -- Add corner
    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 4)
    applyCorner.Parent = applyButton
    
    -- Button hover effect
    applyButton.MouseEnter:Connect(function()
        createTween(applyButton, {BackgroundColor3 = COLORS.AccentDark}):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    applyButton.MouseLeave:Connect(function()
        createTween(applyButton, {BackgroundColor3 = COLORS.Accent}):Play()
    end)
    
    -- Button click
    applyButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createRipple(applyButton)
        
        -- Hide popup
        colorPickerPopup.Visible = false
    end)
    
    -- Color picker state
    local open = false
    
    -- Toggle color picker function
    local function toggleColorPicker()
        open = not open
        colorPickerPopup.Visible = open
    end
    
    -- Color picker button click
    colorPickerButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createRipple(colorPickerButton)
        toggleColorPicker()
    end)
    
    -- Close color picker when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local popupPos = colorPickerPopup.AbsolutePosition
            local popupSize = colorPickerPopup.AbsoluteSize
            local buttonPos = colorPickerButton.AbsolutePosition
            local buttonSize = colorPickerButton.AbsoluteSize
            
            if open and not (mousePos.X >= popupPos.X and mousePos.X <= popupPos.X + popupSize.X and mousePos.Y >= popupPos.Y and mousePos.Y <= popupPos.Y + popupSize.Y) and not (mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y) then
                toggleColorPicker()
            end
        end
    end)
    
    -- Return color picker for chaining
    return {
        Instance = colorPickerContainer,
        
        -- Set color
        SetColor = function(_, newColor)
            colorDisplay.BackgroundColor3 = newColor
            
            -- Update sliders
            local r, g, b = math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255)
            
            colorPickerPopup.RContainer.Value.Text = tostring(r)
            colorPickerPopup.RContainer.SliderFrame.Fill.Size = UDim2.new(r / 255, 0, 1, 0)
            colorPickerPopup.RContainer.SliderFrame.Indicator.Position = UDim2.new(r / 255, -6, 0.5, -6)
            
            colorPickerPopup.GContainer.Value.Text = tostring(g)
            colorPickerPopup.GContainer.SliderFrame.Fill.Size = UDim2.new(g / 255, 0, 1, 0)
            colorPickerPopup.GContainer.SliderFrame.Indicator.Position = UDim2.new(g / 255, -6, 0.5, -6)
            
            colorPickerPopup.BContainer.Value.Text = tostring(b)
            colorPickerPopup.BContainer.SliderFrame.Fill.Size = UDim2.new(b / 255, 0, 1, 0)
            colorPickerPopup.BContainer.SliderFrame.Indicator.Position = UDim2.new(b / 255, -6, 0.5, -6)
            
            callback(newColor)
        end,
        
        -- Get color
        GetColor = function()
            return colorDisplay.BackgroundColor3
        end
    }
end

-- Add a keybind
function RedGlowUI:AddKeybind(parent, text, default, callback)
    callback = callback or function() end
    default = default or Enum.KeyCode.Unknown
    
    local keybindContainer = Instance.new("Frame")
    keybindContainer.Name = "KeybindContainer"
    keybindContainer.BackgroundTransparency = 1
    keybindContainer.Size = UDim2.new(1, 0, 0, 32)
    keybindContainer.ZIndex = parent.ZIndex
    keybindContainer.Parent = parent
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Name = "Label"
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Position = UDim2.new(0, 0, 0, 0)
    keybindLabel.Size = UDim2.new(1, -80, 1, 0)
    keybindLabel.ZIndex = parent.ZIndex
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.Text = text
    keybindLabel.TextColor3 = COLORS.Text
    keybindLabel.TextSize = 14
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindContainer
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "Button"
    keybindButton.BackgroundColor3 = COLORS.Background
    keybindButton.BorderSizePixel = 0
    keybindButton.Position = UDim2.new(1, -70, 0, 0)
    keybindButton.Size = UDim2.new(0, 70, 1, 0)
    keybindButton.ZIndex = parent.ZIndex
    keybindButton.Font = Enum.Font.Gotham
    keybindButton.Text = default ~= Enum.KeyCode.Unknown and default.Name or "None"
    keybindButton.TextColor3 = COLORS.Text
    keybindButton.TextSize = 14
    keybindButton.Parent = keybindContainer
    
    -- Add corner
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = keybindButton
    
    -- Button hover effect
    keybindButton.MouseEnter:Connect(function()
        createTween(keybindButton, {BackgroundColor3 = COLORS.Highlight}):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    keybindButton.MouseLeave:Connect(function()
        createTween(keybindButton, {BackgroundColor3 = COLORS.Background}):Play()
    end)
    
    -- Keybind state
    local key = default
    local listening = false
    
    -- Update keybind function
    local function updateKeybind(input)
        key = input.KeyCode
        keybindButton.Text = key ~= Enum.KeyCode.Unknown and key.Name or "None"
        callback(key)
    end
    
    -- Toggle listening function
    local function toggleListening()
        listening = not listening
        
        if listening then
            keybindButton.Text = "..."
            createTween(keybindButton, {BackgroundColor3 = COLORS.Accent}):Play()
        else
            keybindButton.Text = key ~= Enum.KeyCode.Unknown and key.Name or "None"
            createTween(keybindButton, {BackgroundColor3 = COLORS.Background}):Play()
        end
    end
    
    -- Keybind button click
    keybindButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        toggleListening()
    end)
    
    -- Listen for key press
    UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            updateKeybind(input)
            toggleListening()
        elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
            callback(key)
        end
    end)
    
    -- Return keybind for chaining
    return {
        Instance = keybindContainer,
        
        -- Set key
        SetKey = function(_, newKey)
            key = newKey
            keybindButton.Text = key ~= Enum.KeyCode.Unknown and key.Name or "None"
            callback(key)
        end,
        
        -- Get key
        GetKey = function()
            return key
        end
    }
end

-- Create notification
function RedGlowUI:CreateNotification(title, text, duration, notifType)
    title = title or "Notification"
    text = text or ""
    duration = duration or 3
    notifType = notifType or "info" -- info, success, warning, error
    
    -- Get notification color based on type
    local notifColor
    if notifType == "success" then
        notifColor = COLORS.Success
    elseif notifType == "warning" then
        notifColor = COLORS.Warning
    elseif notifType == "error" then
        notifColor = COLORS.Error
    else
        notifColor = COLORS.Accent
    end
    
    -- Create notification container if it doesn't exist
    if not self.NotificationContainer then
        self.NotificationContainer = Instance.new("Frame")
        self.NotificationContainer.Name = "NotificationContainer"
        self.NotificationContainer.BackgroundTransparency = 1
        self.NotificationContainer.Position = UDim2.new(1, -20, 0, 20)
        self.NotificationContainer.Size = UDim2.new(0, 300, 1, -40)
        self.NotificationContainer.ZIndex = 100
        self.NotificationContainer.Parent = self.ScreenGui
        
        -- Add list layout
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 10)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        listLayout.Parent = self.NotificationContainer
    end
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = COLORS.Background
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.ZIndex = 101
    notification.ClipsDescendants = true
    notification.Parent = self.NotificationContainer
    
    -- Add corner
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 6)
    notifCorner.Parent = notification
    
    -- Add shadow
    createShadow(notification)
    
    -- Create notification accent
    local notifAccent = Instance.new("Frame")
    notifAccent.Name = "Accent"
    notifAccent.BackgroundColor3 = notifColor
    notifAccent.BorderSizePixel = 0
    notifAccent.Position = UDim2.new(0, 0, 0, 0)
    notifAccent.Size = UDim2.new(0, 4, 1, 0)
    notifAccent.ZIndex = 102
    notifAccent.Parent = notification
    
    -- Add corner to accent
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 6)
    accentCorner.Parent = notifAccent
    
    -- Fix corner overlap
    local accentFix = Instance.new("Frame")
    accentFix.Name = "Fix"
    accentFix.BackgroundColor3 = notifColor
    accentFix.BorderSizePixel = 0
    accentFix.Position = UDim2.new(0.5, 0, 0, 0)
    accentFix.Size = UDim2.new(0.5, 0, 1, 0)
    accentFix.ZIndex = 102
    accentFix.Parent = notifAccent
    
    -- Create notification title
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Name = "Title"
    notifTitle.BackgroundTransparency = 1
    notifTitle.Position = UDim2.new(0, 15, 0, 10)
    notifTitle.Size = UDim2.new(1, -25, 0, 20)
    notifTitle.ZIndex = 103
    notifTitle.Font = Enum.Font.GothamSemibold
    notifTitle.Text = title
    notifTitle.TextColor3 = COLORS.Text
    notifTitle.TextSize = 16
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notification
    
    -- Create notification text
    local notifText = Instance.new("TextLabel")
    notifText.Name = "Text"
    notifText.BackgroundTransparency = 1
    notifText.Position = UDim2.new(0, 15, 0, 35)
    notifText.Size = UDim2.new(1, -25, 0, 0)
    notifText.ZIndex = 103
    notifText.Font = Enum.Font.Gotham
    notifText.Text = text
    notifText.TextColor3 = COLORS.TextDark
    notifText.TextSize = 14
    notifText.TextWrapped = true
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.AutomaticSize = Enum.AutomaticSize.Y
    notifText.Parent = notification
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -25, 0, 10)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.ZIndex = 103
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextColor3 = COLORS.TextDark
    closeButton.TextSize = 20
    closeButton.Parent = notification
    
    -- Close button hover effect
    closeButton.MouseEnter:Connect(function()
        createTween(closeButton, {TextColor3 = COLORS.Text}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        createTween(closeButton, {TextColor3 = COLORS.TextDark}):Play()
    end)
    
    -- Calculate notification height
    local height = 45 + notifText.TextBounds.Y
    
    -- Show notification
    notification.Size = UDim2.new(1, 0, 0, 0)
    createTween(notification, {Size = UDim2.new(1, 0, 0, height)}, 0.3, Enum.EasingStyle.Quint):Play()
    playSound(SOUNDS.Notification)
    
    -- Close notification function
    local function closeNotification()
        createTween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint):Play()
        wait(0.3)
        notification:Destroy()
    end
    
    -- Close button click
    closeButton.MouseButton1Click:Connect(function()
        closeNotification()
    end)
    
    -- Auto close
    spawn(function()
        wait(duration)
        if notification and notification.Parent then
            closeNotification()
        end
    end)
    
    -- Return notification
    return notification
end

-- Return the library
return RedGlowUI
