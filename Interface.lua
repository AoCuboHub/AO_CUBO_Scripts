--// AO CUBO - Interface Online (via GitHub)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local GITHUB_REPO = "https://raw.githubusercontent.com/AoCuboHub/AO_CUBO_Scripts/main/"

-- Baixa o scriptIndex.lua do GitHub que lista pastas e scripts
local indexURL = GITHUB_REPO .. "scriptIndex.lua"
local success, data = pcall(function()
    return loadstring(game:HttpGet(indexURL, true))()
end)

if not success then
    warn("Erro ao carregar o índice de scripts: ", data)
    return
end

local index = data -- tabela: { ["ESP"] = { "WallHack", "PlayerESP" }, ... }

-- Interface simples
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AoCuboUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

for folderName, scripts in pairs(index) do
    local folderLabel = Instance.new("TextLabel", Frame)
    folderLabel.Text = "📂 " .. folderName
    folderLabel.Size = UDim2.new(1, -10, 0, 25)
    folderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    folderLabel.BackgroundTransparency = 1
    folderLabel.Font = Enum.Font.GothamBold
    folderLabel.TextSize = 14

    for _, scriptName in ipairs(scripts) do
        local button = Instance.new("TextButton", Frame)
        button.Text = "▶️ " .. scriptName
        button.Size = UDim2.new(1, -20, 0, 30)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Font = Enum.Font.Gotham
        button.TextSize = 12

        button.MouseButton1Click:Connect(function()
            local scriptUrl = string.format("%s%s/%s.lua", GITHUB_REPO, folderName, scriptName)
            local ok, result = pcall(function()
                loadstring(game:HttpGet(scriptUrl, true))()
            end)
            if not ok then
                warn("Erro ao executar script: ", result)
            end
        end)
    end
end
