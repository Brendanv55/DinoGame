--[[
let path = [[0, 4], [ 1, 5], [2, 6] , [4, 6], [6,5


class Segment {
	constructor (x0, y0, x1, y1, x2, y2, x3, y3) {
		this.a = createVector(x0, y0);
		this.b = createVector(x1, y1);
		this.c = createVector(x2, y2);
		this.d = createVector(x3, y3);
	}
}

let alpha = 0.5;
let tension = 0;

class Spline {
	constructor (segments) {

	}

	draw() {

	}
}


class Map {
	constructor() {}



	getPointAlong(i) {

	}
}

function path(){
	let x1,y1=50;
	let xanchor1,yanchor1=100;
	let x2,y2=70;
	let xanchor2,yanchor2=200;
	fill("black");
	curve(x1,y1,xanchor1,yanchor1,x2,y2,xanchor2,yanchor2);
	}]]--
local Player = game.Players.LocalPlayer
local ScreenGui = Player:WaitForChild("PlayerGui", 30)
local Holder = ScreenGui:WaitForChild("UI", 30):WaitForChild("Holder", 30)

local Bezier = require(script.Bezier)
local Line = require(script.Line)
local BezierTween = require(script.BezierTween)

local Map = {
	Points = {},
	Tweens = {}
}

local offset = Vector2.new(0, 36)


function Map.Init()
	--[[
	
	for i = 1, #Map.Points, 3 do
		local p0 = Map.Points[i]
		local p1 = Map.Points[i + 1]
		local p2 = Map.Points[i + 2]
		local p3 = Map.Points[i + 3]
		
		local bez = Bezier.new(p0, p3)
		local points = bez:Cubic(0, p1, p2)
		
		print(i)
		for j, v in ipairs(points) do
			local p = game.ReplicatedStorage.Assets.CurvePoint:Clone()
			p.Position = UDim2.new(0, v.x, 0, v.y)
			p.Parent = Holder.Path

			if points[j - 1] then
				Line(points[j - 1].x, points[j - 1].y, v.x, v.y, Holder.Path, 2, Color3.new(0,0,0))
			end
		end
	end
	]]
	local list = {}
	for i = 1, 6 do
		--local pt = Holder.Points[i]
		list[i] = Holder.Points[i].Position
		--list[i] = pt.AbsolutePosition + pt.AbsoluteSize/2 + offset
	end

	
	--local t = BezierTween.Create(Holder.ImageLabel, {20, 'Quad', 'Out'}, {
	--	Position = list })

	
	--t:Play()
end

function Map.Start()

end


return Map