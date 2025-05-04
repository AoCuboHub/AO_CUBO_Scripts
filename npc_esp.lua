local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local DISTANCE_LIMIT = 1300 -- Limite máximo em studs

local function isNPC(model)
	if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
		if model ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(model) then
			return true
		end
	end
	return false
end

local function createNPCESP(npc)
	if npc:FindFirstChild("NPC_ESP") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NPC_ESP"
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.Adornee = npc.HumanoidRootPart
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = npc

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 0)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	-- Atualização dinâmica
	RunService.RenderStepped:Connect(function()
		if npc and npc:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (npc.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if dist <= DISTANCE_LIMIT then
				label.Visible = true
				label.Text = npc.Name .. "\n" .. math.floor(dist) .. " studs"
			else
				label.Visible = false -- Esconde se estiver longe
			end
		end
	end)
end

task.spawn(function()
	while true do
		for _, obj in ipairs(workspace:GetDescendants()) do
			if isNPC(obj) then
				createNPCESP(obj)
			end
		end
		task.wait(1)
	end
end)
