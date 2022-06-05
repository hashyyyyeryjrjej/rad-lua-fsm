local FSM = {}
FSM.__index = FSM

--FSM.__tostring = function (self)
--	return tostring(self:currentState())
--end

FSM.__eq = function (self, value)
	if self == value or self.name == value or typeof(value) == "table" and self.name == value.name then
		return true
	end
	
	return false
end

-- Dependencies

local State = require(script.State)
local Group = require(script.Group)

-- Logic

function FSM:switch(targetState)
	assert(targetState,
		"Expected argument #1, got nil")
	
	local state = self:currentState()
	
	if state == targetState then
		warn("State is already set")
		return
	end
	
	if state and targetState.from and targetState.from ~= state.name then
		warn("State origin doesn't match")
		return
	end
	
	if state then
		state:leave(); state._onLeave:Fire()
	end
	
	targetState:enter(); targetState._onEnter:Fire()
	self.state = targetState
end

function FSM:getState(target: string)
	assert(target,
		"Expected argument #1, got nil")

	for __, state in self.states do
		if state.name == target then
			return state
		end
	end

	return nil
end

function FSM:getGroup(target: string)
	assert(target,
		"Expected argument #1, got nil")
	
	for __, group in self.groups do
		if group.name == target then
			return group
		end
	end
	
	return nil
end

function FSM:currentState()
	return self.state or nil
end

function FSM:build(states, groups)
	self.states = {}
	self.groups = {}
	
	if not states then
		return
	end
	
	for index, state in states do
		local instance = State.new(self, state)
		
		self[index] = instance
		self.states[index] = instance
		
		-- Creates the natural "FSM.onState" shortcuts
		local format = instance.name:gsub(instance.name:sub(1,1), string.upper, 1)
		self["on" .. format] = instance.onEnter
		self["on" .. format .. "Leave"] = instance.onLeave
	end
	
	if not groups then
		return
	end
	
	for index, group in groups do
		local instance = Group.new(index)
		
		for __, state in group do
			instance:add(self:getState(state))
		end
		
		self.groups[index] = instance
	end
end

function FSM.new(dictionary: {states: {}, groups: {}, default: string?})
	local self = setmetatable({}, FSM)
	
	self.state = nil
	self.states = {}
	self.groups = {}
	
	local defaultState = dictionary.default or "idle"
	if not dictionary.states[defaultState] then
		dictionary.states[defaultState] = {name = defaultState}
	end
	
	self:build(dictionary.states, dictionary.groups)
	self:switch(self:getState(dictionary.default or "idle"))
	
	return self
end

return FSM
