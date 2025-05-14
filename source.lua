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
    Background = Color3.fromRGB(19, 20, 24),
    DarkBackground = Color3.fromRGB(22, 23, 27),
    LightBackground = Color3.fromRGB(27, 28, 33),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(66, 89, 182),
    AccentDark = Color3.fromRGB(37, 57, 137),
    Glow = Color3.fromRGB(66, 89, 182),
    Success = Color3.fromRGB(50, 200, 50),
    Warning = Color3.fromRGB(255, 200, 50),
    Error = Color3.fromRGB(255, 50, 50),
    Highlight = Color3.fromRGB(30, 31, 36),
    Shadow = Color3.fromRGB(0, 0, 0)
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
    shadow.Image = "rbxassetid://17290899982"
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
    glow.Image = "rbxassetid://17290723539"
    glow.ImageColor3 = COLORS.Glow
    glow.ImageTransparency = transparency or 0.5
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(23, 23, 277, 277)
    glow.SliceScale = 1
    glow.Size = size or UDim2.new(1, 20, 1, 20)
    glow.Position = position or UDim2.new(0, -10, 0, -10)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    
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
    self.Flags = {}
    self.dragging = false
    self.drag_position = nil
    self.start_position = nil
    
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
    
    -- Create shadow
    self.Shadow = Instance.new("ImageLabel")
    self.Shadow.Name = "Shadow"
    self.Shadow.Parent = self.ScreenGui
    self.Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Shadow.BackgroundTransparency = 1
    self.Shadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.Shadow.BorderSizePixel = 0
    self.Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Shadow.Size = UDim2.new(0, 776, 0, 509)
    self.Shadow.ZIndex = 0
    self.Shadow.Image = "rbxassetid://17290899982"
    
    -- Create main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.Parent = self.ScreenGui
    self.Container.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Container.BackgroundColor3 = COLORS.Background
    self.Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Container.Size = UDim2.new(0, 699, 0, 426)
    
    -- Add corner
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 20)
    containerCorner.Parent = self.Container
    
    -- Create title bar
    self.TitleBar = Instance.new("ImageLabel")
    self.TitleBar.Name = "Top"
    self.TitleBar.Parent = self.Container
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleBar.BackgroundTransparency = 1
    self.TitleBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Size = UDim2.new(0, 699, 0, 39)
    self.TitleBar.Image = ""
    
    -- Create logo
    self.Logo = Instance.new("ImageLabel")
    self.Logo.Name = "Logo"
    self.Logo.Parent = self.TitleBar
    self.Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Logo.BackgroundTransparency = 1
    self.Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.Logo.BorderSizePixel = 0
    self.Logo.Position = UDim2.new(0.0387367606, 0, 0.5, 0)
    self.Logo.Size = UDim2.new(0, 30, 0, 25)
    self.Logo.Image = ""
    
    -- Create title
    self.Title = Instance.new("TextLabel")
    self.Title.Parent = self.TitleBar
    self.Title.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Title.BackgroundTransparency = 1
    self.Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.Title.BorderSizePixel = 0
    self.Title.Position = UDim2.new(0.0938254446, 0, 0.496794879, 0)
    self.Title.Size = UDim2.new(0, 75, 0, 16)
    self.Title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    self.Title.Text = title or "RedGlow UI"
    self.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Title.TextScaled = true
    self.Title.TextSize = 14
    self.Title.TextWrapped = true
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Create divider line
    self.Line = Instance.new("Frame")
    self.Line.Name = "Line"
    self.Line.Parent = self.Container
    self.Line.BackgroundColor3 = COLORS.DarkBackground
    self.Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.Line.BorderSizePixel = 0
    self.Line.Position = UDim2.new(0.296137333, 0, 0.0915492922, 0)
    self.Line.Size = UDim2.new(0, 2, 0, 387)
    
    -- Create tabs container
    self.TabButtons = Instance.new("ScrollingFrame")
    self.TabButtons.Name = "Tabs"
    self.TabButtons.Active = true
    self.TabButtons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.TabButtons.BackgroundTransparency = 1
    self.TabButtons.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.TabButtons.BorderSizePixel = 0
    self.TabButtons.Position = UDim2.new(0, 0, 0.0915492922, 0)
    self.TabButtons.Size = UDim2.new(0, 209, 0, 386)
    self.TabButtons.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    self.TabButtons.ScrollBarThickness = 0
    self.TabButtons.Parent = self.Container
    
    -- Add list layout to tabs
    local tabsListLayout = Instance.new("UIListLayout")
    tabsListLayout.Parent = self.TabButtons
    tabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsListLayout.Padding = UDim.new(0, 9)
    
    -- Add padding to tabs
    local tabsPadding = Instance.new("UIPadding")
    tabsPadding.Parent = self.TabButtons
    tabsPadding.PaddingTop = UDim.new(0, 15)
    
    -- Add corner to tabs
    local tabsCorner = Instance.new("UICorner")
    tabsCorner.Parent = self.TabButtons
    
    -- Create mobile button for mobile devices
    self.MobileButton = Instance.new("TextButton")
    self.MobileButton.Name = "Mobile"
    self.MobileButton.BackgroundColor3 = COLORS.LightBackground
    self.MobileButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.MobileButton.BorderSizePixel = 0
    self.MobileButton.Position = UDim2.new(0.0210955422, 0, 0.91790241, 0)
    self.MobileButton.Size = UDim2.new(0, 122, 0, 38)
    self.MobileButton.AutoButtonColor = false
    self.MobileButton.Modal = true
    self.MobileButton.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    self.MobileButton.Text = ""
    self.MobileButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    self.MobileButton.TextSize = 14
    self.MobileButton.Parent = self.ScreenGui
    
    -- Add corner to mobile button
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 13)
    mobileCorner.Parent = self.MobileButton
    
    -- Add shadow to mobile button
    local mobileShadow = Instance.new("ImageLabel")
    mobileShadow.Name = "Shadow"
    mobileShadow.Parent = self.MobileButton
    mobileShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    mobileShadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mobileShadow.BackgroundTransparency = 1
    mobileShadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
    mobileShadow.BorderSizePixel = 0
    mobileShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    mobileShadow.Size = UDim2.new(0, 144, 0, 58)
    mobileShadow.ZIndex = 0
    mobileShadow.Image = "rbxassetid://17183270335"
    mobileShadow.ImageTransparency = 0.2
    
    -- Add state text to mobile button
    self.MobileState = Instance.new("TextLabel")
    self.MobileState.Name = "State"
    self.MobileState.Parent = self.MobileButton
    self.MobileState.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MobileState.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.MobileState.BackgroundTransparency = 1
    self.MobileState.BorderColor3 = Color3.fromRGB(0, 0, 0)
    self.MobileState.BorderSizePixel = 0
    self.MobileState.Position = UDim2.new(0.646000028, 0, 0.5, 0)
    self.MobileState.Size = UDim2.new(0, 64, 0, 15)
    self.MobileState.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    self.MobileState.Text = "Open"
    self.MobileState.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.MobileState.TextScaled = true
    self.MobileState.TextSize = 14
    self.MobileState.TextWrapped = true
    self.MobileState.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add icon to mobile button
    local mobileIcon = Instance.new("ImageLabel")
    mobileIcon.Name = "Icon"
    mobileIcon.Parent = self.MobileButton
    mobileIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    mobileIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mobileIcon.BackgroundTransparency = 1
    mobileIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    mobileIcon.BorderSizePixel = 0
    mobileIcon.Position = UDim2.new(0.268000007, 0, 0.5, 0)
    mobileIcon.Size = UDim2.new(0, 15, 0, 15)
    mobileIcon.Image = "rbxassetid://17183279677"
    
    -- Initialize tabs
    self.Tabs = {}
    self.ActiveTab = nil
    self.Enabled = true
    
    -- Make UI draggable if specified
    if draggable ~= false then
        self.Container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self.dragging = true
                self.drag_position = input.Position
                self.start_position = self.Container.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        self.dragging = false
                        self.drag_position = nil
                        self.start_position = nil
                    end
                end)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if self.dragging and self.drag_position and self.start_position then
                    local delta = input.Position - self.drag_position
                    local position = UDim2.new(
                        self.start_position.X.Scale, 
                        self.start_position.X.Offset + delta.X, 
                        self.start_position.Y.Scale, 
                        self.start_position.Y.Offset + delta.Y
                    )
                    
                    TweenService:Create(self.Container, TWEEN_INFO.VeryFast, {
                        Position = position
                    }):Play()
                    
                    TweenService:Create(self.Shadow, TWEEN_INFO.VeryFast, {
                        Position = position
                    }):Play()
                end
            end
        end)
    end
    
    -- Toggle UI visibility with Insert key
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            self:ToggleVisibility()
        end
    end)
    
    -- Toggle UI visibility with mobile button
    self.MobileButton.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)
    
    return self
end

-- Toggle UI visibility
function RedGlowUI:ToggleVisibility()
    self.Enabled = not self.Enabled
    
    if self.Enabled then
        self:Open()
    else
        self:Close()
    end
end

-- Open UI
function RedGlowUI:Open()
    self.Container.Visible = true
    self.Shadow.Visible = true
    self.MobileButton.Modal = true
    
    TweenService:Create(self.Container, TWEEN_INFO.Slow, {
        Size = UDim2.new(0, 699, 0, 426)
    }):Play()
    
    TweenService:Create(self.Shadow, TWEEN_INFO.Slow, {
        Size = UDim2.new(0, 776, 0, 509)
    }):Play()
    
    self.MobileState.Text = "Close"
end

-- Close UI
function RedGlowUI:Close()
    TweenService:Create(self.Shadow, TWEEN_INFO.Slow, {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    local mainTween = TweenService:Create(self.Container, TWEEN_INFO.Slow, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    mainTween:Play()
    mainTween.Completed:Connect(function()
        if not self.Enabled then
            self.Container.Visible = false
            self.Shadow.Visible = false
            self.MobileButton.Modal = false
        end
    end)
    
    self.MobileState.Text = "Open"
end

-- Create a new tab
function RedGlowUI:AddTab(name, icon)
    local tab = Instance.new("TextButton")
    tab.Name = "Tab"
    tab.BackgroundColor3 = COLORS.LightBackground
    tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tab.BorderSizePixel = 0
    tab.Size = UDim2.new(0, 174, 0, 40)
    tab.ZIndex = 2
    tab.AutoButtonColor = false
    tab.Font = Enum.Font.SourceSans
    tab.Text = ""
    tab.TextColor3 = Color3.fromRGB(0, 0, 0)
    tab.TextSize = 14
    tab.Parent = self.TabButtons
    
    -- Add corner to tab
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 5)
    tabCorner.Parent = tab
    
    -- Add text label to tab
    local tabText = Instance.new("TextLabel")
    tabText.Parent = tab
    tabText.AnchorPoint = Vector2.new(0.5, 0.5)
    tabText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabText.BackgroundTransparency = 1
    tabText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabText.BorderSizePixel = 0
    tabText.Position = UDim2.new(0.58965224, 0, 0.5, 0)
    tabText.Size = UDim2.new(0, 124, 0, 15)
    tabText.ZIndex = 3
    tabText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    tabText.Text = name
    tabText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabText.TextScaled = true
    tabText.TextSize = 14
    tabText.TextTransparency = 0.3
    tabText.TextWrapped = true
    tabText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add logo to tab
    local tabLogo = Instance.new("ImageLabel")
    tabLogo.Name = "Logo"
    tabLogo.Parent = tab
    tabLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    tabLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabLogo.BackgroundTransparency = 1
    tabLogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabLogo.BorderSizePixel = 0
    tabLogo.Position = UDim2.new(0.130999997, 0, 0.5, 0)
    tabLogo.Size = UDim2.new(0, 17, 0, 17)
    tabLogo.ZIndex = 3
    tabLogo.Image = icon or "rbxassetid://17290697757"
    tabLogo.ImageTransparency = 0.3
    
    -- Add glow to tab
    local tabGlow = Instance.new("ImageLabel")
    tabGlow.Name = "Glow"
    tabGlow.Parent = tab
    tabGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    tabGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabGlow.BackgroundTransparency = 1
    tabGlow.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabGlow.BorderSizePixel = 0
    tabGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    tabGlow.Size = UDim2.new(0, 190, 0, 53)
    tabGlow.Image = "rbxassetid://17290723539"
    tabGlow.ImageTransparency = 1
    
    -- Add fill to tab
    local tabFill = Instance.new("Frame")
    tabFill.Name = "Fill"
    tabFill.Parent = tab
    tabFill.AnchorPoint = Vector2.new(0.5, 0.5)
    tabFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabFill.BackgroundTransparency = 1
    tabFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabFill.BorderSizePixel = 0
    tabFill.Position = UDim2.new(0.5, 0, 0.5, 0)
    tabFill.Size = UDim2.new(0, 174, 0, 40)
    tabFill.ZIndex = 2
    
    -- Add corner to fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = tabFill
    
    -- Add gradient to fill
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, COLORS.Accent),
        ColorSequenceKeypoint.new(1.00, COLORS.AccentDark)
    }
    fillGradient.Rotation = 20
    fillGradient.Parent = tabFill
    
    -- Create left section
    local leftSection = Instance.new("ScrollingFrame")
    leftSection.Name = "LeftSection"
    leftSection.Active = true
    leftSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    leftSection.BackgroundTransparency = 1
    leftSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
    leftSection.BorderSizePixel = 0
    leftSection.Position = UDim2.new(0.326180249, 0, 0.126760557, 0)
    leftSection.Size = UDim2.new(0, 215, 0, 372)
    leftSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    leftSection.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    leftSection.ScrollBarThickness = 0
    leftSection.Parent = self.Container
    
    -- Add list layout to left section
    local leftSectionList = Instance.new("UIListLayout")
    leftSectionList.Parent = leftSection
    leftSectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftSectionList.SortOrder = Enum.SortOrder.LayoutOrder
    leftSectionList.Padding = UDim.new(0, 7)
    
    -- Create right section
    local rightSection = Instance.new("ScrollingFrame")
    rightSection.Name = "RightSection"
    rightSection.Active = true
    rightSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rightSection.BackgroundTransparency = 1
    rightSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
    rightSection.BorderSizePixel = 0
    rightSection.Position = UDim2.new(0.662374794, 0, 0.126760557, 0)
    rightSection.Size = UDim2.new(0, 215, 0, 372)
    rightSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    rightSection.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    rightSection.ScrollBarThickness = 0
    rightSection.Parent = self.Container
    
    -- Add list layout to right section
    local rightSectionList = Instance.new("UIListLayout")
    rightSectionList.Parent = rightSection
    rightSectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rightSectionList.SortOrder = Enum.SortOrder.LayoutOrder
    rightSectionList.Padding = UDim.new(0, 7)
    
    -- Hide sections initially
    if self.Container:FindFirstChild('RightSection') then
        leftSection.Visible = false
        rightSection.Visible = false
    else
        self:SelectTab(name)
    end
    
    -- Tab click handler
    tab.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    -- Store tab data
    self.Tabs[name] = {
        Button = tab,
        LeftSection = leftSection,
        RightSection = rightSection
    }
    
    -- Return tab object for chaining
    return {
        Name = name,
        
        -- Add title to section
        AddTitle = function(self, options)
            local section = options.section == 'left' and leftSection or rightSection
            
            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.AnchorPoint = Vector2.new(0.5, 0.5)
            title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            title.BackgroundTransparency = 1
            title.BorderColor3 = Color3.fromRGB(0, 0, 0)
            title.BorderSizePixel = 0
            title.Position = UDim2.new(0.531395316, 0, 0.139784947, 0)
            title.Size = UDim2.new(0, 201, 0, 15)
            title.ZIndex = 2
            title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextScaled = true
            title.TextSize = 14
            title.TextWrapped = true
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = section
            title.Text = options.name
            
            return self
        end,
        
        -- Add toggle to section
        AddToggle = function(self, options)
            local section = options.section == 'left' and leftSection or rightSection
            
            -- Create toggle container
            local toggle = Instance.new("TextButton")
            toggle.Name = "Toggle"
            toggle.Parent = section
            toggle.BackgroundColor3 = COLORS.LightBackground
            toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            toggle.BorderSizePixel = 0
            toggle.Size = UDim2.new(0, 215, 0, 37)
            toggle.AutoButtonColor = false
            toggle.Font = Enum.Font.SourceSans
            toggle.Text = ""
            toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
            toggle.TextSize = 14
            
            -- Add corner to toggle
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 10)
            toggleCorner.Parent = toggle
            
            -- Create checkbox
            local checkbox = Instance.new("Frame")
            checkbox.Name = "Checkbox"
            checkbox.Parent = toggle
            checkbox.AnchorPoint = Vector2.new(0.5, 0.5)
            checkbox.BackgroundColor3 = COLORS.DarkBackground
            checkbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            checkbox.BorderSizePixel = 0
            checkbox.Position = UDim2.new(0.915, 0, 0.5, 0)
            checkbox.Size = UDim2.new(0, 17, 0, 17)
            
            -- Add corner to checkbox
            local checkboxCorner = Instance.new("UICorner")
            checkboxCorner.CornerRadius = UDim.new(0, 4)
            checkboxCorner.Parent = checkbox
            
            -- Add glow to checkbox
            local checkboxGlow = Instance.new("ImageLabel")
            checkboxGlow.Name = "Glow"
            checkboxGlow.Parent = checkbox
            checkboxGlow.AnchorPoint = Vector2.new(0.5, 0.5)
            checkboxGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            checkboxGlow.BackgroundTransparency = 1
            checkboxGlow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            checkboxGlow.BorderSizePixel = 0
            checkboxGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
            checkboxGlow.Size = UDim2.new(0, 27, 0, 27)
            checkboxGlow.Image = "rbxassetid://17290798394"
            checkboxGlow.ImageTransparency = 1
            
            -- Add fill to checkbox
            local checkboxFill = Instance.new("Frame")
            checkboxFill.Name = "Fill"
            checkboxFill.Parent = checkbox
            checkboxFill.AnchorPoint = Vector2.new(0.5, 0.5)
            checkboxFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            checkboxFill.BackgroundTransparency = 1
            checkboxFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
            checkboxFill.BorderSizePixel = 0
            checkboxFill.Position = UDim2.new(0.5, 0, 0.5, 0)
            checkboxFill.Size = UDim2.new(0, 17, 0, 17)
            
            -- Add corner to fill
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 4)
            fillCorner.Parent = checkboxFill
            
            -- Add gradient to fill
            local fillGradient = Instance.new("UIGradient")
            fillGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, COLORS.Accent),
                ColorSequenceKeypoint.new(1.00, COLORS.AccentDark)
            }
            fillGradient.Rotation = 20
            fillGradient.Parent = checkboxFill
            
            -- Add text label to toggle
            local toggleText = Instance.new("TextLabel")
            toggleText.Parent = toggle
            toggleText.AnchorPoint = Vector2.new(0.5, 0.5)
            toggleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleText.BackgroundTransparency = 1
            toggleText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            toggleText.BorderSizePixel = 0
            toggleText.Position = UDim2.new(0.444953382, 0, 0.5, 0)
            toggleText.Size = UDim2.new(0, 164, 0, 15)
            toggleText.ZIndex = 2
            toggleText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleText.TextScaled = true
            toggleText.TextSize = 14
            toggleText.TextWrapped = true
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.Text = options.name
            
            -- Set up flag
            local flag = options.flag or options.name
            if not self.Flags[flag] then
                self.Flags[flag] = options.default or false
            end
            
            -- Update toggle visuals
            local function updateToggle()
                if self.Flags[flag] then
                    TweenService:Create(checkbox.Fill, TWEEN_INFO.Medium, {
                        BackgroundTransparency = 0
                    }):Play()
                    
                    TweenService:Create(checkbox.Glow, TWEEN_INFO.Medium, {
                        ImageTransparency = 0
                    }):Play()
                else
                    TweenService:Create(checkbox.Fill, TWEEN_INFO.Medium, {
                        BackgroundTransparency = 1
                    }):Play()
                    
                    TweenService:Create(checkbox.Glow, TWEEN_INFO.Medium, {
                        ImageTransparency = 1
                    }):Play()
                end
            end
            
            -- Initial update
            updateToggle()
            
            -- Toggle click handler
            toggle.MouseButton1Click:Connect(function()
                self.Flags[flag] = not self.Flags[flag]
                updateToggle()
                
                if options.callback then
                    options.callback(self.Flags[flag])
                end
            end)
            
            -- Hover effects
            toggle.MouseEnter:Connect(function()
                TweenService:Create(toggle, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.Highlight
                }):Play()
            end)
            
            toggle.MouseLeave:Connect(function()
                TweenService:Create(toggle, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.LightBackground
                }):Play()
            end)
            
            return self
        end,
        
        -- Add slider to section
        AddSlider = function(self, options)
            local section = options.section == 'left' and leftSection or rightSection
            
            -- Create slider container
            local slider = Instance.new("TextButton")
            slider.Name = "Slider"
            slider.BackgroundColor3 = COLORS.LightBackground
            slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
            slider.BorderSizePixel = 0
            slider.Size = UDim2.new(0, 215, 0, 48)
            slider.AutoButtonColor = false
            slider.Font = Enum.Font.SourceSans
            slider.Text = ""
            slider.TextColor3 = Color3.fromRGB(0, 0, 0)
            slider.TextSize = 14
            slider.Parent = section
            
            -- Add corner to slider
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 10)
            sliderCorner.Parent = slider
            
            -- Create slider box
            local sliderBox = Instance.new("Frame")
            sliderBox.Name = "Box"
            sliderBox.Parent = slider
            sliderBox.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderBox.BackgroundColor3 = COLORS.DarkBackground
            sliderBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            sliderBox.BorderSizePixel = 0
            sliderBox.Position = UDim2.new(0.508023143, 0, 0.708333313, 0)
            sliderBox.Size = UDim2.new(0, 192, 0, 6)
            
            -- Add corner to box
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 15)
            boxCorner.Parent = sliderBox
            
            -- Add glow to box
            local boxGlow = Instance.new("ImageLabel")
            boxGlow.Name = "Glow"
            boxGlow.Parent = sliderBox
            boxGlow.AnchorPoint = Vector2.new(0.5, 0.5)
            boxGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            boxGlow.BackgroundTransparency = 1
            boxGlow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            boxGlow.BorderSizePixel = 0
            boxGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
            boxGlow.Size = UDim2.new(0, 204, 0, 17)
            boxGlow.ZIndex = 2
            boxGlow.Image = "rbxassetid://17381990533"
            
            -- Add gradient to glow
            local glowGradient = Instance.new("UIGradient")
            glowGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0.00, 0.00),
                NumberSequenceKeypoint.new(0.50, 0.00),
                NumberSequenceKeypoint.new(0.53, 1.00),
                NumberSequenceKeypoint.new(1.00, 1.00)
            }
            glowGradient.Parent = boxGlow
            
            -- Create fill
            local fill = Instance.new("ImageLabel")
            fill.Name = "Fill"
            fill.Parent = sliderBox
            fill.AnchorPoint = Vector2.new(0, 0.5)
            fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            fill.BackgroundTransparency = 1
            fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
            fill.BorderSizePixel = 0
            fill.Position = UDim2.new(0, 0, 0.5, 0)
            fill.Size = UDim2.new(0, 192, 0, 6)
            fill.Image = "rbxassetid://17382033116"
            
            -- Add corner to fill
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 4)
            fillCorner.Parent = fill
            
            -- Add gradient to fill
            local fillGradient = Instance.new("UIGradient")
            fillGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0.00, 0.00),
                NumberSequenceKeypoint.new(0.50, 0.00),
                NumberSequenceKeypoint.new(0.50, 1.00),
                NumberSequenceKeypoint.new(1.00, 1.00)
            }
            fillGradient.Parent = fill
            
            -- Create hitbox
            local hitbox = Instance.new("TextButton")
            hitbox.Name = "Hitbox"
            hitbox.Parent = sliderBox
            hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            hitbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hitbox.BackgroundTransparency = 1
            hitbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            hitbox.BorderSizePixel = 0
            hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
            hitbox.Size = UDim2.new(0, 200, 0, 13)
            hitbox.ZIndex = 3
            hitbox.AutoButtonColor = false
            hitbox.Font = Enum.Font.SourceSans
            hitbox.Text = ""
            hitbox.TextColor3 = Color3.fromRGB(0, 0, 0)
            hitbox.TextSize = 14
            
            -- Add text label
            local sliderText = Instance.new("TextLabel")
            sliderText.Parent = slider
            sliderText.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderText.BackgroundTransparency = 1
            sliderText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            sliderText.BorderSizePixel = 0
            sliderText.Position = UDim2.new(0.414720833, 0, 0.375, 0)
            sliderText.Size = UDim2.new(0, 151, 0, 15)
            sliderText.ZIndex = 2
            sliderText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            sliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
            sliderText.TextScaled = true
            sliderText.TextSize = 14
            sliderText.TextWrapped = true
            sliderText.TextXAlignment = Enum.TextXAlignment.Left
            sliderText.Text = options.name
            
            -- Add number display
            local numberDisplay = Instance.new("TextLabel")
            numberDisplay.Name = "Number"
            numberDisplay.Parent = slider
            numberDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
            numberDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            numberDisplay.BackgroundTransparency = 1
            numberDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
            numberDisplay.BorderSizePixel = 0
            numberDisplay.Position = UDim2.new(0.854255736, 0, 0.375, 0)
            numberDisplay.Size = UDim2.new(0, 38, 0, 15)
            numberDisplay.ZIndex = 2
            numberDisplay.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            numberDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
            numberDisplay.TextScaled = true
            numberDisplay.TextSize = 14
            numberDisplay.TextWrapped = true
            numberDisplay.TextXAlignment = Enum.TextXAlignment.Right
            
            -- Set up flag
            local flag = options.flag or options.name
            local min = options.min or 0
            local max = options.max or 100
            local default = options.default or min
            
            if not self.Flags[flag] then
                self.Flags[flag] = default
            end
            
            numberDisplay.Text = tostring(self.Flags[flag])
            
            -- Update slider function
            local function updateSlider(value)
                local percent = (value - min) / (max - min)
                
                -- Update fill gradient
                fillGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0.00, 0.00),
                    NumberSequenceKeypoint.new(percent, 0.00),
                    NumberSequenceKeypoint.new(math.min(percent + 0.001, 1), 1.00),
                    NumberSequenceKeypoint.new(1.00, 1.00)
                }
                
                -- Update glow gradient
                glowGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0.00, 0.00),
                    NumberSequenceKeypoint.new(percent, 0.00),
                    NumberSequenceKeypoint.new(math.min(percent + 0.03, 1), 1.00),
                    NumberSequenceKeypoint.new(1.00, 1.00)
                }
                
                -- Update number display
                numberDisplay.Text = tostring(value)
                
                -- Update flag
                self.Flags[flag] = value
                
                -- Call callback
                if options.callback then
                    options.callback(value)
                end
            end
            
            -- Initial update
            updateSlider(self.Flags[flag])
            
            -- Slider drag functionality
            local isDragging = false
            
            hitbox.MouseButton1Down:Connect(function()
                isDragging = true
                
                -- Update slider based on mouse position
                local function update()
                    if not isDragging then return end
                    
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = mousePos.X - sliderBox.AbsolutePosition.X
                    local percent = math.clamp(relativePos / sliderBox.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * percent)
                    
                    updateSlider(value)
                end
                
                -- Connect to RenderStepped for smooth updates
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    update()
                end)
                
                -- Disconnect when mouse button is released
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        if connection then
                            connection:Disconnect()
                        end
                    end
                end)
                
                update()
            end)
            
            -- Hover effects
            slider.MouseEnter:Connect(function()
                TweenService:Create(slider, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.Highlight
                }):Play()
            end)
            
            slider.MouseLeave:Connect(function()
                TweenService:Create(slider, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.LightBackground
                }):Play()
            end)
            
            return self
        end,
        
        -- Add dropdown to section
        AddDropdown = function(self, options)
            local section = options.section == 'left' and leftSection or rightSection
            
            -- Create dropdown container
            local dropdown = Instance.new("TextButton")
            dropdown.Parent = section
            dropdown.Name = "Dropdown"
            dropdown.BackgroundColor3 = COLORS.LightBackground
            dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
            dropdown.BorderSizePixel = 0
            dropdown.Size = UDim2.new(0, 215, 0, 36)
            dropdown.AutoButtonColor = false
            dropdown.Font = Enum.Font.SourceSans
            dropdown.Text = ""
            dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
            dropdown.TextSize = 14
            
            -- Add corner to dropdown
            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 10)
            dropdownCorner.Parent = dropdown
            
            -- Add list layout
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = dropdown
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            -- Add padding
            local padding = Instance.new("UIPadding")
            padding.Parent = dropdown
            padding.PaddingTop = UDim.new(0, 6)
            
            -- Create box
            local box = Instance.new("Frame")
            box.Name = "Box"
            box.Parent = dropdown
            box.AnchorPoint = Vector2.new(0.5, 0)
            box.BackgroundColor3 = COLORS.DarkBackground
            box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            box.BorderSizePixel = 0
            box.Position = UDim2.new(0.5, 0, 0.15, 0)
            box.Size = UDim2.new(0, 202, 0, 25)
            box.ZIndex = 2
            
            -- Add corner to box
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 6)
            boxCorner.Parent = box
            
            -- Create options container
            local optionsContainer = Instance.new("Frame")
            optionsContainer.Name = "Options"
            optionsContainer.Parent = box
            optionsContainer.AnchorPoint = Vector2.new(0.5, 0)
            optionsContainer.BackgroundColor3 = COLORS.DarkBackground
            optionsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
            optionsContainer.BorderSizePixel = 0
            optionsContainer.ClipsDescendants = true
            optionsContainer.Position = UDim2.new(0.5, 0, 0.76, 0)
            optionsContainer.Size = UDim2.new(0, 202, 0, 0)
            
            -- Add corner to options container
            local optionsCorner = Instance.new("UICorner")
            optionsCorner.CornerRadius = UDim.new(0, 6)
            optionsCorner.Parent = optionsContainer
            
            -- Add padding to options container
            local optionsPadding = Instance.new("UIPadding")
            optionsPadding.Parent = optionsContainer
            optionsPadding.PaddingLeft = UDim.new(0, 15)
            optionsPadding.PaddingTop = UDim.new(0, 10)
            
            -- Add list layout to options container
            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Parent = optionsContainer
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Padding = UDim.new(0, 10)
            
            -- Add text label
            local boxText = Instance.new("TextLabel")
            boxText.Parent = box
            boxText.AnchorPoint = Vector2.new(0.5, 0.5)
            boxText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            boxText.BackgroundTransparency = 1
            boxText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            boxText.BorderSizePixel = 0
            boxText.Position = UDim2.new(0.43, 0, 0.5, 0)
            boxText.Size = UDim2.new(0, 151, 0, 13)
            boxText.ZIndex = 2
            boxText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            boxText.TextColor3 = Color3.fromRGB(255, 255, 255)
            boxText.TextScaled = true
            boxText.TextSize = 14
            boxText.TextWrapped = true
            boxText.TextXAlignment = Enum.TextXAlignment.Left
            boxText.Text = options.name
            
            -- Add arrow
            local arrow = Instance.new("ImageLabel")
            arrow.Name = "Arrow"
            arrow.Parent = box
            arrow.Active = true
            arrow.AnchorPoint = Vector2.new(0.5, 0.5)
            arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            arrow.BackgroundTransparency = 1
            arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            arrow.BorderSizePixel = 0
            arrow.Position = UDim2.new(0.92, 0, 0.5, 0)
            arrow.Size = UDim2.new(0, 12, 0, 12)
            arrow.ZIndex = 2
            arrow.Image = "rbxassetid://17400678941"
            
            -- Set up flag
            local flag = options.flag or options.name
            local defaultOption = options.default or (options.options and options.options[1]) or ""
            
            if not self.Flags[flag] then
                self.Flags[flag] = defaultOption
            end
            
            -- Create option template
            local function createOption(optionText)
                local option = Instance.new("TextButton")
                option.Name = "Option"
                option.Active = false
                option.AnchorPoint = Vector2.new(0.5, 0.5)
                option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                option.BackgroundTransparency = 1
                option.BorderColor3 = Color3.fromRGB(0, 0, 0)
                option.BorderSizePixel = 0
                option.Position = UDim2.new(0.47283414, 0, 0.309523821, 0)
                option.Selectable = false
                option.Size = UDim2.new(0, 176, 0, 13)
                option.ZIndex = 2
                option.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                option.TextColor3 = Color3.fromRGB(255, 255, 255)
                option.TextScaled = true
                option.TextSize = 14
                option.TextTransparency = optionText == self.Flags[flag] and 0 or 0.5
                option.TextWrapped = true
                option.TextXAlignment = Enum.TextXAlignment.Left
                option.Text = optionText
                option.Parent = optionsContainer
                
                -- Option click handler
                option.MouseButton1Click:Connect(function()
                    -- Update flag
                    self.Flags[flag] = optionText
                    
                    -- Update text
                    boxText.Text = optionText
                    
                    -- Update option transparency
                    for _, child in pairs(optionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            TweenService:Create(child, TWEEN_INFO.Medium, {
                                TextTransparency = child.Text == optionText and 0 or 0.5
                            }):Play()
                        end
                    end
                    
                    -- Close dropdown
                    toggleDropdown(false)
                    
                    -- Call callback
                    if options.callback then
                        options.callback(optionText)
                    end
                end)
                
                return option
            end
            
            -- Populate options
            if options.options then
                for _, optionText in ipairs(options.options) do
                    createOption(optionText)
                end
            end
            
            -- Toggle dropdown function
            local isOpen = false
            local function toggleDropdown(state)
                isOpen = state ~= nil and state or not isOpen
                
                if isOpen then
                    -- Calculate options height
                    local optionsHeight = 0
                    for _, child in pairs(optionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            optionsHeight = optionsHeight + child.AbsoluteSize.Y + 10
                        end
                    end
                    
                    -- Open dropdown
                    TweenService:Create(dropdown, TWEEN_INFO.Medium, {
                        Size = UDim2.new(0, 215, 0, 36 + optionsHeight)
                    }):Play()
                    
                    TweenService:Create(optionsContainer, TWEEN_INFO.Medium, {
                        Size = UDim2.new(0, 202, 0, optionsHeight)
                    }):Play()
                    
                    TweenService:Create(arrow, TWEEN_INFO.Medium, {
                        Rotation = 180
                    }):Play()
                    
                    -- Update text
                    boxText.Text = self.Flags[flag]
                else
                    -- Close dropdown
                    TweenService:Create(dropdown, TWEEN_INFO.Medium, {
                        Size = UDim2.new(0, 215, 0, 36)
                    }):Play()
                    
                    TweenService:Create(optionsContainer, TWEEN_INFO.Medium, {
                        Size = UDim2.new(0, 202, 0, 0)
                    }):Play()
                    
                    TweenService:Create(arrow, TWEEN_INFO.Medium, {
                        Rotation = 0
                    }):Play()
                    
                    -- Update text
                    boxText.Text = options.name
                end
            end
            
            -- Dropdown click handler
            dropdown.MouseButton1Click:Connect(function()
                toggleDropdown()
            end)
            
            -- Hover effects
            dropdown.MouseEnter:Connect(function()
                TweenService:Create(dropdown, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.Highlight
                }):Play()
            end)
            
            dropdown.MouseLeave:Connect(function()
                TweenService:Create(dropdown, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.LightBackground
                }):Play()
            end)
            
            return self
        end,
        
        -- Add textbox to section
        AddTextbox = function(self, options)
            local section = options.section == 'left' and leftSection or rightSection
            
            -- Create textbox container
            local textbox = Instance.new("TextButton")
            textbox.Name = "TextBox"
            textbox.BackgroundColor3 = COLORS.LightBackground
            textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            textbox.BorderSizePixel = 0
            textbox.Size = UDim2.new(0, 215, 0, 36)
            textbox.AutoButtonColor = false
            textbox.Font = Enum.Font.SourceSans
            textbox.Text = ""
            textbox.TextColor3 = Color3.fromRGB(0, 0, 0)
            textbox.TextSize = 14
            textbox.Parent = section
            
            -- Add corner to textbox
            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 10)
            textboxCorner.Parent = textbox
            
            -- Add list layout
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = textbox
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            -- Add padding
            local padding = Instance.new("UIPadding")
            padding.Parent = textbox
            padding.PaddingTop = UDim.new(0, 6)
            
            -- Create box
            local box = Instance.new("Frame")
            box.Name = "Box"
            box.Parent = textbox
            box.AnchorPoint = Vector2.new(0.5, 0)
            box.BackgroundColor3 = COLORS.DarkBackground
            box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            box.BorderSizePixel = 0
            box.Position = UDim2.new(0.5, 0, 0.15, 0)
            box.Size = UDim2.new(0, 202, 0, 25)
            box.ZIndex = 2
            
            -- Add corner to box
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 6)
            boxCorner.Parent = box
            
            -- Create text holder
            local textHolder = Instance.new("TextBox")
            textHolder.Name = "TextHolder"
            textHolder.Parent = box
            textHolder.BackgroundColor3 = COLORS.DarkBackground
            textHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
            textHolder.BorderSizePixel = 0
            textHolder.Position = UDim2.new(0.0445544571, 0, 0.24, 0)
            textHolder.Size = UDim2.new(0, 182, 0, 13)
            textHolder.ZIndex = 2
            textHolder.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            textHolder.Text = ""
            textHolder.PlaceholderText = options.placeholder or options.name
            textHolder.TextColor3 = Color3.fromRGB(255, 255, 255)
            textHolder.TextSize = 14
            textHolder.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Set up flag
            local flag = options.flag or options.name
            local defaultValue = options.default or ""
            
            if not self.Flags[flag] then
                self.Flags[flag] = defaultValue
            end
            
            -- Set initial text
            textHolder.Text = self.Flags[flag]
            
            -- Text changed handler
            textHolder.FocusLost:Connect(function(enterPressed)
                -- Update flag
                self.Flags[flag] = textHolder.Text
                
                -- Call callback
                if options.callback then
                    options.callback(textHolder.Text, enterPressed)
                end
            end)
            
            -- Hover effects
            textbox.MouseEnter:Connect(function()
                TweenService:Create(textbox, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.Highlight
                }):Play()
            end)
            
            textbox.MouseLeave:Connect(function()
                TweenService:Create(textbox, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.LightBackground
                }):Play()
            end)
            
            return self
        end,
        
        -- Add keybind to section
        AddKeybind = function(self, options)
            local section = options.section == 'left' and leftSection or rightSection
            
            -- Create keybind container
            local keybind = Instance.new("TextButton")
            keybind.Name = "Keybind"
            keybind.BackgroundColor3 = COLORS.LightBackground
            keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
            keybind.BorderSizePixel = 0
            keybind.Position = UDim2.new(-0.0186046511, 0, 0.440860212, 0)
            keybind.Size = UDim2.new(0, 215, 0, 37)
            keybind.AutoButtonColor = false
            keybind.Font = Enum.Font.SourceSans
            keybind.Text = ""
            keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
            keybind.TextSize = 14
            keybind.Parent = section
            
            -- Add corner to keybind
            local keybindCorner = Instance.new("UICorner")
            keybindCorner.CornerRadius = UDim.new(0, 10)
            keybindCorner.Parent = keybind
            
            -- Add text label
            local keybindText = Instance.new("TextLabel")
            keybindText.Parent = keybind
            keybindText.AnchorPoint = Vector2.new(0.5, 0.5)
            keybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            keybindText.BackgroundTransparency = 1
            keybindText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            keybindText.BorderSizePixel = 0
            keybindText.Position = UDim2.new(0.424475819, 0, 0.5, 0)
            keybindText.Size = UDim2.new(0, 155, 0, 15)
            keybindText.ZIndex = 2
            keybindText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            keybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
            keybindText.TextScaled = true
            keybindText.TextSize = 14
            keybindText.TextWrapped = true
            keybindText.TextXAlignment = Enum.TextXAlignment.Left
            keybindText.Text = options.name
            
            -- Create box
            local box = Instance.new("Frame")
            box.Name = "Box"
            box.Parent = keybind
            box.AnchorPoint = Vector2.new(0.5, 0.5)
            box.BackgroundColor3 = COLORS.DarkBackground
            box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            box.BorderSizePixel = 0
            box.Position = UDim2.new(0.875459313, 0, 0.472972959, 0)
            box.Size = UDim2.new(0, 27, 0, 21)
            
            -- Add corner to box
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 4)
            boxCorner.Parent = box
            
            -- Add text label to box
            local boxText = Instance.new("TextLabel")
            boxText.Parent = box
            boxText.AnchorPoint = Vector2.new(0.5, 0.5)
            boxText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            boxText.BackgroundTransparency = 1
            boxText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            boxText.BorderSizePixel = 0
            boxText.Position = UDim2.new(0.630466938, 0, 0.5, 0)
            boxText.Size = UDim2.new(0, 29, 0, 15)
            boxText.ZIndex = 2
            boxText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            boxText.TextColor3 = Color3.fromRGB(255, 255, 255)
            boxText.TextScaled = true
            boxText.TextSize = 14
            boxText.TextWrapped = true
            
            -- Set up flag
            local flag = options.flag or options.name
            local defaultKey = options.default or Enum.KeyCode.Unknown
            
            if not self.Flags[flag] then
                self.Flags[flag] = typeof(defaultKey) == "EnumItem" and defaultKey.Name or defaultKey
            end
            
            -- Set initial text
            boxText.Text = self.Flags[flag]
            
            -- Listening state
            local listening = false
            
            -- Keybind click handler
            keybind.MouseButton1Click:Connect(function()
                listening = true
                boxText.Text = "..."
                
                -- Wait for key press
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        -- Update flag
                        self.Flags[flag] = input.KeyCode.Name
                        
                        -- Update text
                        boxText.Text = input.KeyCode.Name
                        
                        -- Call callback
                        if options.callback then
                            options.callback(input.KeyCode)
                        end
                        
                        -- Stop listening
                        listening = false
                        connection:Disconnect()
                    end
                end)
            end)
            
            -- Key press handler
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == self.Flags[flag] then
                    -- Call callback
                    if options.callback then
                        options.callback(input.KeyCode)
                    end
                end
            end)
            
            -- Hover effects
            keybind.MouseEnter:Connect(function()
                TweenService:Create(keybind, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.Highlight
                }):Play()
            end)
            
            keybind.MouseLeave:Connect(function()
                TweenService:Create(keybind, TWEEN_INFO.Fast, {
                    BackgroundColor3 = COLORS.LightBackground
                }):Play()
            end)
            
            return self
        end
    }
end

-- Select a tab
function RedGlowUI:SelectTab(name)
    -- Get tab data
    local tab = self.Tabs[name]
    if not tab then return end
    
    -- Hide all sections
    for _, tabData in pairs(self.Tabs) do
        if tabData.LeftSection then
            tabData.LeftSection.Visible = false
        end
        
        if tabData.RightSection then
            tabData.RightSection.Visible = false
        end
        
        -- Reset tab visuals
        if tabData.Button then
            TweenService:Create(tabData.Button.Fill, TWEEN_INFO.Medium, {
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(tabData.Button.Glow, TWEEN_INFO.Medium, {
                ImageTransparency = 1
            }):Play()
            
            TweenService:Create(tabData.Button.TextLabel, TWEEN_INFO.Medium, {
                TextTransparency = 0.5
            }):Play()
            
            TweenService:Create(tabData.Button.Logo, TWEEN_INFO.Medium, {
                ImageTransparency = 0.5
            }):Play()
        end
    end
    
    -- Show selected tab sections
    tab.LeftSection.Visible = true
    tab.RightSection.Visible = true
    
    -- Update tab visuals
    TweenService:Create(tab.Button.Fill, TWEEN_INFO.Medium, {
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(tab.Button.Glow, TWEEN_INFO.Medium, {
        ImageTransparency = 0
    }):Play()
    
    TweenService:Create(tab.Button.TextLabel, TWEEN_INFO.Medium, {
        TextTransparency = 0
    }):Play()
    
    TweenService:Create(tab.Button.Logo, TWEEN_INFO.Medium, {
        ImageTransparency = 0
    }):Play()
    
    -- Set active tab
    self.ActiveTab = name
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

-- Save flags
function RedGlowUI:SaveFlags()
    -- Create folder if it doesn't exist
    if not isfolder("RedGlowUI") then
        makefolder("RedGlowUI")
    end
    
    -- Save flags to file
    local success, result = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(self.Flags)
        writefile("RedGlowUI/" .. game.PlaceId .. ".json", json)
    end)
    
    return success
end

-- Load flags
function RedGlowUI:LoadFlags()
    -- Check if file exists
    if not isfile("RedGlowUI/" .. game.PlaceId .. ".json") then
        return false
    end
    
    -- Load flags from file
    local success, result = pcall(function()
        local json = readfile("RedGlowUI/" .. game.PlaceId .. ".json")
        local flags = game:GetService("HttpService"):JSONDecode(json)
        
        -- Update flags
        for flag, value in pairs(flags) do
            self.Flags[flag] = value
        end
    end)
    
    return success
end

-- Return the library
return RedGlowUI
