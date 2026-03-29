
local Player = game.Players.LocalPlayer
local ScreenGui = Player:WaitForChild("PlayerGui", 30)
local Holder = ScreenGui:WaitForChild("UI", 30):WaitForChild("Holder", 30)


local RoundHandler = {}

function RoundHandler.Init()
	for i,v in Holder.Points:GetChildren() do
		v.Visible = false
	end
end

function RoundHandler.Start()
	
end

return RoundHandler