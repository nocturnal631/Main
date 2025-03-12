-- Frosty Library v1.2.0
local Frosty = {
    Windows = {},
    Theme = {
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(100, 190, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(175, 175, 175),
        Success = Color3.fromRGB(85, 255, 127),
        Error = Color3.fromRGB(255, 85, 85),
        Warning = Color3.fromRGB(255, 235, 59),
        Info = Color3.fromRGB(100, 181, 246),
        BorderColor = Color3.fromRGB(40, 40, 40),
        SliderBackground = Color3.fromRGB(35, 35, 35),
        DropdownBackground = Color3.fromRGB(35, 35, 35),
        InputBackground = Color3.fromRGB(35, 35, 35),
        ButtonBackground = Color3.fromRGB(45, 45, 45),
        SectionBackground = Color3.fromRGB(35, 35, 35),
    },
    Config = {
        CornerRadius = UDim.new(0, 6),
        FontSize = Enum.FontSize.Size14,
        Font = Enum.Font.Gotham,
        SmoothDragging = true,
        UseAcrylic = true,
        AnimationDuration = 0.2,
        TooltipDelay = 0.5,
        RippleEffect = true,
    },
    Icons = {
        Settings = "rbxassetid://3926307971",
        Close = "rbxassetid://6031094678",
        Minimize = "rbxassetid://6031090990",
        Toggle = "rbxassetid://3926305904",
        Dropdown = "rbxassetid://6031086173",
        Warning = "rbxassetid://6031082533",
        Info = "rbxassetid://6031068433",
        Success = "rbxassetid://6031068426",
        Error = "rbxassetid://6031071057",
    },
    Connections = {},
    Windows = {},
    Signals = {},
    ActiveTooltip = nil,
    Version = "1.2.0",
}

-- Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Local Player & Utils
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility Functions
function Frosty.Utils = {}

function Frosty.Utils.CreateTween(instance, duration, properties, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, style, direction),
        properties
    )
    
    return tween
end

function Frosty.Utils.CreateRipple(parent)
    if not Frosty.Config.RippleEffect then return end
    
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    Frosty.Utils.CreateTween(ripple, 0.5, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Frosty.Utils.Round(number, decimalPlaces)
    local multiplier = 10 ^ (decimalPlaces or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function Frosty.Utils.MakeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        if not Frosty.Config.SmoothDragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        else
            local delta = input.Position - dragStart
            local targetPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Frosty.Utils.CreateTween(frame, 0.1, {Position = targetPosition}, Enum.EasingStyle.Linear):Play()
        end
    end
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Frosty.Utils.CreateStroke(instance, transparency, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.Color = color or Frosty.Theme.BorderColor
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function Frosty.Utils.CreateShadow(instance, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, size or 30, 1, size or 30)
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageTransparency = transparency or 0.5
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = instance.ZIndex - 1
    shadow.Parent = instance
    return shadow
end

function Frosty.Utils.CreateTooltip(text)
    if Frosty.ActiveTooltip then
        Frosty.ActiveTooltip:Destroy()
        Frosty.ActiveTooltip = nil
    end
    
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 200, 0, 36)
    tooltip.Position = UDim2.new(0, Mouse.X + 15, 0, Mouse.Y - 10)
    tooltip.BackgroundColor3 = Frosty.Theme.Background
    tooltip.BackgroundTransparency = 0.1
    tooltip.ZIndex = 100
    tooltip.Visible = true
    tooltip.Parent = CoreGui.FrostyLibrary
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = Frosty.Config.CornerRadius
    corner.Parent = tooltip
    
    Frosty.Utils.CreateStroke(tooltip, 0, 1)
    Frosty.Utils.CreateShadow(tooltip, 20, 0.7)
    
    local label = Instance.new("TextLabel")
    label.Name = "TooltipText"
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Frosty.Theme.TextColor
    label.TextSize = 14
    label.Font = Frosty.Config.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 101
    label.Parent = tooltip
    
    -- Auto-size tooltip
    local textSize = TextService:GetTextSize(text, 14, Frosty.Config.Font, Vector2.new(400, 36))
    tooltip.Size = UDim2.new(0, textSize.X + 30, 0, 36)
    
    tooltip.Position = UDim2.new(0, Mouse.X + 15, 0, Mouse.Y - 15)
    
    -- Set active tooltip
    Frosty.ActiveTooltip = tooltip
    
    -- Follow mouse
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not Frosty.ActiveTooltip then
            connection:Disconnect()
            return
        end
        
        tooltip.Position = UDim2.new(0, Mouse.X + 15, 0, Mouse.Y - 15)
        
        -- Boundary check
        local overX = (Mouse.X + tooltip.AbsoluteSize.X + 15) - workspace.CurrentCamera.ViewportSize.X
        if overX > 0 then
            tooltip.Position = UDim2.new(0, Mouse.X - tooltip.AbsoluteSize.X - 5, 0, Mouse.Y - 15)
        end
    end)
    
    return tooltip
end

function Frosty.new(title, config)
    config = config or {}
    
    -- Set config values from input
    for key, value in pairs(config) do
        if Frosty.Config[key] ~= nil then
            Frosty.Config[key] = value
        end
    end
    
    -- Main GUI
    local FrostyGui = Instance.new("ScreenGui")
    FrostyGui.Name = "FrostyLibrary"
    FrostyGui.ResetOnSpawn = false
    FrostyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FrostyGui.IgnoreGuiInset = true
    
    -- Set Parent
    if syn and syn.protect_gui then
        syn.protect_gui(FrostyGui)
        FrostyGui.Parent = game.CoreGui
    elseif gethui then
        FrostyGui.Parent = gethui()
    else
        FrostyGui.Parent = CoreGui
    end
    
    -- Acrylic Effect Background
    local acrylicBg
    if Frosty.Config.UseAcrylic then
        acrylicBg = Instance.new("Frame")
        acrylicBg.Name = "Acrylic"
        acrylicBg.Size = UDim2.new(1, 0, 1, 0)
        acrylicBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        acrylicBg.BackgroundTransparency = 0.95
        acrylicBg.BorderSizePixel = 0
        acrylicBg.Visible = false
        acrylicBg.ZIndex = 0
        acrylicBg.Parent = FrostyGui
        
        local blurEffect = Instance.new("BlurEffect")
        blurEffect.Size = 10
        blurEffect.Parent = game:GetService("Lighting")
        
        -- Remove blur on cleanup
        Frosty.Connections[#Frosty.Connections + 1] = FrostyGui.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                blurEffect:Destroy()
            end
        end)
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
    MainFrame.BackgroundColor3 = Frosty.Theme.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = FrostyGui
    
    -- Add corner radius
    local cornerMain = Instance.new("UICorner")
    cornerMain.CornerRadius = Frosty.Config.CornerRadius
    cornerMain.Parent = MainFrame
    
    -- Add shadow
    Frosty.Utils.CreateShadow(MainFrame, 40, 0.5)
    
    -- Add stroke
    Frosty.Utils.CreateStroke(MainFrame, 0, 1.5)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Frosty.Theme.Foreground
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = TitleBar
    
    -- Title Bar Bottom Cover (to remove bottom rounded corners)
    local titleBarBottomCover = Instance.new("Frame")
    titleBarBottomCover.Name = "BottomCover"
    titleBarBottomCover.Size = UDim2.new(1, 0, 0, 10)
    titleBarBottomCover.Position = UDim2.new(0, 0, 1, -10)
    titleBarBottomCover.BackgroundColor3 = Frosty.Theme.Foreground
    titleBarBottomCover.BorderSizePixel = 0
    titleBarBottomCover.ZIndex = TitleBar.ZIndex
    titleBarBottomCover.Parent = TitleBar
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -150, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Frosty Library"
    TitleLabel.TextColor3 = Frosty.Theme.TextColor
    TitleLabel.TextSize = 18
    TitleLabel.Font = Frosty.Config.Font
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("ImageButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -35, 0, 8)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Image = Frosty.Icons.Close
    CloseButton.ImageColor3 = Frosty.Theme.TextColor
    CloseButton.ImageTransparency = 0.2
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseEnter:Connect(function()
        Frosty.Utils.CreateTween(CloseButton, 0.2, {ImageColor3 = Frosty.Theme.Error}):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Frosty.Utils.CreateTween(CloseButton, 0.2, {ImageColor3 = Frosty.Theme.TextColor}):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Frosty.Utils.CreateRipple(CloseButton)
        Frosty.Utils.CreateTween(MainFrame, 0.3, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 0)}):Play()
        Frosty.Utils.CreateTween(MainFrame, 0.3, {BackgroundTransparency = 1}):Play()
        
        if Frosty.Config.UseAcrylic then
            Frosty.Utils.CreateTween(acrylicBg, 0.3, {BackgroundTransparency = 1}):Play()
        end
        
        task.delay(0.3, function()
            FrostyGui:Destroy()
            
            -- Clean up connections
            for _, connection in ipairs(Frosty.Connections) do
                connection:Disconnect()
            end
        end)
    end)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("ImageButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
    MinimizeButton.Position = UDim2.new(1, -70, 0, 8)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Image = Frosty.Icons.Minimize
    MinimizeButton.ImageColor3 = Frosty.Theme.TextColor
    MinimizeButton.ImageTransparency = 0.2
    MinimizeButton.Parent = TitleBar
    
    MinimizeButton.MouseEnter:Connect(function()
        Frosty.Utils.CreateTween(MinimizeButton, 0.2, {ImageColor3 = Frosty.Theme.Accent}):Play()
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        Frosty.Utils.CreateTween(MinimizeButton, 0.2, {ImageColor3 = Frosty.Theme.TextColor}):Play()
    end)
    
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        Frosty.Utils.CreateRipple(MinimizeButton)
        minimized = not minimized
        
        if minimized then
            Frosty.Utils.CreateTween(MainFrame, 0.3, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 40)}):Play()
        else
            Frosty.Utils.CreateTween(MainFrame, 0.3, {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 450)}):Play()
        end
    end)
    
    -- Settings Button
    local SettingsButton = Instance.new("ImageButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Size = UDim2.new(0, 24, 0, 24)
    SettingsButton.Position = UDim2.new(1, -105, 0, 8)
    SettingsButton.BackgroundTransparency = 1
    SettingsButton.Image = Frosty.Icons.Settings
    SettingsButton.ImageColor3 = Frosty.Theme.TextColor
    SettingsButton.ImageTransparency = 0.2
    SettingsButton.Parent = TitleBar
    
    SettingsButton.MouseEnter:Connect(function()
        Frosty.Utils.CreateTween(SettingsButton, 0.2, {ImageColor3 = Frosty.Theme.Accent}):Play()
    end)
    
    SettingsButton.MouseLeave:Connect(function()
        Frosty.Utils.CreateTween(SettingsButton, 0.2, {ImageColor3 = Frosty.Theme.TextColor}):Play()
    end)
    
    -- Make the window draggable
    Frosty.Utils.MakeDraggable(MainFrame, TitleBar)
    
    -- Tabs Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundColor3 = Frosty.Theme.Foreground
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- Tab List
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer
    
    -- Tab Padding
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingRight = UDim.new(0, 5)
    TabPadding.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -160, 1, -50)
    ContentContainer.Position = UDim2.new(0, 155, 0, 45)
    ContentContainer.BackgroundColor3 = Frosty.Theme.Background
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    -- Create Tab Selector Indicator
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Name = "TabIndicator"
    TabIndicator.Size = UDim2.new(0, 4, 0, 30)
    TabIndicator.Position = UDim2.new(0, 0, 0, 0)
    TabIndicator.BackgroundColor3 = Frosty.Theme.Accent
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Visible = false
    TabIndicator.Parent = TabContainer
    
    -- Window Object
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        MainFrame = MainFrame,
        ContentContainer = ContentContainer,
        TabContainer = TabContainer,
        TabIndicator = TabIndicator,
        FrostyGui = FrostyGui
    }
    
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Button"
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = Frosty.Theme.Foreground
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = Frosty.Config.CornerRadius
        tabCorner.Parent = TabButton
        
        -- Tab Icon
        local TabIconImage
        if tabIcon then
            TabIconImage = Instance.new("ImageLabel")
            TabIconImage.Name = "TabIcon"
            TabIconImage.Size = UDim2.new(0, 20, 0, 20)
            TabIconImage.Position = UDim2.new(0, 10, 0, 8)
            TabIconImage.BackgroundTransparency = 1
            TabIconImage.Image = tabIcon
            TabIconImage.ImageColor3 = Frosty.Theme.SubTextColor
            TabIconImage.Parent = TabButton
        end
        
        -- Tab Label
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "TabLabel"
        TabLabel.Size = UDim2.new(1, tabIcon and -40 or -20, 1, 0)
        TabLabel.Position = UDim2.new(0, tabIcon and 40 or 15, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.TextColor3 = Frosty.Theme.SubTextColor
        TabLabel.TextSize = 14
        TabLabel.Font = Frosty.Config.Font
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Create the tab content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, -20, 1, -10)
        TabContent.Position = UDim2.new(0, 10, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Frosty.Theme.Accent
        TabContent.ScrollBarImageTransparency = 0.5
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        -- Auto-size the canvas
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 10)
        UIListLayout.FillDirection = Enum.FillDirection.Vertical
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = TabContent
        
        UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Padding
        local UIPadding = Instance.new("UIPadding")
        UIPadding.PaddingTop = UDim.new(0, 10)
        UIPadding.PaddingBottom = UDim.new(0, 10)
        UIPadding.PaddingLeft = UDim.new(0, 10)
        UIPadding.PaddingRight = UDim.new(0, 10)
        UIPadding.Parent = TabContent
        
        -- Tab Button Hover Effect
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= tabName then
                Frosty.Utils.CreateTween(TabButton, 0.2, {BackgroundTransparency = 0.8}):Play()
                if TabIconImage then
                    Frosty.Utils.CreateTween(TabIconImage, 0.2, {ImageColor3 = Frosty.Theme.TextColor}):Play()
                end
                Frosty.Utils.CreateTween(TabLabel, 0.2, {TextColor3 = Frosty.Theme.TextColor}):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= tabName then
                Frosty.Utils.CreateTween(TabButton, 0.2, {BackgroundTransparency = 1}):Play()
                if TabIconImage then
                    Frosty.Utils.CreateTween(TabIconImage, 0.2, {ImageColor3 = Frosty.Theme.SubTextColor}):Play()
                end
                Frosty.Utils.CreateTween(TabLabel, 0.2, {TextColor3 = Frosty.Theme.SubTextColor}):Play()
            end
        end)
        
        -- Tab Button Click
        TabButton.MouseButton1Click:Connect(function()
            Frosty.Utils.CreateRipple(TabButton)
            Window:SelectTab(tabName)
        end)
        
        -- Tab Object
        local Tab = {
            Name = tabName,
            Button = TabButton,
            Content = TabContent,
            Sections = {},
            Elements = {},
        }
        
        -- Create Tab Elements
        
        -- Create Section
        function Tab:CreateSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            local sectionName = sectionConfig.Name or "Section"
            
            local Section = Instance.new("Frame")
            Section.Name = sectionName .. "Section"
            Section.Size = UDim2.new(1, 0, 0, 36) -- Will be resized based on content
            Section.BackgroundColor3 = Frosty.Theme.SectionBackground
            Section.BorderSizePixel = 0
            Section.Parent = TabContent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = Frosty.Config.CornerRadius
            sectionCorner.Parent = Section
            
            -- Add stroke
            Frosty.Utils.CreateStroke(Section, 0.5, 1)
            
            -- Section Title
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Size = UDim2.new(1, -20, 0, 30)
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = Frosty.Theme.TextColor
            SectionTitle.TextSize = 14
            SectionTitle.Font = Frosty.Config.Font
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = Section
            
            -- Section Content
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "SectionContent"
            SectionContent.Size = UDim2.new(1, -20, 0, 0) -- Will be resized based on content
            SectionContent.Position = UDim2.new(0, 10, 0, 30)
            SectionContent.BackgroundTransparency = 1
            SectionContent.BorderSizePixel = 0
            SectionContent.ClipsDescendants = true
            SectionContent.Parent = Section
            
            -- List layout for section content
            local SectionList = Instance.new("UIListLayout")
            SectionList.Padding = UDim.new(0, 8)
            SectionList.FillDirection = Enum.FillDirection.Vertical
            SectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            SectionList.SortOrder = Enum.SortOrder.LayoutOrder
            SectionList.Parent = SectionContent
            
            -- Update section size when content changes
            SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, -20, 0, SectionList.AbsoluteContentSize.Y)
                Section.Size = UDim2.new(1, 0, 0, SectionContent.Size.Y.Offset + 40)
            end)
            
            -- Section methods
            local SectionObject = {
                Instance = Section,
                Content = SectionContent,
                Name = sectionName
            }
            
            function SectionObject:CreateButton(config)
                config = config or {}
                local buttonName = config.Name or "Button"
                local callback = config.Callback or function() end
                local tooltip = config.Tooltip
                
                local Button = Instance.new("TextButton")
                Button.Name = buttonName .. "Button"
                Button.Size = UDim2.new(1, 0, 0, 32)
                Button.BackgroundColor3 = Frosty.Theme.ButtonBackground
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.Parent = SectionContent
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = Frosty.Config.CornerRadius
                buttonCorner.Parent = Button
                
                -- Add stroke
                Frosty.Utils.CreateStroke(Button, 0.9, 1)
                
                -- Button Label
                local ButtonLabel = Instance.new("TextLabel")
                ButtonLabel.Name = "ButtonLabel"
                ButtonLabel.Size = UDim2.new(1, -20, 1, 0)
                ButtonLabel.Position = UDim2.new(0, 10, 0, 0)
                ButtonLabel.BackgroundTransparency = 1
                ButtonLabel.Text = buttonName
                ButtonLabel.TextColor3 = Frosty.Theme.TextColor
                ButtonLabel.TextSize = 14
                ButtonLabel.Font = Frosty.Config.Font
                ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
                ButtonLabel.Parent = Button
                
                -- Button animation
                Button.MouseEnter:Connect(function()
                    if tooltip then
                        local tooltipInstance = Frosty.Utils.CreateTooltip(tooltip)
                    end
                    
                    Frosty.Utils.CreateTween(Button, 0.2, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.ButtonBackground.R * 1.1,
                        Frosty.Theme.ButtonBackground.G * 1.1,
                        Frosty.Theme.ButtonBackground.B * 1.1
                    )}):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    if Frosty.ActiveTooltip then
                        Frosty.ActiveTooltip:Destroy()
                        Frosty.ActiveTooltip = nil
                    end
                    
                    Frosty.Utils.CreateTween(Button, 0.2, {BackgroundColor3 = Frosty.Theme.ButtonBackground}):Play()
                end)
                
                Button.MouseButton1Down:Connect(function()
                    Frosty.Utils.CreateTween(Button, 0.1, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.ButtonBackground.R * 0.9,
                        Frosty.Theme.ButtonBackground.G * 0.9,
                        Frosty.Theme.ButtonBackground.B * 0.9
                    )}):Play()
                end)
                
                Button.MouseButton1Up:Connect(function()
                    Frosty.Utils.CreateTween(Button, 0.1, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.ButtonBackground.R * 1.1,
                        Frosty.Theme.ButtonBackground.G * 1.1,
                        Frosty.Theme.ButtonBackground.B * 1.1
                    )}):Play()
                end)
                
                Button.MouseButton1Click:Connect(function()
                    Frosty.Utils.CreateRipple(Button)
                    callback()
                end)
                
                return {
                    Instance = Button,
                    SetText = function(text)
                        ButtonLabel.Text = text
                    end,
                    SetCallback = function(newCallback)
                        callback = newCallback
                    end
                }
            end
            
            function SectionObject:CreateToggle(config)
                config = config or {}
                local toggleName = config.Name or "Toggle"
                local default = config.Default or false
                local callback = config.Callback or function() end
                local tooltip = config.Tooltip
                
                local Toggle = Instance.new("Frame")
                Toggle.Name = toggleName .. "Toggle"
                Toggle.Size = UDim2.new(1, 0, 0, 32)
                Toggle.BackgroundColor3 = Frosty.Theme.ButtonBackground
                Toggle.BorderSizePixel = 0
                Toggle.Parent = SectionContent
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = Frosty.Config.CornerRadius
                toggleCorner.Parent = Toggle
                
                -- Add stroke
                Frosty.Utils.CreateStroke(Toggle, 0.9, 1)
                
                -- Toggle Label
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = toggleName
                ToggleLabel.TextColor3 = Frosty.Theme.TextColor
                ToggleLabel.TextSize = 14
                ToggleLabel.Font = Frosty.Config.Font
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = Toggle
                
                -- Toggle Button
                local ToggleButton = Instance.new("Frame")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Size = UDim2.new(0, 40, 0, 20)
                ToggleButton.Position = UDim2.new(1, -50, 0, 6)
                ToggleButton.BackgroundColor3 = Frosty.Theme.Error
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Parent = Toggle
                
                local toggleButtonCorner = Instance.new("UICorner")
                toggleButtonCorner.CornerRadius = UDim.new(1, 0)
                toggleButtonCorner.Parent = ToggleButton
                
                -- Toggle Indicator
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Name = "ToggleIndicator"
                ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Parent = ToggleButton
                
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(1, 0)
                indicatorCorner.Parent = ToggleIndicator
                
                -- Make the entire toggle clickable
                local ToggleClickArea = Instance.new("TextButton")
                ToggleClickArea.Name = "ToggleClickArea"
                ToggleClickArea.Size = UDim2.new(1, 0, 1, 0)
                ToggleClickArea.BackgroundTransparency = 1
                ToggleClickArea.Text = ""
                ToggleClickArea.Parent = Toggle
                
                -- Create the toggle object
                local isEnabled = default
                
                -- Function to update toggle state
                local function updateToggle()
                    if isEnabled then
                        Frosty.Utils.CreateTween(ToggleButton, 0.2, {BackgroundColor3 = Frosty.Theme.Success}):Play()
                        Frosty.Utils.CreateTween(ToggleIndicator, 0.2, {Position = UDim2.new(0, 22, 0.5, -8)}):Play()
                    else
                        Frosty.Utils.CreateTween(ToggleButton, 0.2, {BackgroundColor3 = Frosty.Theme.Error}):Play()
                        Frosty.Utils.CreateTween(ToggleIndicator, 0.2, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                    end
                    callback(isEnabled)
                end
                
                -- Set default state
                if default then
                    ToggleButton.BackgroundColor3 = Frosty.Theme.Success
                    ToggleIndicator.Position = UDim2.new(0, 22, 0.5, -8)
                end
                
                -- Toggle animations
                Toggle.MouseEnter:Connect(function()
                    if tooltip then
                        local tooltipInstance = Frosty.Utils.CreateTooltip(tooltip)
                    end
                    
                    Frosty.Utils.CreateTween(Toggle, 0.2, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.ButtonBackground.R * 1.1,
                        Frosty.Theme.ButtonBackground.G * 1.1,
                        Frosty.Theme.ButtonBackground.B * 1.1
                    )}):Play()
                end)
                
                Toggle.MouseLeave:Connect(function()
                    if Frosty.ActiveTooltip then
                        Frosty.ActiveTooltip:Destroy()
                        Frosty.ActiveTooltip = nil
                    end
                    
                    Frosty.Utils.CreateTween(Toggle, 0.2, {BackgroundColor3 = Frosty.Theme.ButtonBackground}):Play()
                end)
                
                ToggleClickArea.MouseButton1Click:Connect(function()
                    Frosty.Utils.CreateRipple(Toggle)
                    isEnabled = not isEnabled
                    updateToggle()
                end)
                
                return {
                    Instance = Toggle,
                    SetValue = function(value)
                        isEnabled = value
                        updateToggle()
                    end,
                    GetValue = function()
                        return isEnabled
                    end,
                    SetCallback = function(newCallback)
                        callback = newCallback
                    end
                }
            end
            
            function SectionObject:CreateSlider(config)
                config = config or {}
                local sliderName = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = math.clamp(config.Default or min, min, max)
                local increment = config.Increment or 1
                local callback = config.Callback or function() end
                local tooltip = config.Tooltip
                local valueSuffix = config.ValueSuffix or ""
                
                local Slider = Instance.new("Frame")
                Slider.Name = sliderName .. "Slider"
                Slider.Size = UDim2.new(1, 0, 0, 50)
                Slider.BackgroundColor3 = Frosty.Theme.ButtonBackground
                Slider.BorderSizePixel = 0
                Slider.Parent = SectionContent
                
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = Frosty.Config.CornerRadius
                sliderCorner.Parent = Slider
                
                -- Add stroke
                Frosty.Utils.CreateStroke(Slider, 0.9, 1)
                
                -- Slider Label
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "SliderLabel"
                SliderLabel.Size = UDim2.new(1, 0, 0, 25)
                SliderLabel.Position = UDim2.new(0, 10, 0, 0)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = sliderName
                SliderLabel.TextColor3 = Frosty.Theme.TextColor
                SliderLabel.TextSize = 14
                SliderLabel.Font = Frosty.Config.Font
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = Slider
                
                -- Slider Value
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Name = "SliderValue"
                SliderValue.Size = UDim2.new(0, 50, 0, 25)
                SliderValue.Position = UDim2.new(1, -60, 0, 0)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(default) .. valueSuffix
                SliderValue.TextColor3 = Frosty.Theme.TextColor
                SliderValue.TextSize = 14
                SliderValue.Font = Frosty.Config.Font
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = Slider
                
                -- Slider Bar
                local SliderBar = Instance.new("Frame")
                SliderBar.Name = "SliderBar"
                SliderBar.Size = UDim2.new(1, -20, 0, 5)
                SliderBar.Position = UDim2.new(0, 10, 0, 35)
                SliderBar.BackgroundColor3 = Frosty.Theme.SliderBackground
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = Slider
                
                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(1, 0)
                sliderBarCorner.Parent = SliderBar
                
                -- Slider Fill
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "SliderFill"
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.BackgroundColor3 = Frosty.Theme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar
                
                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(1, 0)
                sliderFillCorner.Parent = SliderFill
                
                -- Slider Knob
                local SliderKnob = Instance.new("Frame")
                SliderKnob.Name = "SliderKnob"
                SliderKnob.Size = UDim2.new(0, 16, 0, 16)
                SliderKnob.Position = UDim2.new(0, 0, 0.5, -8)
                SliderKnob.BackgroundColor3 = Frosty.Theme.TextColor
                SliderKnob.BorderSizePixel = 0
                SliderKnob.ZIndex = 2
                SliderKnob.Parent = SliderFill
                
                local sliderKnobCorner = Instance.new("UICorner")
                sliderKnobCorner.CornerRadius = UDim.new(1, 0)
                sliderKnobCorner.Parent = SliderKnob
                
                -- Slider Interaction
                local SliderButton = Instance.new("TextButton")
                SliderButton.Name = "SliderButton"
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.BackgroundTransparency = 1
                SliderButton.Text = ""
                SliderButton.Parent = SliderBar
                
                -- Slider Functions
                local value = default
                
                local function updateSlider(newValue)
                    value = math.clamp(newValue, min, max)
                    if increment > 0 then
                        value = math.floor(value / increment + 0.5) * increment
                    end
                    value = Frosty.Utils.Round(value, 2)
                    
                    local percent = (value - min) / (max - min)
                    SliderValue.Text = tostring(value) .. valueSuffix
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(1, -8, 0.5, -8)
                    
                    callback(value)
                end
                
                -- Set default value
                updateSlider(default)
                
                -- Slider interaction
                local isDragging = false
                
                SliderButton.MouseButton1Down:Connect(function()
                    isDragging = true
                    local percentage = math.clamp((Mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    updateSlider(min + ((max - min) * percentage))
                end)
                
                SliderBar.MouseEnter:Connect(function()
                    if tooltip then
                        local tooltipInstance = Frosty.Utils.CreateTooltip(tooltip)
                    end
                    
                    Frosty.Utils.CreateTween(Slider, 0.2, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.ButtonBackground.R * 1.1,
                        Frosty.Theme.ButtonBackground.G * 1.1,
                        Frosty.Theme.ButtonBackground.B * 1.1
                    )}):Play()
                end)
                
                SliderBar.MouseLeave:Connect(function()
                    if Frosty.ActiveTooltip then
                        Frosty.ActiveTooltip:Destroy()
                        Frosty.ActiveTooltip = nil
                    end
                    
                    Frosty.Utils.CreateTween(Slider, 0.2, {BackgroundColor3 = Frosty.Theme.ButtonBackground}):Play()
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        dragInput = input
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                        local percentage = math.clamp((Mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        updateSlider(min + ((max - min) * percentage))
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                return {
                    Instance = Slider,
                    SetValue = function(newValue)
                        updateSlider(newValue)
                    end,
                    GetValue = function()
                        return value
                    end,
                    SetCallback = function(newCallback)
                        callback = newCallback
                    end
                }
            end
            
            function SectionObject:CreateDropdown(config)
                config = config or {}
                local dropdownName = config.Name or "Dropdown"
                local options = config.Options or {}
                local default = config.Default
                local callback = config.Callback or function() end
                local tooltip = config.Tooltip
                local multiSelect = config.MultiSelect or false
                
                -- Set default selection (if not provided but options exist)
                if default == nil and #options > 0 then
                    default = multiSelect and {} or options[1]
                end
                
                -- Create the dropdown
                local Dropdown = Instance.new("Frame")
                Dropdown.Name = dropdownName .. "Dropdown"
                Dropdown.Size = UDim2.new(1, 0, 0, 40)
                Dropdown.BackgroundColor3 = Frosty.Theme.ButtonBackground
                Dropdown.BorderSizePixel = 0
                Dropdown.ClipsDescendants = true
                Dropdown.Parent = SectionContent
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = Frosty.Config.CornerRadius
                dropdownCorner.Parent = Dropdown
                
                -- Add stroke
                Frosty.Utils.CreateStroke(Dropdown, 0.9, 1)
                
                -- Dropdown Label
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Name = "DropdownLabel"
                DropdownLabel.Size = UDim2.new(1, -40, 0, 40)
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = dropdownName
                DropdownLabel.TextColor3 = Frosty.Theme.TextColor
                DropdownLabel.TextSize = 14
                DropdownLabel.Font = Frosty.Config.Font
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = Dropdown
                
                -- Selected Value
                local SelectedValue = Instance.new("TextLabel")
                SelectedValue.Name = "SelectedValue"
                SelectedValue.Size = UDim2.new(0, 100, 0, 40)
                SelectedValue.Position = UDim2.new(1, -120, 0, 0)
                SelectedValue.BackgroundTransparency = 1
                SelectedValue.TextColor3 = Frosty.Theme.SubTextColor
                SelectedValue.TextSize = 14
                SelectedValue.Font = Frosty.Config.Font
                SelectedValue.TextXAlignment = Enum.TextXAlignment.Right
                SelectedValue.TextTruncate = Enum.TextTruncate.AtEnd
                SelectedValue.Parent = Dropdown
                
                -- Dropdown Arrow
                local DropdownArrow = Instance.new("ImageLabel")
                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
                DropdownArrow.Position = UDim2.new(1, -30, 0, 10)
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Image = Frosty.Icons.Dropdown
                DropdownArrow.ImageColor3 = Frosty.Theme.TextColor
                DropdownArrow.Rotation = 0
                DropdownArrow.Parent = Dropdown
                
                -- Dropdown Button
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Size = UDim2.new(1, 0, 0, 40)
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Text = ""
                DropdownButton.Parent = Dropdown
                
                -- Dropdown Container
                local OptionContainer = Instance.new("Frame")
                OptionContainer.Name = "OptionContainer"
                OptionContainer.Size = UDim2.new(1, -20, 0, 0) -- Will be sized based on options
                OptionContainer.Position = UDim2.new(0, 10, 0, 45)
                OptionContainer.BackgroundTransparency = 1
                OptionContainer.BorderSizePixel = 0
                OptionContainer.Visible = false
                OptionContainer.Parent = Dropdown
                
                -- Option List Layout
                local optionListLayout = Instance.new("UIListLayout")
                optionListLayout.Padding = UDim.new(0, 5)
                optionListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                optionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionListLayout.Parent = OptionContainer
                
                -- Get total option container height
                local function getContainerHeight()
                    return optionListLayout.AbsoluteContentSize.Y
                end
                
                -- Add options
                local optionButtons = {}
                local selectedOptions = multiSelect and {} or nil
                
                -- Update selection display text
                local function updateSelectionText()
                    if multiSelect then
                        local selectedCount = 0
                        for _ in pairs(selectedOptions) do
                            selectedCount = selectedCount + 1
                        end
                        
                        if selectedCount == 0 then
                            SelectedValue.Text = "None"
                        elseif selectedCount == 1 then
                            for option, _ in pairs(selectedOptions) do
                                SelectedValue.Text = option
                                break
                            end
                        else
                            SelectedValue.Text = selectedCount .. " selected"
                        end
                    else
                        SelectedValue.Text = selectedOptions or "None"
                    end
                end
                
                -- Set initial selection
                if multiSelect then
                    if type(default) == "table" then
                        for _, option in pairs(default) do
                            selectedOptions[option] = true
                        end
                    end
                else
                    selectedOptions = default
                end
                
                -- Create option buttons
                local function createOptions()
                    -- Clear existing options
                    for _, button in pairs(optionButtons) do
                        button:Destroy()
                    end
                    optionButtons = {}
                    
                    -- Create new option buttons
                    for i, option in ipairs(options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = "Option_" .. option
                        OptionButton.Size = UDim2.new(1, 0, 0, 30)
                        OptionButton.BackgroundColor3 = Frosty.Theme.Foreground
                        OptionButton.BackgroundTransparency = 0.8
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Frosty.Theme.TextColor
                        OptionButton.TextSize = 14
                        OptionButton.Font = Frosty.Config.Font
                        OptionButton.Parent = OptionContainer
                        
                        local optionCorner = Instance.new("UICorner")
                        optionCorner.CornerRadius = Frosty.Config.CornerRadius
                        optionCorner.Parent = OptionButton
                        
                        -- Add selection indicator for multi-select
                        if multiSelect then
                            local SelectionIndicator = Instance.new("Frame")
                            SelectionIndicator.Name = "SelectionIndicator"
                            SelectionIndicator.Size = UDim2.new(0, 20, 0, 20)
                            SelectionIndicator.Position = UDim2.new(1, -30, 0.5, -10)
                            SelectionIndicator.BackgroundColor3 = Frosty.Theme.SliderBackground
                            SelectionIndicator.BorderSizePixel = 0
                            SelectionIndicator.Parent = OptionButton
                            
                            local indicatorCorner = Instance.new("UICorner")
                            indicatorCorner.CornerRadius = UDim.new(0, 4)
                            indicatorCorner.Parent = SelectionIndicator
                            
                            if selectedOptions[option] then
                                SelectionIndicator.BackgroundColor3 = Frosty.Theme.Accent
                            end
                        end
                        
                        -- Option hover effect
                        OptionButton.MouseEnter:Connect(function()
                            Frosty.Utils.CreateTween(OptionButton, 0.2, {BackgroundTransparency = 0.5}):Play()
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            Frosty.Utils.CreateTween(OptionButton, 0.2, {BackgroundTransparency = 0.8}):Play()
                        end)
                        
                        -- Option selection
                        OptionButton.MouseButton1Click:Connect(function()
                            Frosty.Utils.CreateRipple(OptionButton)
                            
                            if multiSelect then
                                -- Toggle selection
                                selectedOptions[option] = not selectedOptions[option] or nil
                                
                                -- Update visual indicator
                                local indicator = OptionButton:FindFirstChild("SelectionIndicator")
                                if indicator then
                                    if selectedOptions[option] then
                                        Frosty.Utils.CreateTween(indicator, 0.2, {BackgroundColor3 = Frosty.Theme.Accent}):Play()
                                    else
                                        Frosty.Utils.CreateTween(indicator, 0.2, {BackgroundColor3 = Frosty.Theme.SliderBackground}):Play()
                                    end
                                end
                                
                                -- Get selected options as array for callback
                                local selectedArray = {}
                                for opt, _ in pairs(selectedOptions) do
                                    table.insert(selectedArray, opt)
                                end
                                
                                callback(selectedArray, option) -- Pass all selected options and the changed option
                            else
                                -- Single selection
                                selectedOptions = option
                                closeDropdown() -- Close dropdown after selection for single-select
                                callback(option)
                            end
                            
                            updateSelectionText()
                        end)
                        
                        optionButtons[option] = OptionButton
                    end
                end
                
                -- Create initial options
                createOptions()
                updateSelectionText()
                
                -- Dropdown State
                local isOpen = false
                
                -- Dropdown open/close functions
                local function openDropdown()
                    isOpen = true
                    
                    -- Calculate height for dropdown content
                    local contentHeight = getContainerHeight()
                    OptionContainer.Visible = true
                    
                    -- Animate dropdown opening
                    Frosty.Utils.CreateTween(DropdownArrow, 0.3, {Rotation = 180}):Play()
                    Frosty.Utils.CreateTween(Dropdown, 0.3, {Size = UDim2.new(1, 0, 0, 50 + contentHeight)}):Play()
                end
                
                local function closeDropdown()
                    isOpen = false
                    
                    -- Animate dropdown closing
                    Frosty.Utils.CreateTween(DropdownArrow, 0.3, {Rotation = 0}):Play()
                    Frosty.Utils.CreateTween(Dropdown, 0.3, {Size = UDim2.new(1, 0, 0, 40)}):Play()
                    
                    task.delay(0.3, function()
                        if not isOpen then
                            OptionContainer.Visible = false
                        end
                    end)
                end
                
                -- Toggle dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    Frosty.Utils.CreateRipple(Dropdown)
                    
                    if isOpen then
                        closeDropdown()
                    else
                        openDropdown()
                    end
                end)
                
                -- Close dropdown when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if isOpen and not Dropdown:IsDescendantOf(game) then return end
                        
                        local mousePos = UserInputService:GetMouseLocation()
                        local dropdownPos = Dropdown.AbsolutePosition
                        local dropdownSize = Dropdown.AbsoluteSize
                        
                        if isOpen and (mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or 
                                      mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y) then
                            closeDropdown()
                        end
                    end
                end)
                
                -- Hover effects
                Dropdown.MouseEnter:Connect(function()
                    if tooltip then
                        local tooltipInstance = Frosty.Utils.CreateTooltip(tooltip)
                    end
                    
                    Frosty.Utils.CreateTween(Dropdown, 0.2, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.ButtonBackground.R * 1.1,
                        Frosty.Theme.ButtonBackground.G * 1.1,
                        Frosty.Theme.ButtonBackground.B * 1.1
                    )}):Play()
                end)
                
                Dropdown.MouseLeave:Connect(function()
                    if Frosty.ActiveTooltip then
                        Frosty.ActiveTooltip:Destroy()
                        Frosty.ActiveTooltip = nil
                    end
                    
                    Frosty.Utils.CreateTween(Dropdown, 0.2, {BackgroundColor3 = Frosty.Theme.ButtonBackground}):Play()
                end)
                
                -- Dropdown object
                local dropdownObject = {
                    Instance = Dropdown,
                    SetValue = function(value)
                        if multiSelect then
                            selectedOptions = {}
                            if type(value) == "table" then
                                for _, option in pairs(value) do
                                    selectedOptions[option] = true
                                end
                            end
                        else
                            selectedOptions = value
                        end
                        
                        -- Update selection visuals
                        for option, button in pairs(optionButtons) do
                            local indicator = button:FindFirstChild("SelectionIndicator")
                            if indicator and multiSelect then
                                if selectedOptions[option] then
                                    indicator.BackgroundColor3 = Frosty.Theme.Accent
                                else
                                    indicator.BackgroundColor3 = Frosty.Theme.SliderBackground
                                end
                            end
                        end
                        
                        updateSelectionText()
                    end,
                    GetValue = function()
                        if multiSelect then
                            local selectedArray = {}
                            for option, _ in pairs(selectedOptions) do
                                table.insert(selectedArray, option)
                            end
                            return selectedArray
                        else
                            return selectedOptions
                        end
                    end,
                    SetOptions = function(newOptions)
                        options = newOptions
                        createOptions()
                        updateSelectionText()
                        
                        -- Update size if dropdown is open
                        if isOpen then
                            local contentHeight = getContainerHeight()
                            Frosty.Utils.CreateTween(Dropdown, 0.3, {Size = UDim2.new(1, 0, 0, 50 + contentHeight)}):Play()
                        end
                    end,
                    SetCallback = function(newCallback)
                        callback = newCallback
                    end
                }
                
                return dropdownObject
            end
            
            function SectionObject:CreateInput(config)
                config = config or {}
                local inputName = config.Name or "Input"
                local default = config.Default or ""
                local placeholder = config.Placeholder or "Enter text..."
                local callback = config.Callback or function() end
                local tooltip = config.Tooltip
                local inputType = config.InputType or "Default" -- Default, Number, Password
                
                local Input = Instance.new("Frame")
                Input.Name = inputName .. "Input"
                Input.Size = UDim2.new(1, 0, 0, 60)
                Input.BackgroundColor3 = Frosty.Theme.ButtonBackground
                Input.BorderSizePixel = 0
                Input.Parent = SectionContent
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = Frosty.Config.CornerRadius
                inputCorner.Parent = Input
                
                -- Add stroke
                Frosty.Utils.CreateStroke(Input, 0.9, 1)
                
                -- Input Label
                local InputLabel = Instance.new("TextLabel")
                InputLabel.Name = "InputLabel"
                InputLabel.Size = UDim2.new(1, -20, 0, 25)
                InputLabel.Position = UDim2.new(0, 10, 0, 0)
                InputLabel.BackgroundTransparency = 1
                InputLabel.Text = inputName
                InputLabel.TextColor3 = Frosty.Theme.TextColor
                InputLabel.TextSize = 14
                InputLabel.Font = Frosty.Config.Font
                InputLabel.TextXAlignment = Enum.TextXAlignment.Left
                InputLabel.Parent = Input
                
                -- Input Field Background
                local InputBackground = Instance.new("Frame")
                InputBackground.Name = "InputBackground"
                InputBackground.Size = UDim2.new(1, -20, 0, 30)
                InputBackground.Position = UDim2.new(0, 10, 0, 25)
                InputBackground.BackgroundColor3 = Frosty.Theme.InputBackground
                InputBackground.BorderSizePixel = 0
                InputBackground.Parent = Input
                
                local inputBgCorner = Instance.new("UICorner")
                inputBgCorner.CornerRadius = UDim.new(0, 4)
                inputBgCorner.Parent = InputBackground
                
                -- Input Field
                local InputField = Instance.new("TextBox")
                InputField.Name = "InputField"
                InputField.Size = UDim2.new(1, -20, 1, 0)
                InputField.Position = UDim2.new(0, 10, 0, 0)
                InputField.BackgroundTransparency = 1
                InputField.Text = default
                InputField.PlaceholderText = placeholder
                InputField.TextColor3 = Frosty.Theme.TextColor
                InputField.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                InputField.TextSize = 14
                InputField.Font = Frosty.Config.Font
                InputField.TextXAlignment = Enum.TextXAlignment.Left
                InputField.ClearTextOnFocus = false
                
                -- Configure input type
                if inputType == "Number" then
                    InputField.TextInputType = Enum.TextInputType.Number
                    InputField.PlaceholderText = "Enter a number..."
                elseif inputType == "Password" then
                    InputField.TextInputType = Enum.TextInputType.Default
                    InputField.Visible = true
                    InputField.Text = string.rep("•", #default)
                    
                    -- Password handling
                    local realValue = default
                    
                    InputField.Focused:Connect(function()
                        InputField.Text = realValue
                    end)
                    
                    InputField.FocusLost:Connect(function(enterPressed)
                        realValue = InputField.Text
                        InputField.Text = string.rep("•", #realValue)
                        
                        if enterPressed then
                            callback(realValue)
                        end
                    end)
                    
                    InputField.Changed:Connect(function(property)
                        if property == "Text" and InputField:IsFocused() then
                            realValue = InputField.Text
                        end
                    end)
                end
                
                InputField.Parent = InputBackground
                
                -- Input hover & focus effects
                Input.MouseEnter:Connect(function()
                    if tooltip then
                        local tooltipInstance = Frosty.Utils.CreateTooltip(tooltip)
                    end
                    
                    Frosty.Utils.CreateTween(Input, 0.2, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.ButtonBackground.R * 1.1,
                        Frosty.Theme.ButtonBackground.G * 1.1,
                        Frosty.Theme.ButtonBackground.B * 1.1
                    )}):Play()
                end)
                
                Input.MouseLeave:Connect(function()
                    if Frosty.ActiveTooltip then
                        Frosty.ActiveTooltip:Destroy()
                        Frosty.ActiveTooltip = nil
                    end
                    
                    Frosty.Utils.CreateTween(Input, 0.2, {BackgroundColor3 = Frosty.Theme.ButtonBackground}):Play()
                end)
                
                InputField.Focused:Connect(function()
                    Frosty.Utils.CreateTween(InputBackground, 0.2, {BackgroundColor3 = Color3.fromRGB(
                        Frosty.Theme.InputBackground.R * 1.2,
                        Frosty.Theme.InputBackground.G * 1.2,
                        Frosty.Theme.InputBackground.B * 1.2
                    )}):Play()
                end)
                
                InputField.FocusLost:Connect(function(enterPressed)
                    Frosty.Utils.CreateTween(InputBackground, 0.2, {BackgroundColor3 = Frosty.Theme.InputBackground}):Play()
                    
                    if inputType ~= "Password" and enterPressed then
                        callback(InputField.Text)
                    end
                end)
                
                -- Input object
                local inputObject = {
                    Instance = Input,
                    SetValue = function(value)
                        if inputType == "Password" then
                            realValue = value
                            if not InputField:IsFocused() then
                                InputField.Text = string.rep("•", #value)
                            else
                                InputField.Text = value
                            end
                        else
                            InputField.Text = value
                        end
                    end,
                    GetValue = function()
                        if inputType == "Password" then
                            return realValue
                        else
                            return InputField.Text
                        end
                    end,
                    SetCallback = function(newCallback)
                        callback = newCallback
                    end
                }
                
                return inputObject
            end
            
            Tab.Sections[sectionName] = SectionObject
            return SectionObject
        end
        
        -- Create Label
        function Tab:CreateLabel(config)
            config = config or {}
            local labelText = config.Text or "Label"
            local align = config.Align or "Center" -- Left, Center, Right
            
            local Label = Instance.new("Frame")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.BackgroundTransparency = 1
            Label.Parent = TabContent
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Name = "LabelText"
            LabelText.Size = UDim2.new(1, 0, 1, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.Text = labelText
            LabelText.TextColor3 = Frosty.Theme.TextColor
            LabelText.TextSize = 14
            LabelText.Font = Frosty.Config.Font
            
            if align == "Left" then
                LabelText.TextXAlignment = Enum.TextXAlignment.Left
            elseif align == "Right" then
                LabelText.TextXAlignment = Enum.TextXAlignment.Right
            else
                LabelText.TextXAlignment = Enum.TextXAlignment.Center
            end
            
            LabelText.Parent = Label
            
            -- Update function
            local labelObject = {
                Instance = Label,
                SetText = function(text)
                    LabelText.Text = text
                end
            }
            
            return labelObject
        end
        
        -- Create Divider
        function Tab:CreateDivider(config)
            config = config or {}
            local dividerText = config.Text
            
            local Divider = Instance.new("Frame")
            Divider.Name = "Divider"
            Divider.Size = UDim2.new(1, 0, 0, dividerText and 30 or 10)
            Divider.BackgroundTransparency = 1
            Divider.Parent = TabContent
            
            local Line = Instance.new("Frame")
            Line.Name = "Line"
            Line.BackgroundColor3 = Frosty.Theme.BorderColor
            Line.BorderSizePixel = 0
            
            if dividerText then
                Line.Size = UDim2.new(0.3, 0, 0, 1)
                Line.Position = UDim2.new(0.05, 0, 0.5, 0)
                
                local Line2 = Instance.new("Frame")
                Line2.Name = "Line2"
                Line2.Size = UDim2.new(0.3, 0, 0, 1)
                Line2.Position = UDim2.new(0.65, 0, 0.5, 0)
                Line2.BackgroundColor3 = Frosty.Theme.BorderColor
                Line2.BorderSizePixel = 0
                Line2.Parent = Divider
                
                local DividerText = Instance.new("TextLabel")
                DividerText.Name = "DividerText"
                DividerText.Size = UDim2.new(0.25, 0, 1, 0)
                DividerText.Position = UDim2.new(0.375, 0, 0, 0)
                DividerText.BackgroundTransparency = 1
                DividerText.Text = dividerText
                DividerText.TextColor3 = Frosty.Theme.SubTextColor
                DividerText.TextSize = 12
                DividerText.Font = Frosty.Config.Font
                DividerText.Parent = Divider
            else
                Line.Size = UDim2.new(0.9, 0, 0, 1)
                Line.Position = UDim2.new(0.05, 0, 0.5, 0)
            end
            
            Line.Parent = Divider
            
            -- Update function
            local dividerObject = {
                Instance = Divider,
                SetText = function(text)
                    if dividerText then
                        Divider.DividerText.Text = text
                    end
                end
            }
            
            return dividerObject
        end
        
        -- Register tab
        Window.Tabs[tabName] = Tab
        
        -- Select the tab if it's the first one
        if #Window.Tabs == 1 then
            Window:SelectTab(tabName)
        end
        
        return Tab
    end
    
    -- Select a tab
    function Window:SelectTab(tabName)
        -- Skip if already selected
        if Window.ActiveTab == tabName then return end
        
        -- Hide all tabs
        for name, tab in pairs(Window.Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundTransparency = 1
            
            -- Find and adjust the label and icon
            local tabLabel = tab.Button:FindFirstChild("TabLabel")
            local tabIcon = tab.Button:FindFirstChild("TabIcon")
            
            if tabLabel then
                tabLabel.TextColor3 = Frosty.Theme.SubTextColor
            end
            
            if tabIcon then
                tabIcon.ImageColor3 = Frosty.Theme.SubTextColor
            end
        end
        
        -- Show the selected tab
        if Window.Tabs[tabName] then
            Window.Tabs[tabName].Content.Visible = true
            local tab = Window.Tabs[tabName]
            
            -- Highlight the selected tab button
            tab.Button.BackgroundTransparency = 0.8
            
            -- Find and adjust the label and icon
            local tabLabel = tab.Button:FindFirstChild("TabLabel")
            local tabIcon = tab.Button:FindFirstChild("TabIcon")
            
            if tabLabel then
                tabLabel.TextColor3 = Frosty.Theme.TextColor
            end
            
            if tabIcon then
                tabIcon.ImageColor3 = Frosty.Theme.Accent
            end
            
            -- Move tab indicator
            if Window.TabIndicator then
                Window.TabIndicator.Visible = true
                Frosty.Utils.CreateTween(Window.TabIndicator, 0.3, {
                    Position = UDim2.new(0, 0, 0, tab.Button.AbsolutePosition.Y - Window.TabContainer.AbsolutePosition.Y),
                    Size = UDim2.new(0, 4, 0, tab.Button.AbsoluteSize.Y)
                }):Play()
            end
            
            Window.ActiveTab = tabName
        end
    end
    
    -- Register window
    table.insert(Frosty.Windows, Window)
    
    -- Show the GUI with a smooth animation
    MainFrame.Size = UDim2.new(0, 650, 0, 0)
    MainFrame.BackgroundTransparency = 1
    
    if Frosty.Config.UseAcrylic then
        acrylicBg.Visible = true
        acrylicBg.BackgroundTransparency = 1
        Frosty.Utils.CreateTween(acrylicBg, 0.5, {BackgroundTransparency = 0.95}):Play()
    end
    
    Frosty.Utils.CreateTween(MainFrame, 0.5, {Size = UDim2.new(0, 650, 0, 450), BackgroundTransparency = 0}):Play()
    
    return Window
end

-- Define notification system
function Frosty.Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 5
    local type = options.Type or "Info" -- Info, Success, Warning, Error
    
    -- Create notification container if it doesn't exist
    if not Frosty.NotificationContainer then
        local screenGui = CoreGui:FindFirstChild("FrostyNotifications")
        
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "FrostyNotifications"
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            -- Set Parent
            if syn and syn.protect_gui then
                syn.protect_gui(screenGui)
                screenGui.Parent = game.CoreGui
            elseif gethui then
                screenGui.Parent = gethui()
            else
                screenGui.Parent = CoreGui
            end
        end
        
        Frosty.NotificationContainer = Instance.new("Frame")
        Frosty.NotificationContainer.Name = "NotificationContainer"
        Frosty.NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
        Frosty.NotificationContainer.Position = UDim2.new(1, -320, 0, 0)
        Frosty.NotificationContainer.BackgroundTransparency = 1
        Frosty.NotificationContainer.Parent = screenGui
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        listLayout.Padding = UDim.new(0, 10)
        listLayout.Parent = Frosty.NotificationContainer
        
        -- Add padding
        local padding = Instance.new("UIPadding")
        padding.PaddingBottom = UDim.new(0, 20)
        padding.Parent = Frosty.NotificationContainer
    end
    
    -- Determine notification color based on type
    local notifColor
    local iconImage
    
    if type == "Success" then
        notifColor = Frosty.Theme.Success
        iconImage = Frosty.Icons.Success
    elseif type == "Warning" then
        notifColor = Frosty.Theme.Warning
        iconImage = Frosty.Icons.Warning
    elseif type == "Error" then
        notifColor = Frosty.Theme.Error
        iconImage = Frosty.Icons.Error
    else
        notifColor = Frosty.Theme.Info
        iconImage = Frosty.Icons.Info
    end
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, -20, 0, 80)
    notification.BackgroundColor3 = Frosty.Theme.Background
    notification.BackgroundTransparency = 0.1
    notification.Position = UDim2.new(1, 20, 0, 0)
    notification.ClipsDescendants = true
    notification.Parent = Frosty.NotificationContainer
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = Frosty.Config.CornerRadius
    notifCorner.Parent = notification
    
    -- Add shadow
    Frosty.Utils.CreateShadow(notification, 15, 0.5)
    
    -- Add bar on left side
    local bar = Instance.new("Frame")
    bar.Name = "NotificationBar"
    bar.Size = UDim2.new(0, 5, 1, 0)
    bar.BackgroundColor3 = notifColor
    bar.BorderSizePixel = 0
    bar.Parent = notification
    
    -- Add icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "NotificationIcon"
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0, 15)
    icon.BackgroundTransparency = 1
    icon.Image = iconImage
    icon.ImageColor3 = notifColor
    icon.Parent = notification
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "NotificationTitle"
    titleLabel.Size = UDim2.new(1, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 45, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Frosty.Theme.TextColor
    titleLabel.TextSize = 16
    titleLabel.Font = Frosty.Config.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    -- Add message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "NotificationMessage"
    messageLabel.Size = UDim2.new(1, -60, 0, 40)
    messageLabel.Position = UDim2.new(0, 45, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Frosty.Theme.SubTextColor
    messageLabel.TextSize = 14
    messageLabel.Font = Frosty.Config.Font
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = notifColor
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notification
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 15)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = Frosty.Theme.SubTextColor
    closeButton.TextSize = 14
    closeButton.Font = Frosty.Config.Font
    closeButton.Parent = notification
    
    -- Animations
    notification.Position = UDim2.new(1, 20, 0, 0)
    Frosty.Utils.CreateTween(notification, 0.3, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    -- Progress bar animation
    Frosty.Utils.CreateTween(progressBar, duration, {Size = UDim2.new(0, 0, 0, 3)}, Enum.EasingStyle.Linear):Play()
    
    -- Close handling
    local closed = false
    
    local function closeNotification()
        if closed then return end
        closed = true
        
        -- Animate out
        Frosty.Utils.CreateTween(notification, 0.3, {Position = UDim2.new(1, 20, 0, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
        
        task.delay(0.35, function()
            notification:Destroy()
        end)
    end
    
    -- Close on button click
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    -- Auto close after duration
    task.delay(duration, closeNotification)
    
    return notification
end

-- Popup Dialog
function Frosty.Dialog(options)
    options = options or {}
    local title = options.Title or "Dialog"
    local message = options.Message or "Are you sure?"
    local buttons = options.Buttons or {
        {Text = "OK", Callback = function() end, Primary = true},
        {Text = "Cancel", Callback = function() end, Primary = false}
    }
    
    -- Create dialog background
    local dialogBackground = Instance.new("Frame")
    dialogBackground.Name = "DialogBackground"
    dialogBackground.Size = UDim2.new(1, 0, 1, 0)
    dialogBackground.BackgroundColor3 = Color3.new(0, 0, 0)
    dialogBackground.BackgroundTransparency = 1
    dialogBackground.ZIndex = 100
    
    -- Set Parent
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FrostyDialog"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game.CoreGui
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
    
    dialogBackground.Parent = screenGui
    
    -- Create dialog
    local dialog = Instance.new("Frame")
    dialog.Name = "Dialog"
    dialog.Size = UDim2.new(0, 400, 0, 200)
    dialog.Position = UDim2.new(0.5, -200, 0.5, -100)
    dialog.BackgroundColor3 = Frosty.Theme.Background
    dialog.BackgroundTransparency = 1
    dialog.ZIndex = 101
    dialog.Parent = dialogBackground
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = Frosty.Config.CornerRadius
    dialogCorner.Parent = dialog
    
    -- Add shadow
    Frosty.Utils.CreateShadow(dialog, 30, 0.5)
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "DialogTitle"
    titleLabel.Size = UDim2.new(1, -40, 0, 40)
    titleLabel.Position = UDim2.new(0, 20, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Frosty.Theme.TextColor
    titleLabel.TextSize = 20
    titleLabel.Font = Frosty.Config.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 102
    titleLabel.Parent = dialog
    
    -- Add message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "DialogMessage"
    messageLabel.Size = UDim2.new(1, -40, 0, 80)
    messageLabel.Position = UDim2.new(0, 20, 0, 60)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Frosty.Theme.SubTextColor
    messageLabel.TextSize = 16
    messageLabel.Font = Frosty.Config.Font
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.ZIndex = 102
    messageLabel.Parent = dialog
    
    -- Add buttons
    local buttonHolder = Instance.new("Frame")
    buttonHolder.Name = "ButtonHolder"
    buttonHolder.Size = UDim2.new(1, -40, 0, 40)
    buttonHolder.Position = UDim2.new(0, 20, 1, -60)
    buttonHolder.BackgroundTransparency = 1
    buttonHolder.ZIndex = 102
    buttonHolder.Parent = dialog
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonLayout.Padding = UDim.new(0, 10)
    buttonLayout.Parent = buttonHolder
    
    -- Create each button
    for i, btn in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = "DialogButton_" .. btn.Text
        button.Size = UDim2.new(0, 100, 0, 36)
        button.BackgroundColor3 = btn.Primary and Frosty.Theme.Accent or Frosty.Theme.ButtonBackground
        button.Text = btn.Text or "Button"
        button.TextColor3 = Frosty.Theme.TextColor
        button.TextSize = 14
        button.Font = Frosty.Config.Font
        button.ZIndex = 103
        button.AutoButtonColor = false
        button.Parent = buttonHolder
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        -- Button animations
        button.MouseEnter:Connect(function()
            Frosty.Utils.CreateTween(button, 0.2, {BackgroundColor3 = Color3.fromRGB(
                button.BackgroundColor3.R * 1.1,
                button.BackgroundColor3.G * 1.1,
                button.BackgroundColor3.B * 1.1
            )}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            Frosty.Utils.CreateTween(button, 0.2, {BackgroundColor3 = btn.Primary and Frosty.Theme.Accent or Frosty.Theme.ButtonBackground}):Play()
        end)
        
        button.MouseButton1Click:Connect(function()
            Frosty.Utils.CreateRipple(button)
            
            -- Close dialog
            Frosty.Utils.CreateTween(dialogBackground, 0.3, {BackgroundTransparency = 1}):Play()
            Frosty.Utils.CreateTween(dialog, 0.3, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -200, 0.6, -100)}):Play()
            
            task.delay(0.3, function()
                screenGui:Destroy()
                if btn.Callback then
                    btn.Callback()
                end
            end)
        end)
    end
    
    -- Animate in
    Frosty.Utils.CreateTween(dialogBackground, 0.3, {BackgroundTransparency = 0.5}):Play()
    dialog.Position = UDim2.new(0.5, -200, 0.6, -100)
    dialog.BackgroundTransparency = 1
    Frosty.Utils.CreateTween(dialog, 0.3, {Position = UDim2.new(0.5, -200, 0.5, -100), BackgroundTransparency = 0}):Play()
    
    -- Return dialog object
    return {
        Instance = dialog,
        Close = function()
            Frosty.Utils.CreateTween(dialogBackground, 0.3, {BackgroundTransparency = 1}):Play()
            Frosty.Utils.CreateTween(dialog, 0.3, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -200, 0.6, -100)}):Play()
            
            task.delay(0.3, function()
                screenGui:Destroy()
            end)
        end
    }
end

-- Set Theme
function Frosty.SetTheme(theme)
    if type(theme) ~= "table" then return end
    
    -- Update theme
    for key, value in pairs(theme) do
        if Frosty.Theme[key] ~= nil then
            Frosty.Theme[key] = value
        end
    end
    
    -- Update all UI elements that use theme colors
    -- This would require a more complex implementation to update all existing UI elements
end

-- Cleanup function
function Frosty.Cleanup()
    for _, connection in ipairs(Frosty.Connections) do
        connection:Disconnect()
    end
    
    for _, window in ipairs(Frosty.Windows) do
        if window.FrostyGui then
            window.FrostyGui:Destroy()
        end
    end
    
    if Frosty.NotificationContainer and Frosty.NotificationContainer.Parent then
        Frosty.NotificationContainer.Parent:Destroy()
    end
end

return Frosty
