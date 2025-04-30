--// AO CUBO Interface
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local AOCUBO_DIR = "C:/Users/User Game/Desktop/AO CUBO"
local scriptIndexPath = AOCUBO_DIR .. "/scriptIndex.lua"

-- Função auxiliar para ler diretórios
local function listFolders(path)
    local folders = {}
    local success, files = pcall(function()
        return listfiles(path)
    end)
    if success and files then
        for _, file in ipairs(files) do
            if isfolder(file) then
                table.insert(folders, file)
            end
        end
    end
    return folders
end

-- Função auxiliar para ler scripts dentro dos diretórios
local function listScripts(folder)
    local scripts = {}
    local success, files = pcall(function()
        return listfiles(folder)
    end)
    if success and files then
        for _, file in ipairs(files) do
            if file:sub(-4) == ".lua" then
                table.insert(scripts, file)
            end
        end
    end
    return scripts
end

-- Carrega o scriptIndex
local scriptIndex = require(scriptIndexPath)

-- Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AoCuboUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local transparency = 0.8 -- default 20% visível

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 100, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = transparency
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(90, 90, 90)
UIStroke.Thickness = 1

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Top bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local Logo = Instance.new("TextLabel", TopBar)
Logo.Text = "🎲 AO CUBO"
Logo.Size = UDim2.new(1, -60, 1, 0)
Logo.Position = UDim2.new(0, 10, 0, 0)
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.BackgroundTransparency = 1
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 14

-- Minimizar botão
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 1, 0)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14

local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Size = UDim2.new(0, 40, 0, 40)
FloatingBtn.Position = UDim2.new(0, 20, 0, 200)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.Image = "rbxassetid://9766671519"
FloatingBtn.Visible = false
FloatingBtn.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner", FloatingBtn)
FloatingCorner.CornerRadius = UDim.new(1, 0)

local function minimize()
    MainFrame.Visible = false
    FloatingBtn.Visible = true
end

local function restore()
    MainFrame.Visible = true
    FloatingBtn.Visible = false
end

MinBtn.MouseButton1Click:Connect(minimize)
FloatingBtn.MouseButton1Click:Connect(restore)

-- Menu lateral
local SideMenu = Instance.new("Frame", MainFrame)
SideMenu.Size = UDim2.new(0, 90, 1, -30)
SideMenu.Position = UDim2.new(0, 0, 0, 30)
SideMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SideMenu.BackgroundTransparency = transparency

-- Conteúdo dinâmico
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -90, 1, -30)
ContentFrame.Position = UDim2.new(0, 90, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.BackgroundTransparency = transparency

local function loadScripts()
    -- Itera pelos diretórios e scripts do scriptIndex
    for category, scripts in pairs(scriptIndex) do
        local CategoryBtn = Instance.new("TextButton", SideMenu)
        CategoryBtn.Size = UDim2.new(1, 0, 0, 30)
        CategoryBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CategoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CategoryBtn.Text = category
        CategoryBtn.Font = Enum.Font.Gotham
        CategoryBtn.TextSize = 12

        CategoryBtn.MouseButton1Click:Connect(function()
            ContentFrame:ClearAllChildren()
            -- Carrega os scripts dessa categoria
            for _, script in ipairs(scripts) do
                local Toggle = Instance.new("TextButton", ContentFrame)
                Toggle.Size = UDim2.new(1, -10, 0, 30)
                Toggle.Position = UDim2.new(0, 5, 0, (#ContentFrame:GetChildren()-1)*35)
                Toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.Text = "🔑 " .. script.name
                Toggle.Font = Enum.Font.Gotham
                Toggle.TextSize = 12

                local running = false
                local thread = nil
                Toggle.MouseButton1Click:Connect(function()
                    if running and thread then
                        coroutine.close(thread)
                        running = false
                        Toggle.Text = "🔑 " .. script.name
                    else
                        thread = coroutine.create(function()
                            loadstring(game:HttpGet(script.url))()
                        end)
                        coroutine.resume(thread)
                        running = true
                        Toggle.Text = "✅ " .. script.name
                    end
                end)
            end
        end)
    end
end

-- Configurações
local SettingsBtn = Instance.new("TextButton", SideMenu)
SettingsBtn.Size = UDim2.new(1, 0, 0, 30)
SettingsBtn.Position = UDim2.new(0, 0, 1, -30)
SettingsBtn.Text = "⚙ Config"
SettingsBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsBtn.Font = Enum.Font.Gotham
SettingsBtn.TextSize = 12

local SettingsPanel = Instance.new("Frame", ContentFrame)
SettingsPanel.Visible = false
SettingsPanel.Size = UDim2.new(1, 0, 1, 0)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SettingsPanel.BackgroundTransparency = transparency

local SliderLabel = Instance.new("TextLabel", SettingsPanel)
SliderLabel.Text = "Transparência"
SliderLabel.Size = UDim2.new(1, -20, 0, 20)
SliderLabel.Position = UDim2.new(0, 10, 0, 10)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.TextSize = 12

local Slider = Instance.new("Frame", SettingsPanel)
Slider.Size = UDim2.new(1, -20, 0, 10)
Slider.Position = UDim2.new(0, 10, 0, 35)
Slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

local Fill = Instance.new("Frame", Slider)
Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Fill.Size = UDim2.new(1 - transparency, 0, 1, 0)
Fill.BorderSizePixel = 0

local dragging = false

Slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        transparency = 1 - relX
        Fill.Size = UDim2.new(relX, 0, 1, 0)
        MainFrame.BackgroundTransparency = transparency
        SideMenu.BackgroundTransparency = transparency
        ContentFrame.BackgroundTransparency = transparency
        SettingsPanel.BackgroundTransparency = transparency
    end
end)

SettingsBtn.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

-- Ativa
loadScripts()
