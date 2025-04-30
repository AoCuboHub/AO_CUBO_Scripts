-- Script para ESP de outros jogadores com nome, distância e cor do time
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP_COLOR_A = Color3.fromRGB(255, 0, 0) -- Cor do time A (vermelho)
local ESP_COLOR_B = Color3.fromRGB(0, 0, 255) -- Cor do time B (azul)
local ESP_SIZE = Vector3.new(2, 5, 2) -- Tamanho da caixa de ESP
local TEXT_SIZE = 14 -- Tamanho da fonte do nome

-- Função para criar uma caixa de ESP para um jogador
local function createESP(player)
    -- Verifica se o jogador possui um modelo de personagem
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Não criar ESP para o jogador local
    if player == LocalPlayer then
        return
    end

    -- Definir a cor do ESP de acordo com o time do jogador
    local teamColor = ESP_COLOR_A -- Default para time A (vermelho)
    if player.Team and player.Team.Name == "TimeB" then
        teamColor = ESP_COLOR_B -- Se o jogador for do time B, fica azul
    end

    -- Cria um modelo para o ESP
    local espBox = Instance.new("Part")
    espBox.Size = ESP_SIZE
    espBox.Anchored = true
    espBox.CanCollide = false
    espBox.Transparency = 0.5
    espBox.Color = teamColor
    espBox.Parent = workspace

    -- Cria um rótulo de texto para o nome do jogador
    local playerName = Instance.new("BillboardGui")
    playerName.Adornee = espBox
    playerName.Size = UDim2.new(0, 100, 0, 50)
    playerName.StudsOffset = Vector3.new(0, 3, 0) -- Ajusta a posição acima da caixa
    playerName.Parent = espBox

    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, 0, 1, 0)
    playerLabel.BackgroundTransparency = 1
    playerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerLabel.TextStrokeTransparency = 0.5
    playerLabel.Font = Enum.Font.GothamBold
    playerLabel.TextSize = TEXT_SIZE
    playerLabel.Text = player.Name
    playerLabel.Parent = playerName

    -- Função para atualizar a posição da caixa de ESP e nome
    local function updateESP()
        if character and character:FindFirstChild("HumanoidRootPart") then
            espBox.Position = character.HumanoidRootPart.Position
            espBox.CFrame = CFrame.new(espBox.Position)
        else
            espBox:Destroy()
        end
    end

    -- Função para calcular a distância entre o jogador local e o alvo
    local function updateDistance()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            playerLabel.Text = player.Name .. "\n" .. math.floor(distance) .. " studs"
        end
    end

    -- Atualiza a posição e a distância do ESP a cada frame
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            updateESP()
            updateDistance()
        else
            connection:Disconnect()
            espBox:Destroy()
        end
    end)

    -- Atualiza o ESP quando o personagem for reiniciado ou mudar
    player.CharacterAdded:Connect(function()
        espBox:Destroy()
        createESP(player)
    end)
end

-- Criar ESP para jogadores existentes (exceto o jogador local)
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
        
        if player.Character then
            createESP(player)
        end
    end
end

-- Criar ESP quando um novo jogador entrar no jogo (exceto o jogador local)
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
    end
end)
