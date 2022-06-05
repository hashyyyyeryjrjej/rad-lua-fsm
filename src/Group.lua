local Group = {}
Group.__index = Group

function Group:has(target): boolean
	for _, state in self.states do
		if state == target then
			return true
		end
	end
	
	return false
end

function Group:add(state)
	if not table.find(self.states, state) then
		table.insert(self.states, state)
	end
end

function Group.new(name: string)
	local self = setmetatable({}, Group)
	
	self.name = name
	self.states = {}
	
	return self
end

return Group
