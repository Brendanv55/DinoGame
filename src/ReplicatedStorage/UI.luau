
local Player = game.Players.LocalPlayer
local ScreenGui = Player:WaitForChild("PlayerGui", 30)
local Holder = ScreenGui:WaitForChild("UI", 30):WaitForChild("Holder", 30)
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")

local CavemanFactory = require(`./CavemanFactory`)
local RoundHandler = require(`./RoundHandler`)

local UiHandler = {}

local SpawnSelect = "None"
local IsDragging = false

function UiHandler.Init()
	--Init Spawn Menu
	
	for i,v in Holder.Points:GetChildren() do
		v.Visible = false
	end
	
	for i,v in CavemanFactory.getTypes() do
		print(i,v)
		if v.sprites and not v.sprites.idle then continue end--print("Didnt pass check") continue end
		local c : ImageButton = Holder.SpawnList.ScrollingFrame.Template:Clone()

		c.Name = i
		c.Image = v.sprites.idle
		c.Visible = true
		
		c.InputBegan:Connect(function(input : InputObject)
			if IsDragging then return end
			--Not gonna add mobile support sorry
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			game.ReplicatedStorage.Sounds["mouse click"]:Play()
			SpawnSelect = c.Name
			Holder.Place.TextLabel.Text = `Spawn Caveman: {SpawnSelect}`
		end)

		c.Parent = Holder.SpawnList.ScrollingFrame
	end
	
	--Holder.SpawnList.ScrollingFrame.CanvasSize = UDim2.fromOffset(Holder.SpawnList.ScrollingFrame.UIListLayout.AbsoluteContentSize.X,0)
	
	Holder.Place.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 or SpawnSelect == "None" then return end
		game.ReplicatedStorage.Sounds["mouse click"]:Play()

		UiHandler.beginMousePlacing()
	end)
	
	Holder.Start.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		game.ReplicatedStorage.Sounds["mouse click"]:Play()
		RoundHandler.StartRound()
	end)
end

local event
local obj
function UiHandler.beginMousePlacing()
	obj = CavemanFactory.new(SpawnSelect)
	
	event = Mouse.Move:Connect(function()
		local pos = UserInputService:GetMouseLocation()
		obj.Instance.Position = UDim2.fromOffset(pos.x,pos.y)		
	end)
	
	Mouse.Button1Down:Connect(function()
		if SpawnSelect == "None" then event:Disconnect() return end 
		if not obj then event:Disconnect() return end
		game.ReplicatedStorage.Sounds["mouse click"]:Play()

		if (UiHandler.endMousePlacing()) then 
			SpawnSelect = "None"
			obj.Spawned = true
			Holder.Place.TextLabel.Text = `Spawn Caveman: {SpawnSelect}`
		else 
			game.ReplicatedStorage.Sounds.Error:Play()
		end
		--print(obj)
	end)
end

function UiHandler.endMousePlacing()
	--local success = true
	
	--for i,v in Holder.Bounds:GetChildren() do
	--	local topLeft = v.AbsolutePosition
	--	local bottomRight = topLeft + v.AbsoluteSize
		
	--	local frameTopLeft = obj.Instance.AbsolutePosition
	--	local frameBottomRight = frameTopLeft + obj.Instance.AbsoluteSize
	--	--if topLeft.X > frameTopLeft.X or topLeft.Y > frameTopLeft.Y
	--	--	and bottomRight.X < frameBottomRight.X or bottomRight.Y < frameBottomRight.Y
	--	--then
	--	if (
	--		topLeft.X < frameBottomRight.X and
	--			bottomRight.X > frameTopLeft.X and
	--			topLeft.Y < frameBottomRight.Y and
	--			bottomRight.Y > frameTopLeft.Y
	--		) then
			
	--		success = false		
	--	end
	--end
	
	
	return true
end

local DinosEscaped = 0

function UiHandler.DinoEscaped()
	DinosEscaped += 1
	if (DinosEscaped > 3) then
		Holder.GameOver.Visible = true
		if game:GetService("SoundService"):FindFirstChild("Undertale - [Neutral run] sans").Playing == false then
			game.ReplicatedStorage.Sounds["Undertale - [Neutral run] sans"]:Play()
		end
	end
end
	
function UiHandler.Start()
	
end

return UiHandler