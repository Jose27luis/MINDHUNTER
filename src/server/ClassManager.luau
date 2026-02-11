local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(game.ReplicatedStorage.Shared.Config)

local ClassManager = {}

-- Almacenar seleccion de clases: { [Player]: "ClassName" }
local playerClasses = {}

-- Evento remoto
local selectClassEvent = Instance.new("RemoteEvent")
selectClassEvent.Name = "SelectClass"
selectClassEvent.Parent = ReplicatedStorage

-- Default class
local DEFAULT_CLASS = "Scout"

function ClassManager.init()
	selectClassEvent.OnServerEvent:Connect(function(player, className)
		if Config.CLASSES[className] then
			playerClasses[player] = className
			print(player.Name .. " selecciono la clase: " .. className)
			
			-- Feedback visual o mensaje (opcional)
		end
	end)
end

function ClassManager.applyClass(player)
	local className = playerClasses[player] or DEFAULT_CLASS
	local classData = Config.CLASSES[className]
	
	if not classData then return end
	
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.MaxHealth = classData.MaxHealth
		humanoid.Health = classData.MaxHealth
		humanoid.WalkSpeed = classData.WalkSpeed
		
		-- Guardar datos para el cliente (SprintController necesita saber RunSpeed/Stamina)
		player:SetAttribute("ClassName", className)
		player:SetAttribute("RunSpeed", classData.RunSpeed)
		player:SetAttribute("WalkSpeed", classData.WalkSpeed)
		player:SetAttribute("StaminaMax", classData.StaminaMax)
	end
	
	print("Clase " .. className .. " aplicada a " .. player.Name)
end

function ClassManager.resetData(player)
	playerClasses[player] = nil
end

return ClassManager
