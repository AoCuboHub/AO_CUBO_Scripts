local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local function getNearestTarget()
	local closest, closestDist = nil, math.huge
	for _, mob in ipairs(workspace:GetDescendants()) do
		if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
			if not Players:GetPlayerFromCharacter(mob) and mob.Humanoid.Health > 0 then
				local dist = (mob.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if dist < closestDist and table.find(_G.AutoFarmUI.GetTargets(), mob.Name) then
					closest = mob
					closestDist = dist
				end
			end
		end
	end
	return closest
end

local function flyTo(targetPos)
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	local hrp = char.HumanoidRootPart
	local start = tick()

	while (hrp.Position - targetPos).Magnitude > 5 and tick() - start < 10 do
		local direction = (targetPos - hrp.Position).Unit
		hrp.Velocity = direction * 100
		hrp.CFrame = CFrame.lookAt(hrp.Position, targetPos)
		RunService.Heartbeat:Wait()
	end

	hrp.Velocity = Vector3.zero
end

local function clickAttack()
	mouse1press()
	task.wait()
	mouse1release()
end

local function useSkill(skill)
	local vim = game:GetService("VirtualInputManager")
	vim:SendKeyEvent(true, skill, false, game)
	task.wait(0.05)
	vim:SendKeyEvent(false, skill, false, game)
end

-- Loop de farm
task.spawn(function()
	while true do
		local target = getNearestTarget()
		if target and target:FindFirstChild("HumanoidRootPart") then
			-- voar até o alvo
			flyTo(target.HumanoidRootPart.Position + Vector3.new(0, 5, 0))

			-- atacar até o alvo morrer
			while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
				clickAttack()

				for _, skill in ipairs(_G.AutoFarmUI.GetSkills()) do
					useSkill(skill)
					task.wait(0.2)
				end

				task.wait(0.1)
			end
		else
			task.wait(1)
		end
	end
end)
