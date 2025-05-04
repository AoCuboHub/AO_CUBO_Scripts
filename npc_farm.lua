--[[ XENO AUTO FARM UI + NPC SPAWN TRACKER + COMBATE CONFIG
    Criado para melhor experiência com Xeno
    Funções:
    - Lista de NPCs em spawn, atualiza automaticamente
    - Menu flutuante para escolher estilo de luta e habilidades
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

--== Janela principal
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AutoFarmInterface"

--== Funções utilitárias
local function createFrame(parent, size, pos, name)
	local frame = Instance.new("Frame", parent)
	frame.Name = name or "Frame"
	frame.Size = size
	frame.Position = pos
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.2
	return frame
end

local function createLabel(parent, text, size, pos)
	local label = Instance.new("TextLabel", parent)
	label.Text = text
	label.Size = size
	label.Position = pos
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	return label
end

local function createButton(parent, text, size, pos, callback)
	local button = Instance.new("TextButton", parent)
	button.Text = text
	button.Size = size
	button.Position = pos
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.MouseButton1Click:Connect(callback)
	return button
end

--== Frame de combate
local combatFrame = createFrame(ScreenGui, UDim2.new(0, 250, 0, 220), UDim2.new(0, 10, 0, 10), "CombatFrame")
createLabel(combatFrame, "Estilo de Combate:", UDim2.new(0, 230, 0, 20), UDim2.new(0, 10, 0, 5))

local selectedStyle = "Fist"
local skillsSelected = {}

local styles = {"Fist", "Fruit", "Sword", "Gun"}
local skillsMap = {
	Fist = {"Z", "X", "C"},
	Fruit = {"Z", "X", "C", "V", "F"},
	Sword = {"Z", "X"},
	Gun = {"Z", "X"},
}

local function updateSkillButtons()
	for _, obj in ipairs(combatFrame:GetChildren()) do
		if obj:IsA("TextButton") and obj.Name == "SkillBtn" then obj:Destroy() end
	end
	skillsSelected = {}

	local skillList = skillsMap[selectedStyle]
	for i, skill in ipairs(skillList) do
		createButton(combatFrame, skill, UDim2.new(0, 40, 0, 30), UDim2.new(0, 10 + (i-1)*45, 0, 90), function(btn)
			skillsSelected[skill] = not skillsSelected[skill]
			btn.BackgroundColor3 = skillsSelected[skill] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
		end).Name = "SkillBtn"
	end
end

-- Botões de estilo de combate
for i, style in ipairs(styles) do
	createButton(combatFrame, style, UDim2.new(0, 50, 0, 25), UDim2.new(0, 10 + (i-1)*60, 0, 30), function()
		selectedStyle = style
		updateSkillButtons()
	end)
end
updateSkillButtons()

--== Frame de NPCs em spawn
local npcFrame = createFrame(ScreenGui, UDim2.new(0, 220, 0, 300), UDim2.new(1, -230, 0, 10), "NPCList")
createLabel(npcFrame, "NPCs em Spawn", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0))

local npcButtons = {}
local activeTargets = {}

local function updateNPCList()
	for _, btn in pairs(npcButtons) do btn:Destroy() end
	npcButtons = {}

	local npcsInRange = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
			if not Players:GetPlayerFromCharacter(obj) and obj ~= LocalPlayer.Character then
				local dist = (obj.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if dist <= 1000 then
					npcsInRange[obj.Name] = true
				end
			end
		end
	end

	local y = 30
	for npcName in pairs(npcsInRange) do
		local btn = createButton(npcFrame, npcName, UDim2.new(1, -10, 0, 25), UDim2.new(0, 5, 0, y), function()
			activeTargets[npcName] = not activeTargets[npcName]
			btn.BackgroundColor3 = activeTargets[npcName] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
		end)
		npcButtons[npcName] = btn
		y = y + 30
	end
end

--== Atualização leve
task.spawn(function()
	while true do
		updateNPCList()
		task.wait(1.5)
	end
end)

--== Exposição de configurações
_G.AutoFarmSettings = {
	GetStyle = function() return selectedStyle end,
	GetSkills = function()
		local used = {}
		for k, v in pairs(skillsSelected) do if v then table.insert(used, k) end end
		return used
	end,
	GetTargets = function()
		local list = {}
		for k, v in pairs(activeTargets) do if v then table.insert(list, k) end end
		return list
	end
}
