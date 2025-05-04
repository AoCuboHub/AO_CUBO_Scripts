-- AutoFarmVooXeno.lua

if getgenv().AutoFarmRodando then return end
getgenv().AutoFarmRodando = true
getgenv().AutoFarmLigado = true

-- Serviços
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")
local uis = game:GetService("UserInputService")
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Configs
local DISTANCIA_ATAQUE = 10
local DISTANCIA_BUSCA = 200
local CLICK_REPETICAO = 3
local DELAY = 0.15
local NPCS_ATIVOS = {}

-- Criar GUI de seleção
local function criarMenuSelecionarNPC()
	local gui = Instance.new("ScreenGui", game.CoreGui)
	gui.Name = "AutoFarmSelecionarNPC"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 200, 0, 300)
	frame.Position = UDim2.new(0, 10, 0.5, -150)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true

	local uilist = Instance.new("UIListLayout", frame)
	uilist.Padding = UDim.new(0, 5)
	uilist.SortOrder = Enum.SortOrder.LayoutOrder

	local scroll = Instance.new("ScrollingFrame", frame)
	scroll.Size = UDim2.new(1, 0, 1, -40)
	scroll.CanvasSize = UDim2.new(0, 0, 10, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6

	local listLayout = Instance.new("UIListLayout", scroll)
	listLayout.Padding = UDim.new(0, 4)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local function toggleNPC(name)
		NPCS_ATIVOS[name] = not NPCS_ATIVOS[name]
	end

	local nomesUnicos = {}
	for _, npc in ipairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
			if not Players:GetPlayerFromCharacter(npc) then
				nomesUnicos[npc.Name] = true
			end
		end
	end

	for nome in pairs(nomesUnicos) do
		NPCS_ATIVOS[nome] = true -- padrão: ligado

		local botao = Instance.new("TextButton", scroll)
		botao.Size = UDim2.new(1, -10, 0, 30)
		botao.Text = nome .. " [ON]"
		botao.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		botao.TextColor3 = Color3.new(1,1,1)
		botao.Font = Enum.Font.GothamBold
		botao.TextScaled = true

		botao.MouseButton1Click:Connect(function()
			toggleNPC(nome)
			botao.Text = nome .. (NPCS_ATIVOS[nome] and " [ON]" or " [OFF]")
			botao.BackgroundColor3 = NPCS_ATIVOS[nome] and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(100, 0, 0)
		end)
	end

	local desligar = Instance.new("TextButton", frame)
	desligar.Size = UDim2.new(1, 0, 0, 30)
	desligar.Position = UDim2.new(0, 0, 1, -30)
	desligar.Text = "Desligar AutoFarm"
	desligar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	desligar.TextColor3 = Color3.new(1,1,1)
	desligar.Font = Enum.Font.GothamBold
	desligar.TextScaled = true

	desligar.MouseButton1Click:Connect(function()
		getgenv().AutoFarmLigado = false
		getgenv().AutoFarmRodando = false
		gui:Destroy()
	end)
end

-- Funções de ataque e mira
local function atacar()
	for _ = 1, CLICK_REPETICAO do
		vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
		vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
	end
end

local function mirar(npc)
	local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(npc.HumanoidRootPart.Position)
	vim:SendMouseMoveEvent(screenPoint.X, screenPoint.Y, game, 0)
end

local function soltarSkills()
	for _, tecla in ipairs({"Z", "X", "C", "V"}) do
		vim:SendKeyEvent(true, tecla, false, game)
		task.wait(0.05)
		vim:SendKeyEvent(false, tecla, false, game)
	end
end

-- Função para detectar NPC válido
local function isNPC(model)
	return model:IsA("Model")
		and model:FindFirstChild("Humanoid")
		and model:FindFirstChild("HumanoidRootPart")
		and model ~= player.Character
		and not Players:GetPlayerFromCharacter(model)
		and NPCS_ATIVOS[model.Name]
end

-- Encontrar NPC mais próximo (e permitido)
local function encontrarAlvo()
	local maisPerto, menorDist = nil, DISTANCIA_BUSCA
	for _, model in ipairs(workspace:GetDescendants()) do
		if isNPC(model) then
			local dist = (hrp.Position - model.HumanoidRootPart.Position).Magnitude
			if dist < menorDist and model.Humanoid.Health > 0 then
				table.insert(NPCS_ATIVOS, model.Name)
				maisPerto = model
				menorDist = dist
			end
		end
	end
	return maisPerto
end

-- Função de voo direto (sem colisões)
local function voarAteNPC(npc)
	local alvoPos = npc.HumanoidRootPart.Position
	local direction = (alvoPos - hrp.Position).Unit
	local speed = 100 -- Velocidade do voo

	hr
p.Anchored = true -- evitar colisão
	while (hrp.Position - alvoPos).Magnitude > DISTANCIA_ATAQUE and getgenv().AutoFarmLigado do
		hr
p.CFrame = CFrame.new(hr
p.Position + direction * speed * 0.1)
		task.wait(0.05)
	end
	hr
p.Anchored = false
end

-- Loop Principal
criarMenuSelecionarNPC()
task.spawn(function()
	while getgenv().AutoFarmLigado do
		local alvo = encontrarAlvo()
		if alvo and alvo:FindFirstChild("HumanoidRootPart") then
			local dist = (hrp.Position - alvo.HumanoidRootPart.Position).Magnitude
			if dist > DISTANCIA_ATAQUE then
				voarAteNPC(alvo)
			else
				mirar(alvo)
				atacar()
				soltarSkills()
			end
		end
		task.wait(DELAY)
	end
end)
