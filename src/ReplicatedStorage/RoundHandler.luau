local DinoFactory = require(script.Parent.DinoFactory)
local CavemanFactory = require("./CavemanFactory")
local Player = game.Players.LocalPlayer
local ScreenGui = Player:WaitForChild("PlayerGui", 30)
local Holder = ScreenGui:WaitForChild("UI", 30):WaitForChild("Holder", 30)


local RoundHandler = {}
local MinDinoSpawn = math.random(1,5)
local DinosLeft = MinDinoSpawn
function RoundHandler.spawn()
	DinosLeft = MinDinoSpawn
	for i = 1, MinDinoSpawn do
		DinoFactory.new("T_Rex")
		DinosLeft -= 1
		task.wait(1)
	end
end

local started = false

--function CalculateDistance(Point1, Point2)
--	local distance = UDim2.new(0, Point1.AbsolutePosition.X - Point2.AbsolutePosition.X, 0, Point1.AbsolutePosition.Y - Point2.AbsolutePosition.Y)
--	return distance
--end

local function getCenter(gui)
	return gui.AbsolutePosition + gui.AbsoluteSize / 2
end

local function getDistance(gui1, gui2)
	local p1 = getCenter(gui1)
	local p2 = getCenter(gui2)
	return (p1 - p2).Magnitude
end

function RoundHandler.StartRound()
	task.spawn(RoundHandler.spawn)
	started = true
	task.spawn(function() 
		while true do
			for id, caveman in CavemanFactory.activeCaveman do
				if caveman.Attacking then continue end

				local dinos = DinoFactory.Dinos
				for i,dino in dinos do
					local dist = (getDistance(dino.Instance, caveman.Instance)) 
					print("Dist from caveman: ", dist)
					if dist <= caveman.range then
						caveman.Attack(dino)
						if dino.health <= 0 then 
							warn("Dino health", dino.health)
							dino.Instance:Destroy()
							dino.Tween:Destroy()
							table.remove(DinoFactory.Dinos, i)
						end
					end
				end
			end

			task.wait(.5)
		end
		RoundHandler.EndRound()
	end)
end

function RoundHandler.EndRound()
	MinDinoSpawn *= 2.5
	started = false
end

function RoundHandler.Init()

end

function RoundHandler.Start()

end

return RoundHandler