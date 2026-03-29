--[[class CavemanType{
    static Puncher = new DinoType('Puncher', { speed: 1, range: 2, strength: 2 })
    constructor(attributes) {
        Object.assign(this, attributes)
    }
}

class Caveman{
    constructor(posX, posY, speed, range, strength, id){
        this.posX =posX;
        this.posY =posY;
        this.speed =speed;
        this.range =range;
        this.strength = strength;
        this.id = id;
    };
    show(){
        fill("#000000");
        circle(this.posX, this.posY, this.range);
    }
    calculateClosestDino(dinoList){
        //for each existing dino, calculate if dist(self, dino) < range and save smallest number
        //return dino within range with least distance
        
    }
    attack(closestDinoID){
        //play attack animation and deal strength damage to selected dino
    }


}]]--
local Player = game.Players.LocalPlayer
local ScreenGui = Player:WaitForChild("PlayerGui", 30)
local Holder = ScreenGui:WaitForChild("UI", 30):WaitForChild("Holder", 30)

local CavemanTypes = {
	Puncher = { speed = 1, range = 350, strength = 2 , sprites = {
		idle = "rbxassetid://74014618647914",
		attacking = {"rbxassetid://106875033114893", "rbxassetid://105113058766576"}
	}},
	Clubber = { speed = 1, range = 3, strength = 4, sprites = {} },
	Thrower = { speed = 2, range = 7, strength = 1 , sprites = {}},
	Launcher = {speed = 2, range = 9, strength = 2 , sprites = {}},
	Spearer = {speed = 5, range = 10, strength = 8, sprites = {}},
	Torcher = {speed = 5, range = 10, strength = 12, sprites = {}},
	Blaster = {speed = 10, range = 15, strength = 10, sprites = {}},
}


local CavemanFactory = {
	activeCaveman = {},
	--Types = CavemanTypes
}
CavemanFactory.__index = CavemanFactory


function CavemanFactory.getTypes()
	return CavemanTypes
end


local counter = 0
function CavemanFactory.new(cType)
	local self = setmetatable({},{__index = CavemanFactory})
	
	counter += 1;
	self.id = counter 
	
	-- Access types with paramter getting data & reassign variable to the table
	local data = CavemanTypes[cType]
	
	if typeof(data) ~= "table" then warn(`Invalid Dino Type: {cType} Selecting random..`)

		-- Have to select random num then loop until reached bc non int indexes
		local num = math.random(1, #CavemanTypes)
		for i = 1, num do
			local i,v  = next(CavemanTypes)
			if (i == num) then data = v end
		end

	end
	
	--insert data
	for i,v in data do 
		self[i] = v
	end
		
	self.Attacking = false
	self.AttackDebounce = tick()
	self.SpriteIndex = -1
	self.Spawned = false
	
	function self.Attack(dino)
		if self.Attacking then return end
		self.Attacking = true
		
		dino.health -= self.strength
		
		local bonk = game.ReplicatedStorage.Sounds.Bonk:Clone()
		
		bonk.PlaybackSpeed = math.random(100, 250)/100
		bonk.Parent = game.ReplicatedStorage

		bonk:Play()
		game.Debris:AddItem(bonk, bonk.TimeLength)
		
		self.AttackDebounce = tick() + self.strength
		
		task.delay(1, function() self.Attacking = false end)
	end
	

	
	--Create Image Label
	local inst = Instance.new("ImageLabel")
	inst.Name = self.id
	inst.Size = UDim2.fromScale(0.1,0.15)	
	inst.BackgroundTransparency = 1	
	inst.Image = self.sprites.idle
	self.Instance = inst
	
	inst.Parent = Holder.Caveman

	
	table.insert(CavemanFactory.activeCaveman, self)

	
	return self	
end


function CavemanFactory.Init()
end


function CavemanFactory.Start()
	task.spawn(function()
		while true do
			for _, obj in CavemanFactory.activeCaveman do
				--print(obj)
				if not obj.Spawned or obj == nil then continue end
				local attacking: {} = obj.sprites.attacking 
				if obj.Attacking then 
					obj.SpriteIndex = (obj.SpriteIndex + 1) % #attacking + 1 -- +1 bc starting at 1
					--print(obj.SpriteIndex)
					obj.Instance.Image = attacking[obj.SpriteIndex]
				else 
					obj.Instance.Image = obj.sprites.idle
				end
			end
			
			task.wait(.5)
		end
	end)
end


return CavemanFactory