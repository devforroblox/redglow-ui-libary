-- Load the library
local RedGlowUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/devforroblox/redglow-ui-libary/refs/heads/main/source.lua"))()

-- Create a new UI window
local UI = RedGlowUI.new("My Cool UI", true) -- Title, Draggable

-- Create tabs
local mainTab = UI:AddTab("Main")
local settingsTab = UI:AddTab("Settings")

-- Create sections
local generalSection = mainTab:AddSection("General")
local playerSection = mainTab:AddSection("Player")
local configSection = settingsTab:AddSection("Configuration")

-- Add UI elements
generalSection:AddLabel("Welcome to RedGlow UI!")

generalSection:AddButton("Click Me", function()
    print("Button clicked!")
    UI:CreateNotification("Success", "Button clicked successfully!", 3, "success")
end)

playerSection:AddToggle("Fly", false, function(value)
    print("Fly toggled:", value)
end)

playerSection:AddSlider("Speed", 0, 100, 50, function(value)
    print("Speed set to:", value)
end)

configSection:AddTextbox("Username", "Enter username...", "", function(text)
    print("Username set to:", text)
end)

configSection:AddDropdown("Theme", {"Dark", "Light", "Custom"}, "Dark", function(option)
    print("Theme set to:", option)
end)

configSection:AddColorPicker("Accent Color", Color3.fromRGB(255, 50, 50), function(color)
    print("Color picked:", color)
end)

configSection:AddKeybind("Toggle UI", Enum.KeyCode.RightControl, function(key)
    print("Keybind pressed:", key.Name)
end)

-- Create a notification
UI:CreateNotification("Success", "UI has been loaded successfully!", 5, "success")
