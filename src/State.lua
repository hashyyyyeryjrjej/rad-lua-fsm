local State = {}
State.__index = State
State.__call = function (self)
	self.fsm:switch(self)
end
--State.__tostring = function (self)
--	return self.name
--end

function State:leave()
	-- Modifiable
end

function State:enter()
	-- Modifiable
end

function State.new(fsm, dictionary)
	assert(fsm, 
		"Expected argument #1, got nil")
	
	local self = setmetatable({}, State)
	
	self.fsm = fsm
	self.name = dictionary.name
	self.from = dictionary.from
	
	local callbacks = dictionary.callbacks
	if callbacks then
		self.enter = if callbacks.enter then callbacks.enter else nil
		self.leave = if callbacks.leave then callbacks.leave else nil
	end
	
	-- These events are fired by the FSM
	-- enter and leave functions may change so that guarantees these fire
	self._onEnter = Instance.new("BindableEvent")
	self.onEnter = self._onEnter.Event
	self._onLeave = Instance.new("BindableEvent")
	self.onLeave = self._onLeave.Event
	
	return self
end

return State
