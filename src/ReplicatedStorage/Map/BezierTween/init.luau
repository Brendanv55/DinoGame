--[[
	BezierTween
	
	By: ltsRealJr
	Credits: https://devforum.roblox.com/t/bhristts-bezier-curve-module-tween-support/1510751
	
	Version: 0.0.2

	This module uses TweenService to create animations using Bezier curves.
	Unlike regular tweens which only allow for start and end points,
	BezierTween enables you to define multiple control points for your animations
	
	Key features:

	- Create smooth transitions between multiple control points
	- Compatible with CFrame, Vector3, UDim, Color, and more
	- Provides familiar tween methods (Play, Pause, Cancel) and events (Completed)
	- Works on UI Objects and Non-UI objects
	- Accepts EndPos as BasePart

	Constructor:
	    BezierTween.Create(Object: Instance, Info: table | TweenInfo, Properties: table)
	        - Object: The instance whose properties will be tweened
	        - Info: Either a table of tween parameters [Duration, EasingStyle, EasingDirection] or a TweenInfo object
	        - Properties: A table of properties to tween with their end values or control points

	Methods:
	    :Play()
	        - Starts or resumes the tween
	    
	    :Pause()
	        - Pauses the tween at its current position
	    
	    :Cancel()
	        - Cancels the tween and returns properties to their original values
	    
	    :Destroy()
	        - Cleans up the tween and removes all connections

	Events:
	    .Completed
	        - Signal that fires when the tween completes naturally

	Static Methods:
	    BezierTween.CleanupInstance(Object: Instance)
	        - Cleans up all tweens associated with the given object

	Examples:
	
	With no Control Points:
		local Part = workspace.Part
		local Tween = BezierTween.Create(Part, {1, 'Quad', 'Out'}, {
		    Position = Vector3.new(10, 10, 10)
		})
		Tween:Play()
		
	With Control Points:
		local Part = workspace.Part
		local StartPos = Part.Position
		local EndPos = StartPos
		local Tween = BezierTween.Create(Part, {1, 'Quad', 'Out'}, {
		    Position = {
		    	StartPos,
		    	StartPos + Vector3.new(0, 10, 0),
		    	EndPos
		    }
		})
		Tween:Play()
]]

-- [[ Services ]] --
local TweenService = game:GetService'TweenService'

-- [[ Tables ]] --
local BezierTween = {}
local ActiveInstanceTweens = {}

-- [[ Modules ]] --
local Utils = require(script:WaitForChild'Utils')

-- [[ Helper Functions ]] --
local function GetTweenInfo(Info)
	if type(Info) == 'table' then
		return TweenInfo.new(
			Info[1] or 1,
			typeof(Info[2]) == 'EnumItem' and Info[2] or Enum.EasingStyle[Info[2] or 'Sine'],
			typeof(Info[3]) == 'EnumItem' and Info[3] or Enum.EasingDirection[Info[3] or 'Out'],
			Info[4] or 0,
			Info[5] ~= nil and Info[5] or false,
			Info[6] or 0
		)
	elseif typeof(Info) == 'TweenInfo' then
		return Info
	else
		return TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
	end
end

-- [[ Types ]] --
export type TweenMethods = {
	Play: (self: any) -> (),
	Pause: (self: any) -> (),
	Cancel: (self: any) -> (),
	Destroy: (self: any) -> (),
	Completed: RBXScriptSignal
}

local function CancelExistingTweens(Object, Properties)
	if not ActiveInstanceTweens[Object] then
		ActiveInstanceTweens[Object] = {}
		return
	end

	for Property, _ in Properties do
		local ExistingTween = ActiveInstanceTweens[Object][Property]
		if ExistingTween then
			if ExistingTween.NumValue then
				if ExistingTween.Connections then
					for _, Con in ExistingTween.Connections do
						Con:Disconnect()
					end
				end
				ExistingTween.NumValue:Destroy()
			end
			if ExistingTween.Tween then
				ExistingTween.Tween:Cancel()
			end
			ActiveInstanceTweens[Object][Property] = nil
		end
	end
end

local function CleanupTween(Object, Property)
	if ActiveInstanceTweens[Object] then
		ActiveInstanceTweens[Object][Property] = nil

		local HasRemainingTweens = false
		for _, _ in ActiveInstanceTweens[Object] do
			HasRemainingTweens = true
			break
		end

		if not HasRemainingTweens then
			ActiveInstanceTweens[Object] = nil
		end
	end
end

-- [[ Module ]] --
function BezierTween.Create(Object, Info, Properties): TweenMethods
	if not Object or not Properties then
		warn'BezierTween: Invalid arguments - Object or Properties are nil'
		return nil
	end

	CancelExistingTweens(Object, Properties)

	local NumValue = Instance.new'NumberValue'
	local TweenInfoObj = GetTweenInfo(Info)
	local Tween = TweenService:Create(NumValue, TweenInfoObj, {Value = 1})

	local ControlPoints = {}
	local HasValidProperties = false

	for Property, EndValue in Properties do
		local Success, StartValue = pcall(function() return Object[Property] end)
		if not Success or StartValue == nil then 
			warn(`BezierTween: Property {Property} does not exist on the object`) 
			continue 
		end

		local Points = {StartValue}

		if typeof(EndValue) == 'table' then
			for I = 1, #EndValue - 1 do
				table.insert(Points, EndValue[I])
			end
			table.insert(Points, EndValue[#EndValue])
		else
			table.insert(Points, EndValue)
		end

		ControlPoints[Property] = Points
		HasValidProperties = true
	end

	if not HasValidProperties then
		warn'BezierTween: No valid properties to tween'
		NumValue:Destroy()
		return nil
	end

	local Connections = {}

	local PropertyUpdaters = {}
	for Property, Points in ControlPoints do
		local Success = pcall(function()
			local TestVal = Object[Property]
			return TestVal ~= nil
		end)

		if Success then
			PropertyUpdaters[Property] = function(T)
				Object[Property] = Utils.BezierPoint(Points, T)
			end
		end
	end

	table.insert(Connections, NumValue.Changed:Connect(function(T)
		for _, UpdateFunc in PropertyUpdaters do
			UpdateFunc(T)
		end
	end))

	table.insert(Connections, Tween.Completed:Connect(function()
		for _, Con in Connections do
			Con:Disconnect()
		end

		NumValue:Destroy()

		for Property, _ in Properties do
			CleanupTween(Object, Property)
		end
	end))

	if typeof(Object) == 'Instance' then
		table.insert(Connections, Object.Destroying:Connect(function()
			for _, Con in Connections do
				Con:Disconnect()
			end

			if NumValue then
				NumValue:Destroy()
			end

			BezierTween.CleanupInstance(Object)
		end))
	end

	if not ActiveInstanceTweens[Object] then
		ActiveInstanceTweens[Object] = {}
	end

	for Property, _ in Properties do
		ActiveInstanceTweens[Object][Property] = {
			Tween = Tween,
			NumValue = NumValue,
			Connections = Connections
		}
	end

	local TweenWrapper = {
		_Tween = Tween,
		_Object = Object,
		_Properties = Properties,
		_NumValue = NumValue,
		Connections = Connections,

		Play = function(self)
			return self._Tween:Play()
		end,

		Pause = function(self)
			return self._Tween:Pause()
		end,

		Cancel = function(self)
			return self._Tween:Cancel()
		end,

		Destroy = function(self)
			if self._Tween then
				self._Tween:Cancel()
			end

			for _, Con in self.Connections do
				if Con then
					Con:Disconnect()
					Con = nil
				end
			end
			self.Connections = {}

			if self._NumValue then
				self._NumValue:Destroy()
				self._NumValue = nil
			end

			for Property, _ in self._Properties do
				CleanupTween(self._Object, Property)
			end
		end
	}

	TweenWrapper.Completed = Tween.Completed

	return TweenWrapper
end

function BezierTween.CleanupInstance(Object)
	if not Object or not ActiveInstanceTweens[Object] then return end

	for Property, TweenData in ActiveInstanceTweens[Object] do
		if TweenData.Tween then
			TweenData.Tween:Cancel()
		end

		if TweenData.Connections then
			for _, Con in TweenData.Connections do
				Con:Disconnect()
			end
		end

		if TweenData.NumValue then
			TweenData.NumValue:Destroy()
		end
	end

	ActiveInstanceTweens[Object] = nil
end

return BezierTween