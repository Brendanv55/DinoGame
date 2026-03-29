
local modules = {}

for i,v in game.ReplicatedStorage.Modules:GetChildren() do
	if v:IsA("ModuleScript") then
		if v.Name:sub(0,1) == "_" then continue end
		print(`Loading {v.Name}`)
		--local succ, err = pcall(function()
			local module = require(v)
			module.Init()
			table.insert(modules, module)
		--end)
		--if not succ then warn(err) end
	end
end

for i,v in modules do
	v.Start()
end