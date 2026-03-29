--[[
class DinoType {
	static T_REX = new DinoType('T-REX', { Strength: 10, Sprites: ['assets/dino1.png'] })
	constructor(label, attributes) {
		this.label = label
		Object.assign(this, attributes)
	}
}

let activeDinos = {};
let counter = 0;
let dinoImg = [loadImage('assets/dino1.png'),loadImage('assets/dino2.png'),loadImage('assets/dino3.png')];

class Dino {
	constructor(type) {
		this.Position = createVector([0], [0]);
		this.Strength = type.Strength;
		this.Name = type.label;



		activeDinos[counter++] = this
	}
	show(){
		fill("#ff0000");
		circle(this.Position[0], this.Positon[1], this.Strength);
		image(dinoImg[1], this.Position[0], this.Position[1]);
	}

	getDamage() {
		return this.Strength
	}

	deleteDino() {
		delete activeDinos[this.Name]
		delete this
	}
}
]]--
local Player = game.Players.LocalPlayer
local ScreenGui = Player:WaitForChild("PlayerGui", 30)
local Holder = ScreenGui:WaitForChild("UI", 30):WaitForChild("Holder", 30)


local DinoTypes = {
	T_Rex = { speed = 1, health = 5, strength = 5, sprites = {"rbxassetid://119840615152551", "rbxassetid://114642092403003"} },
	Spinosaurus = { speed = 1, health = 3, strength = 3 },
	Triceratops = { speed = 1, health = 7, strength = 1 },
	Pterodactyl = {speed = 3, health = 3, strength = 2 },
	Brontosaurus = {speed = 1, health = 10, strength = 2},
	Velociraptor = {speed = 5, health = 3, strength = 2},

}

local DinoFactory = {
	Dinos = {},
	Types = DinoTypes	
}

local counter = 0

function DinoFactory.new(dType)
	local self = setmetatable({}, {__index = DinoFactory})
	
	counter += 1
	self.id = counter 
	
	local data = DinoTypes[dType]
	if typeof(data) ~= "table" then warn(`Invalid Dino Type: {dType} Selecting random..`)
		
		-- Have to select random num then loop until reached bc non int indexes
		local num = math.random(1, #DinoTypes)
		for i = 1, num do
			local i,v  = next(DinoTypes)
			if (i == num) then data = v end
		end
		print("Selected: ")
		
	end
	
	for i,v in dType do 
		self[i] = v
	end
	local inst = Instance.new("ImageLabel")
	inst.Parent = Holder.Dino
	inst.Name = self.id
	inst.Position = UDim2.fromScale(0.5,0.5)	

	self.Instance = inst
	
	table.insert(DinoFactory.Dinos, self)
	
	return self	
end


function DinoFactory.Init()
	
end

function DinoFactory.Start()

end


return DinoFactory