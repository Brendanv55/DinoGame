
local Player = game.Players.LocalPlayer
local ScreenGui = Player:WaitForChild("PlayerGui", 30)
local Holder = ScreenGui:WaitForChild("UI", 30):WaitForChild("Holder", 30)
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")

local CavemanFactory = require(`./CavemanFactory`)

local UiHandler = {}

local SpawnSelect = "None"
local IsDragging = false

function UiHandler.Init()
	--Init Spawn Menu
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
		
		UiHandler.beginMousePlacing()
	end)
end

local event
local obj
function UiHandler.beginMousePlacing()
	obj = CavemanFactory.new(SpawnSelect)
	
	event = Mouse.Move:Connect(function()
		local pos = UserInputService:GetMouseLocation()
		obj.Instance.Position = UDim2.fromOffset(pos.x,pos.y)		
		print(pos)
	end)
	
	Mouse.Button1Down:Connect(function()
		if SpawnSelect == "None" then event:Disconnect() return end 
		if not obj then event:Disconnect() return end
		
		if (UiHandler.endMousePlacing()) then 
			SpawnSelect = "None"
			obj.Spawned = true
			Holder.Place.TextLabel.Text = `Spawn Caveman: {SpawnSelect}`
		end
	end)
end

function UiHandler.endMousePlacing()
	local success = true
	--TODO: CHECK DIST FROM PATH
	return success
end

function UiHandler.Start()
	
end

return UiHandler