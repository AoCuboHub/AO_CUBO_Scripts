-- main.lua

-- Importando o arquivo de index com os scripts
local scriptIndex = require("scriptindex")

-- Variáveis para controle da interface
local menuVisible = true  -- Estado do menu lateral

-- Função para carregar e executar os scripts
local function loadScript(url)
    -- Aqui, você pode implementar a lógica para carregar e executar os scripts a partir do URL fornecido
    print("Carregando script: " .. url)
    -- A lógica real de execução vai depender de como você planeja rodar os scripts remotamente
end

-- Função para criar o menu lateral
local function createMenu()
    -- Criar o menu com as categorias
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 200, 1, 0)
    menu.Position = UDim2.new(0, 0, 0, 0)
    menu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    -- Criar um botão de minimizar
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Text = "-"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(0, 170, 0, 10)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    minimizeButton.MouseButton1Click:Connect(function()
        -- Alternar entre visibilidade do menu lateral
        menuVisible = not menuVisible
        menu.Visible = menuVisible
    end)
    minimizeButton.Parent = menu

    -- Criar os botões para as categorias
    for category, scripts in pairs(scriptIndex) do
        local categoryFrame = Instance.new("Frame")
        categoryFrame.Size = UDim2.new(1, 0, 0, 50)
        categoryFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        categoryFrame.Parent = menu

        local categoryLabel = Instance.new("TextLabel")
        categoryLabel.Text = category
        categoryLabel.Size = UDim2.new(1, 0, 0, 30)
        categoryLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        categoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        categoryLabel.Parent = categoryFrame

        -- Criar os botões para cada script da categoria
        for i, script in ipairs(scripts) do
            local scriptButton = Instance.new("TextButton")
            scriptButton.Text = script.name
            scriptButton.Size = UDim2.new(1, 0, 0, 30)
            scriptButton.Position = UDim2.new(0, 0, 0, 30 + (i - 1) * 30)
            scriptButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            scriptButton.MouseButton1Click:Connect(function()
                -- Carregar o script correspondente
                loadScript(script.url)
            end)
            scriptButton.Parent = categoryFrame
        end
    end

    return menu
end

-- Função para criar o botão flutuante
local function createFloatingButton()
    local floatButton = Instance.new("TextButton")
    floatButton.Text = "🎲"
    floatButton.Size = UDim2.new(0, 50, 0, 50)
    floatButton.Position = UDim2.new(0, 10, 0, 10)
    floatButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatButton.BorderRadius = UDim.new(1, 0)  -- Tornando-o redondo
    floatButton.MouseButton1Click:Connect(function()
        -- Alternar entre visibilidade do menu lateral
        menuVisible = not menuVisible
        menu.Visible = menuVisible
    end)

    return floatButton
end

-- Criar o menu lateral e o botão flutuante
local menu = createMenu()
local floatingButton = createFloatingButton()

-- Adicionar os elementos na tela
menu.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
floatingButton.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
