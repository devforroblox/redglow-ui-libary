--[[
    RedGlow UI Library (Enhanced)
    A sleek, modern UI library for Roblox with ultra-smooth animations and red glowing accents
    
    Features:
    - Smooth grey UI with red glowing edges
    - Premium-quality animations with advanced tweening
    - Enhanced scrolling with momentum and inertia
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
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Constants
local TWEEN_INFO = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    VeryFast = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Linear = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

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
    Slider = "rbxassetid://6895079893",
    Whoosh = "rbxassetid://6768783831"
}

-- Utility Functions
local function createTween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or TWEEN_INFO.Medium
    
    local tween = TweenService:Create(
        instance,
        tweenInfo,
        properties
    )
    
    return tween
end

local function playSound(soundId, volume, pitch)
    volume = volume or 0.5
    pitch = pitch or 1
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.PlaybackSpeed = pitch
    sound.Parent = workspace
    
    sound:Play()
    
    game:GetService("Debris"):AddItem(sound, sound.TimeLength + 0.1)
end

local function createShadow(parent, size, position, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ImageTransparency = transparency or 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.SliceScale = 1
    shadow.Size = size or UDim2.new(1, 10, 1, 10)
    shadow.Position = position or UDim2.new(0, -5, 0, -5)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    
    return shadow
end

local function createGlow(parent, size, position, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5554236805"
    glow.ImageColor3 = COLORS.Glow
    glow.ImageTransparency = transparency or 0.5
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(23, 23, 277, 277)
    glow.SliceScale = 1
    glow.Size = size or UDim2.new(1, 20, 1, 20)
    glow.Position = position or UDim2.new(0, -10, 0, -10)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    
    -- Add pulsing animation
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(glow, tweenInfo, {ImageTransparency = 0.7})
    tween:Play()
    
    return glow
end

local function createRipple(parent, startPos)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.85
    ripple.BorderSizePixel = 0
    ripple.ZIndex = parent.ZIndex + 1
    
    -- If startPos is provided, create ripple at that position
    if startPos then
        local relativePos = Vector2.new(
            startPos.X - parent.AbsolutePosition.X,
            startPos.Y - parent.AbsolutePosition.Y
        )
        
        ripple.Position = UDim2.new(0, relativePos.X, 0, relativePos.Y)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    else
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    end
    
    ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    ripple.Parent = parent
    
    -- Calculate the maximum distance to any corner
    local width, height = parent.AbsoluteSize.X, parent.AbsoluteSize.Y
    local maxDistance = math.sqrt(width^2 + height^2) * 1.5
    
    -- Create ripple animation
    local targetSize = UDim2.new(0, maxDistance, 0, maxDistance)
    local growTween = createTween(ripple, {Size = targetSize}, TWEEN_INFO.Slow)
    local fadeTween = createTween(ripple, {BackgroundTransparency = 1}, TWEEN_INFO.Slow)
    
    growTween:Play()
    fadeTween:Play()
    
    fadeTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Accent
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    
    return stroke
end

local function createScrollingFrame(parent, position, size, zIndex)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Position = position
    scrollFrame.Size = size
    scrollFrame.ZIndex = zIndex
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = COLORS.Accent
    scrollFrame.ScrollBarImageTransparency = 0.5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = parent
    
    -- Add smooth scrolling
    local function smoothScroll(frame)
        local targetPosition = frame.CanvasPosition
        local currentPosition = frame.CanvasPosition
        local velocity = Vector2.new(0, 0)
        local damping = 0.9
        local stiffness = 0.15
        
        local connection
        connection = RunService.RenderStepped:Connect(function(deltaTime)
            if not frame or not frame.Parent then
                connection:Disconnect()
                return
            end
            
            local force = (targetPosition - currentPosition) * stiffness
            velocity = velocity * damping + force
            
            if velocity.Magnitude < 0.1 and (targetPosition - currentPosition).Magnitude < 0.1 then
                currentPosition = targetPosition
                connection:Disconnect()
            else
                currentPosition = currentPosition + velocity
                frame.CanvasPosition = currentPosition
            end
        end)
        
        frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if frame.CanvasPosition ~= currentPosition then
                targetPosition = frame.CanvasPosition
            end
        end)
        
        -- Handle mouse wheel scrolling
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local scrollAmount = input.Position.Z * 80
                targetPosition = Vector2.new(
                    targetPosition.X,
                    math.clamp(targetPosition.Y - scrollAmount, 0, frame.CanvasSize.Y.Offset - frame.AbsoluteSize.Y)
                )
            end
        end)
        
        -- Handle touch scrolling with inertia
        local isDragging = false
        local lastPosition = nil
        local lastUpdateTime = tick()
        local dragVelocity = Vector2.new(0, 0)
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                lastPosition = input.Position
                lastUpdateTime = tick()
                dragVelocity = Vector2.new(0, 0)
            end
        end)
        
        frame.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - lastPosition
                local timeDelta = tick() - lastUpdateTime
                
                if timeDelta > 0 then
                    dragVelocity = delta / timeDelta
                end
                
                targetPosition = Vector2.new(
                    targetPosition.X,
                    math.clamp(targetPosition.Y - delta.Y, 0, frame.CanvasSize.Y.Offset - frame.AbsoluteSize.Y)
                )
                
                lastPosition = input.Position
                lastUpdateTime = tick()
            end
        end)
        
        frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
                
                -- Apply inertia
                local inertiaFactor = 0.2
                velocity = dragVelocity * inertiaFactor
            end
        end)
    end
    
    smoothScroll(scrollFrame)
    
    return scrollFrame
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
        pcall(function()
            self.ScreenGui.Parent = CoreGui
        end)
        
        if not self.ScreenGui.Parent then
            self.ScreenGui.Parent = LocalPlayer.PlayerGui
        end
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
    createShadow(self.Main, UDim2.new(1, 30, 1, 30), UDim2.new(0, -15, 0, -15), 0.3)
    
    -- Add glow
    self.Glow = createGlow(self.Main, UDim2.new(1, 40, 1, 40), UDim2.new(0, -20, 0, -20), 0.4)
    
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
        createTween(self.CloseButton, {TextColor3 = COLORS.Accent}, TWEEN_INFO.Fast):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        createTween(self.CloseButton, {TextColor3 = COLORS.TextDark}, TWEEN_INFO.Fast):Play()
    end)
    
    -- Close button click
    self.CloseButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createRipple(self.CloseButton)
        
        -- Animate close
        local closeTweens = {
            createTween(self.Main, {Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 0), Position = UDim2.new(self.Main.Position.X.Scale, self.Main.Position.X.Offset, self.Main.Position.Y.Scale, self.Main.Position.Y.Offset + self.Main.AbsoluteSize.Y/2)}, TWEEN_INFO.Spring),
            createTween(self.Main, {BackgroundTransparency = 1}, TWEEN_INFO.Medium),
            createTween(self.TitleBar, {BackgroundTransparency = 1}, TWEEN_INFO.Medium),
            createTween(self.Title, {TextTransparency = 1}, TWEEN_INFO.Medium),
            createTween(self.CloseButton, {TextTransparency = 1}, TWEEN_INFO.Medium),
            createTween(self.Glow, {ImageTransparency = 1}, TWEEN_INFO.Medium)
        }
        
        for _, tween in ipairs(closeTweens) do
            tween:Play()
        end
        
        wait(0.6)
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
    
    -- Create tab button list with enhanced scrolling
    self.TabButtonList = createScrollingFrame(
        self.TabButtons,
        UDim2.new(0, 0, 0, 10),
        UDim2.new(1, 0, 1, -10),
        4
    )
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.Parent = self.TabButtonList
    
    -- Auto-adjust canvas size
    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabButtonList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 10)
    end)
    
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = self.Main.Position
                
                -- Play subtle sound
                playSound(SOUNDS.Whoosh, 0.15, 1.2)
                
                -- Add subtle scale effect
                createTween(self.Main, {Size = UDim2.new(0, self.Main.AbsoluteSize.X * 0.98, 0, self.Main.AbsoluteSize.Y * 0.98)}, TWEEN_INFO.VeryFast):Play()
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        
                        -- Restore size with bounce effect
                        createTween(self.Main, {Size = UDim2.new(0, self.Main.AbsoluteSize.X / 0.98, 0, self.Main.AbsoluteSize.Y / 0.98)}, TWEEN_INFO.Spring):Play()
                    end
                end)
            end
        end)
        
        self.TitleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                
                -- Smooth drag with tweening
                createTween(self.Main, {Position = targetPos}, TWEEN_INFO.VeryFast):Play()
            end
        end)
    end
    
    -- Initialize tabs
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Play open animation
    self.Main.Size = UDim2.new(0, 500, 0, 0)
    self.Main.Position = UDim2.new(0.5, -250, 0.5, 0)
    self.Main.BackgroundTransparency = 1
    self.TitleBar.BackgroundTransparency = 1
    self.Title.TextTransparency = 1
    self.CloseButton.TextTransparency = 1
    self.Glow.ImageTransparency = 1
    
    -- Sequence of animations
    wait(0.1)
    createTween(self.Main, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(self.Main, {Size = UDim2.new(0, 500, 0, 350), Position = UDim2.new(0.5, -250, 0.5, -175)}, TWEEN_INFO.Spring):Play()
    wait(0.2)
    createTween(self.TitleBar, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(self.Title, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(self.CloseButton, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(self.Glow, {ImageTransparency = 0.5}, TWEEN_INFO.Slow):Play()
    
    -- Play sound
    playSound(SOUNDS.Whoosh, 0.3)
    
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
    
    -- Add icon if provided
    if icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.Name = "Icon"
        iconImage.BackgroundTransparency = 1
        iconImage.Position = UDim2.new(0, 5, 0.5, -8)
        iconImage.Size = UDim2.new(0, 16, 0, 16)
        iconImage.ZIndex = 5
        iconImage.Image = icon
        iconImage.ImageColor3 = COLORS.TextDark
        iconImage.Parent = tabButton
        
        -- Adjust text position
        tabButton.TextXAlignment = Enum.TextXAlignment.Right
        tabButton.Text = "  " .. name
    end
    
    -- Create tab content with enhanced scrolling
    local tabContent = createScrollingFrame(
        self.TabContent,
        UDim2.new(0, 0, 0, 0),
        UDim2.new(1, 0, 1, 0),
        3
    )
    tabContent.Name = name .. "Content"
    tabContent.Visible = false
    
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
            createTween(tabButton, {TextColor3 = COLORS.Text}, TWEEN_INFO.Fast):Play()
            createTween(tabIndicator, {Size = UDim2.new(0, 2, 0, 10)}, TWEEN_INFO.Fast):Play()
            
            -- Animate icon if present
            local icon = tabButton:FindFirstChild("Icon")
            if icon then
                createTween(icon, {ImageColor3 = COLORS.Text}, TWEEN_INFO.Fast):Play()
            end
            
            playSound(SOUNDS.Hover, 0.2)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            createTween(tabButton, {TextColor3 = COLORS.TextDark}, TWEEN_INFO.Fast):Play()
            createTween(tabIndicator, {Size = UDim2.new(0, 2, 0, 0)}, TWEEN_INFO.Fast):Play()
            
            -- Animate icon if present
            local icon = tabButton:FindFirstChild("Icon")
            if icon then
                createTween(icon, {ImageColor3 = COLORS.TextDark}, TWEEN_INFO.Fast):Play()
            end
        end
    end)
    
    -- Tab button click
    tabButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createRipple(tabButton)
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
        
        -- Animate tab button
        createTween(currentTab.Button, {TextColor3 = COLORS.TextDark}, TWEEN_INFO.Fast):Play()
        createTween(currentTab.Indicator, {Size = UDim2.new(0, 2, 0, 0)}, TWEEN_INFO.Fast):Play()
        
        -- Animate icon if present
        local currentIcon = currentTab.Button:FindFirstChild("Icon")
        if currentIcon then
            createTween(currentIcon, {ImageColor3 = COLORS.TextDark}, TWEEN_INFO.Fast):Play()
        end
        
        -- Fade out content
        createTween(currentTab.Content, {Position = UDim2.new(0.05, 0, 0, 0), BackgroundTransparency = 1}, TWEEN_INFO.Fast):Play()
        wait(0.1)
        currentTab.Content.Visible = false
    end
    
    -- Select new tab
    local newTab = self.Tabs[name]
    
    -- Animate tab button
    createTween(newTab.Button, {TextColor3 = COLORS.Accent}, TWEEN_INFO.Fast):Play()
    createTween(newTab.Indicator, {Size = UDim2.new(0, 2, 0, 20)}, TWEEN_INFO.Spring):Play()
    
    -- Animate icon if present
    local newIcon = newTab.Button:FindFirstChild("Icon")
    if newIcon then
        createTween(newIcon, {ImageColor3 = COLORS.Accent}, TWEEN_INFO.Fast):Play()
    end
    
    -- Fade in content
    newTab.Content.Position = UDim2.new(-0.05, 0, 0, 0)
    newTab.Content.Visible = true
    createTween(newTab.Content, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    
    -- Play sound
    playSound(SOUNDS.Whoosh, 0.2, 1.1)
    
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
    
    -- Add subtle shadow
    createShadow(section, UDim2.new(1, 10, 1, 10), UDim2.new(0, -5, 0, -5), 0.7)
    
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
    
    -- Add accent line
    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.BackgroundColor3 = COLORS.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Position = UDim2.new(0, 10, 0, 30)
    accentLine.Size = UDim2.new(0, 30, 0, 1)
    accentLine.ZIndex = 5
    accentLine.Parent = section
    
    -- Create section content
    local sectionContent = Instance.new("Frame")
    sectionContent.Name = "Content"
    sectionContent.BackgroundTransparency = 1
    sectionContent.Position = UDim2.new(0, 10, 0, 35)
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
        section.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 45)
    end)
    
    -- Animate section creation
    section.BackgroundTransparency = 1
    sectionTitle.TextTransparency = 1
    accentLine.BackgroundTransparency = 1
    
    createTween(section, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(sectionTitle, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(accentLine, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    
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
    
    -- Animate label creation
    label.TextTransparency = 1
    createTween(label, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    
    -- Return label for chaining
    return {
        Instance = label,
        
        -- Set text
        SetText = function(_, newText)
            createTween(label, {TextTransparency = 0.5}, TWEEN_INFO.Fast):Play()
            wait(0.1)
            label.Text = newText
            createTween(label, {TextTransparency = 0}, TWEEN_INFO.Fast):Play()
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
    
    -- Add subtle stroke
    local buttonStroke = createStroke(button, COLORS.Accent, 1, 0.7)
    
    -- Button hover effect
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.Highlight}, TWEEN_INFO.Fast):Play()
        createTween(buttonStroke, {Transparency = 0.3}, TWEEN_INFO.Fast):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.Background}, TWEEN_INFO.Fast):Play()
        createTween(buttonStroke, {Transparency = 0.7}, TWEEN_INFO.Fast):Play()
    end)
    
    -- Button click effect
    button.MouseButton1Down:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.DarkBackground}, TWEEN_INFO.VeryFast):Play()
        createTween(button, {Size = UDim2.new(1, 0, 0, 30)}, TWEEN_INFO.VeryFast):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        createTween(button, {BackgroundColor3 = COLORS.Highlight}, TWEEN_INFO.VeryFast):Play()
        createTween(button, {Size = UDim2.new(1, 0, 0, 32)}, TWEEN_INFO.Spring):Play()
    end)
    
    -- Button click
    button.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createRipple(button, UserInputService:GetMouseLocation())
        callback()
    end)
    
    -- Animate button creation
    button.BackgroundTransparency = 1
    button.TextTransparency = 1
    buttonStroke.Transparency = 1
    
    createTween(button, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(button, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(buttonStroke, {Transparency = 0.7}, TWEEN_INFO.Medium):Play()
    
    -- Return button for chaining
    return {
        Instance = button,
        
        -- Set text
        SetText = function(_, newText)
            createTween(button, {TextTransparency = 0.5}, TWEEN_INFO.Fast):Play()
            wait(0.1)
            button.Text = newText
            createTween(button, {TextTransparency = 0}, TWEEN_INFO.Fast):Play()
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
    
    -- Add subtle glow for on state
    local toggleGlow = createGlow(toggleButton, UDim2.new(1, 20, 1, 20), UDim2.new(0, -10, 0, -10), default and 0.7 or 1)
    
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
    
    -- Add subtle shadow to indicator
    createShadow(toggleIndicator, UDim2.new(1, 6, 1, 6), UDim2.new(0, -3, 0, -3), 0.5)
    
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
        
        -- Update visuals with smooth animation
        if enabled then
            createTween(toggleButton, {BackgroundColor3 = COLORS.Accent}, TWEEN_INFO.Spring):Play()
            createTween(toggleIndicator, {Position = UDim2.new(1, -18, 0.5, -8)}, TWEEN_INFO.Spring):Play()
            createTween(toggleGlow, {ImageTransparency = 0.7}, TWEEN_INFO.Medium):Play()
        else
            createTween(toggleButton, {BackgroundColor3 = COLORS.Background}, TWEEN_INFO.Spring):Play()
            createTween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, -8)}, TWEEN_INFO.Spring):Play()
            createTween(toggleGlow, {ImageTransparency = 1}, TWEEN_INFO.Medium):Play()
        end
        
        -- Add subtle bounce effect
        createTween(toggleIndicator, {Size = UDim2.new(0, 14, 0, 14)}, TWEEN_INFO.VeryFast):Play()
        wait(0.05)
        createTween(toggleIndicator, {Size = UDim2.new(0, 16, 0, 16)}, TWEEN_INFO.Spring):Play()
        
        -- Play sound
        playSound(SOUNDS.Toggle)
        
        -- Call callback
        callback(enabled)
    end
    
    -- Toggle click
    toggleHitbox.MouseButton1Click:Connect(updateToggle)
    
    -- Hover effect
    toggleHitbox.MouseEnter:Connect(function()
        createTween(toggleButton, {BackgroundColor3 = enabled and COLORS.AccentDark or COLORS.Highlight}, TWEEN_INFO.Fast):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    toggleHitbox.MouseLeave:Connect(function()
        createTween(toggleButton, {BackgroundColor3 = enabled and COLORS.Accent or COLORS.Background}, TWEEN_INFO.Fast):Play()
    end)
    
    -- Animate toggle creation
    toggleContainer.BackgroundTransparency = 1
    toggleLabel.TextTransparency = 1
    toggleButton.BackgroundTransparency = 1
    toggleIndicator.BackgroundTransparency = 1
    
    createTween(toggleLabel, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(toggleButton, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(toggleIndicator, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    
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
    
    -- Add subtle shadow to indicator
    createShadow(sliderIndicator, UDim2.new(1, 6, 1, 6), UDim2.new(0, -3, 0, -3), 0.5)
    
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
        
        -- Update visuals with smooth animation
        createTween(sliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, TWEEN_INFO.VeryFast):Play()
        createTween(sliderIndicator, {Position = UDim2.new(sizeX, -6, 0.5, -6)}, TWEEN_INFO.VeryFast):Play()
        sliderValue.Text = tostring(newValue)
        
        -- Update value if changed
        if newValue ~= value then
            value = newValue
            callback(value)
            
            -- Add subtle pulse effect to value
            createTween(sliderValue, {TextSize = 16}, TWEEN_INFO.VeryFast):Play()
            wait(0.05)
            createTween(sliderValue, {TextSize = 14}, TWEEN_INFO.Fast):Play()
        end
    end
    
    -- Slider input
    sliderHitbox.MouseButton1Down:Connect(function(input)
        dragging = true
        updateSlider(input)
        
        -- Add subtle grow effect to indicator
        createTween(sliderIndicator, {Size = UDim2.new(0, 14, 0, 14)}, TWEEN_INFO.VeryFast):Play()
        
        playSound(SOUNDS.Slider, 0.3)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging = false
                
                -- Add subtle shrink effect to indicator
                createTween(sliderIndicator, {Size = UDim2.new(0, 12, 0, 12)}, TWEEN_INFO.Spring):Play()
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    -- Hover effect
    sliderHitbox.MouseEnter:Connect(function()
        createTween(sliderFrame, {BackgroundColor3 = COLORS.Highlight}, TWEEN_INFO.Fast):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    sliderHitbox.MouseLeave:Connect(function()
        createTween(sliderFrame, {BackgroundColor3 = COLORS.Background}, TWEEN_INFO.Fast):Play()
    end)
    
    -- Animate slider creation
    sliderLabel.TextTransparency = 1
    sliderValue.TextTransparency = 1
    sliderFrame.BackgroundTransparency = 1
    sliderFill.BackgroundTransparency = 1
    sliderIndicator.BackgroundTransparency = 1
    
    createTween(sliderLabel, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(sliderValue, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(sliderFrame, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(sliderFill, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(sliderIndicator, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    
    -- Return slider for chaining
    return {
        Instance = sliderContainer,
        
        -- Set value
        SetValue = function(_, newValue)
            newValue = math.clamp(newValue, min, max)
            local sizeX = (newValue - min) / (max - min)
            
            -- Update visuals with smooth animation
            createTween(sliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, TWEEN_INFO.Spring):Play()
            createTween(sliderIndicator, {Position = UDim2.new(sizeX, -6, 0.5, -6)}, TWEEN_INFO.Spring):Play()
            
            -- Ad  {Position = UDim2.new(sizeX, -6, 0.5, -6)}, TWEEN_INFO.Spring):Play()
            
            -- Add subtle pulse effect to value
            createTween(sliderValue, {TextSize = 16}, TWEEN_INFO.VeryFast):Play()
            wait(0.05)
            createTween(sliderValue, {TextSize = 14}, TWEEN_INFO.Fast):Play()
            
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
    
    -- Add subtle stroke
    local textboxStroke = createStroke(textboxFrame, COLORS.Accent, 1, 0.7)
    
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
        createTween(textboxFrame, {BackgroundColor3 = COLORS.Highlight}, TWEEN_INFO.Fast):Play()
        createTween(textboxStroke, {Transparency = 0.3}, TWEEN_INFO.Fast):Play()
        
        -- Add subtle grow effect
        createTween(textboxFrame, {Size = UDim2.new(1, 0, 0, 27)}, TWEEN_INFO.Fast):Play()
        
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    textbox.FocusLost:Connect(function(enterPressed)
        createTween(textboxFrame, {BackgroundColor3 = COLORS.Background}, TWEEN_INFO.Fast):Play()
        createTween(textboxStroke, {Transparency = 0.7}, TWEEN_INFO.Fast):Play()
        
        -- Add subtle shrink effect
        createTween(textboxFrame, {Size = UDim2.new(1, 0, 0, 25)}, TWEEN_INFO.Spring):Play()
        
        callback(textbox.Text, enterPressed)
    end)
    
    -- Animate textbox creation
    textboxLabel.TextTransparency = 1
    textboxFrame.BackgroundTransparency = 1
    textbox.TextTransparency = 1
    textboxStroke.Transparency = 1
    
    createTween(textboxLabel, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(textboxFrame, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(textbox, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(textboxStroke, {Transparency = 0.7}, TWEEN_INFO.Medium):Play()
    
    -- Return textbox for chaining
    return {
        Instance = textboxContainer,
        
        -- Set text
        SetText = function(_, newText)
            createTween(textbox, {TextTransparency = 0.5}, TWEEN_INFO.Fast):Play()
            wait(0.1)
            textbox.Text = newText
            createTween(textbox, {TextTransparency = 0}, TWEEN_INFO.Fast):Play()
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
    
    -- Add subtle stroke
    local dropdownStroke = createStroke(dropdownFrame, COLORS.Accent, 1, 0.7)
    
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
    
    -- Add shadow to list
    createShadow(dropdownList, UDim2.new(1, 10, 1, 10), UDim2.new(0, -5, 0, -5), 0.5)
    
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
                    createTween(optionButton, {BackgroundTransparency = 0.9, BackgroundColor3 = COLORS.Highlight}, TWEEN_INFO.Fast):Play()
                end
                playSound(SOUNDS.Hover, 0.2)
            end)
            
            optionButton.MouseLeave:Connect(function()
                if option ~= value then
                    createTween(optionButton, {BackgroundTransparency = 1}, TWEEN_INFO.Fast):Play()
                end
            end)
            
            -- Option click
            optionButton.MouseButton1Click:Connect(function()
                playSound(SOUNDS.Click)
                createRipple(optionButton)
                
                -- Update value
                value = option
                dropdownText.Text = option
                
                -- Update visuals
                for _, child in pairs(dropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        createTween(child, {TextColor3 = child.Text == value and COLORS.Accent or COLORS.Text}, TWEEN_INFO.Fast):Play()
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
        
        -- Update visuals with smooth animation
        if open then
            populateList()
            dropdownList.Visible = true
            createTween(dropdownArrow, {Rotation = 180}, TWEEN_INFO.Spring):Play()
            createTween(dropdownList, {Size = UDim2.new(1, 0, 0, math.min(#options * 25, 150))}, TWEEN_INFO.Spring):Play()
            createTween(dropdownStroke, {Transparency = 0.3}, TWEEN_INFO.Fast):Play()
            
            -- Add subtle grow effect
            createTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 27)}, TWEEN_INFO.Fast):Play()
            
            playSound(SOUNDS.Whoosh, 0.2, 1.1)
        else
            createTween(dropdownArrow, {Rotation = 0}, TWEEN_INFO.Spring):Play()
            createTween(dropdownList, {Size = UDim2.new(1, 0, 0, 0)}, TWEEN_INFO.Spring):Play()
            createTween(dropdownStroke, {Transparency = 0.7}, TWEEN_INFO.Fast):Play()
            
            -- Add subtle shrink effect
            createTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 25)}, TWEEN_INFO.Spring):Play()
            
            playSound(SOUNDS.Whoosh, 0.2, 0.9)
            
            wait(0.3)
            if not open then
                dropdownList.Visible = false
            end
        end
    end
    
    -- Dropdown click
    dropdownHitbox.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
        createRipple(dropdownFrame)
        toggleDropdown()
    end)
    
    -- Hover effect
    dropdownHitbox.MouseEnter:Connect(function()
        createTween(dropdownFrame, {BackgroundColor3 = COLORS.Highlight}, TWEEN_INFO.Fast):Play()
        playSound(SOUNDS.Hover, 0.2)
    end)
    
    dropdownHitbox.MouseLeave:Connect(function()
        createTween(dropdownFrame, {BackgroundColor3 = COLORS.Background}, TWEEN_INFO.Fast):Play()
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
    
    -- Animate dropdown creation
    dropdownLabel.TextTransparency = 1
    dropdownFrame.BackgroundTransparency = 1
    dropdownText.TextTransparency = 1
    dropdownArrow.TextTransparency = 1
    dropdownStroke.Transparency = 1
    
    createTween(dropdownLabel, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(dropdownFrame, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(dropdownText, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(dropdownArrow, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(dropdownStroke, {Transparency = 0.7}, TWEEN_INFO.Medium):Play()
    
    -- Return dropdown for chaining
    return {
        Instance = dropdownContainer,
        
        -- Set value
        SetValue = function(_, newValue)
            for _, option in ipairs(options) do
                if option == newValue then
                    value = newValue
                    
                    createTween(dropdownText, {TextTransparency = 0.5}, TWEEN_INFO.Fast):Play()
                    wait(0.1)
                    dropdownText.Text = newValue
                    createTween(dropdownText, {TextTransparency = 0}, TWEEN_INFO.Fast):Play()
                    
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
                
                createTween(dropdownText, {TextTransparency = 0.5}, TWEEN_INFO.Fast):Play()
                wait(0.1)
                dropdownText.Text = value
                createTween(dropdownText, {TextTransparency = 0}, TWEEN_INFO.Fast):Play()
                
                callback(value)
            elseif #options == 0 then
                value = ""
                
                createTween(dropdownText, {TextTransparency = 0.5}, TWEEN_INFO.Fast):Play()
                wait(0.1)
                dropdownText.Text = ""
                createTween(dropdownText, {TextTransparency = 0}, TWEEN_INFO.Fast):Play()
            end
            
            -- Update list if open
            if open then
                populateList()
                createTween(dropdownList, {Size = UDim2.new(1, 0, 0, math.min(#options * 25, 150))}, TWEEN_INFO.Spring):Play()
            end
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
    createShadow(notification, UDim2.new(1, 20, 1, 20), UDim2.new(0, -10, 0, -10), 0.5)
    
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
        createTween(closeButton, {TextColor3 = COLORS.Text}, TWEEN_INFO.Fast):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        createTween(closeButton, {TextColor3 = COLORS.TextDark}, TWEEN_INFO.Fast):Play()
    end)
    
    -- Calculate notification height
    local height = 45 + notifText.TextBounds.Y
    
    -- Show notification with smooth animation
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.Position = UDim2.new(0, 50, 0, 0)
    notification.BackgroundTransparency = 1
    notifTitle.TextTransparency = 1
    notifText.TextTransparency = 1
    closeButton.TextTransparency = 1
    notifAccent.BackgroundTransparency = 1
    
    -- Sequence of animations
    createTween(notification, {Size = UDim2.new(1, 0, 0, height), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, TWEEN_INFO.Spring):Play()
    wait(0.1)
    createTween(notifAccent, {BackgroundTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(notifTitle, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    wait(0.1)
    createTween(notifText, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    createTween(closeButton, {TextTransparency = 0}, TWEEN_INFO.Medium):Play()
    
    playSound(SOUNDS.Notification)
    
    -- Close notification function
    local function closeNotification()
        createTween(notifTitle, {TextTransparency = 1}, TWEEN_INFO.Fast):Play()
        createTween(notifText, {TextTransparency = 1}, TWEEN_INFO.Fast):Play()
        createTween(closeButton, {TextTransparency = 1}, TWEEN_INFO.Fast):Play()
        wait(0.1)
        createTween(notifAccent, {BackgroundTransparency = 1}, TWEEN_INFO.Fast):Play()
        wait(0.1)
        createTween(notification, {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, -50, 0, 0), BackgroundTransparency = 1}, TWEEN_INFO.Spring):Play()
        
        wait(0.3)
        notification:Destroy()
    end
    
    -- Close button click
    closeButton.MouseButton1Click:Connect(function()
        playSound(SOUNDS.Click)
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
