local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")

local LockerSystem = {}

-- Crear un armario en la posicion dada
function LockerSystem.createLocker(parent: Instance, position: Vector3, rotation: number)
	local model = Instance.new("Model")
	model.Name = "Locker"
	model.Parent = parent

	-- Parte principal (Cuerpo del armario)
	local mainPart = Instance.new("Part")
	mainPart.Name = "Main"
	mainPart.Size = Vector3.new(4, 8, 3) -- Ancho, Alto, Profundo
	mainPart.Position = position + Vector3.new(0, 4, 0)
	mainPart.Anchored = true
	mainPart.CanCollide = true
	mainPart.Color = Color3.fromRGB(100, 100, 100) -- Gris metalico
	mainPart.Material = Enum.Material.Metal
	mainPart.CFrame = CFrame.new(position + Vector3.new(0, 4, 0)) * CFrame.Angles(0, math.rad(rotation), 0)
	mainPart.Parent = model

	-- Puerta (Visual)
	local door = Instance.new("Part")
	door.Name = "Door"
	door.Size = Vector3.new(3.8, 7.8, 0.2)
	door.CFrame = mainPart.CFrame * CFrame.new(0, 0, -1.45)
	door.Anchored = true
	door.CanCollide = true
	door.Color = Color3.fromRGB(90, 90, 90)
	door.Material = Enum.Material.Metal
	door.Parent = model
	
	-- Rejillas de ventilacion (Decal o textura simple)
	local vents = Instance.new("Texture")
	vents.Texture = "rbxassetid://6065796850" -- Rejilla generica (Placeholder)
	vents.Face = Enum.NormalId.Front
	vents.Parent = door

	-- Prompt de interaccion
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Locker"
	prompt.ActionText = "Esconderse"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 8
	prompt.Parent = mainPart

	-- Logica de interaccion
	prompt.Triggered:Connect(function(player)
		local character = player.Character
		if not character then return end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end
		
		local isHidden = player:GetAttribute("Hidden")

		if not isHidden then
			-- ESCONDERSE
			player:SetAttribute("Hidden", true)
			prompt.ActionText = "Salir"
			
			-- Tp adentro
			humanoidRootPart.CFrame = mainPart.CFrame
			humanoidRootPart.Anchored = true
			
			-- Hacer invisible
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("Decal") then
					if part.Name ~= "HumanoidRootPart" then
						part.Transparency = 1
						if part:IsA("BasePart") then part.CanCollide = false end
					end
				end
			end
		else
			-- SALIR
			player:SetAttribute("Hidden", false)
			prompt.ActionText = "Esconderse"
			
			-- Tp afuera (frente al armario)
			humanoidRootPart.CFrame = mainPart.CFrame * CFrame.new(0, 0, -5)
			humanoidRootPart.Anchored = false
			
			-- Hacer visible
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("Decal") then
					if part.Name ~= "HumanoidRootPart" then
						part.Transparency = 0
						if part:IsA("BasePart") then part.CanCollide = true end
					end
				end
			end
		end
	end)
end

return LockerSystem
