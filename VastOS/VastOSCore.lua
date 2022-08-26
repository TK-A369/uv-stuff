local VastOS = {
	counter = 0,
	threads = {},
	topics = {},
	services = {},
}

function VastOS:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function VastOS:mkThread(co, priority)
	priority = priority or 1
	table.insert(self.threads, { co = co, priority = priority, bonusPriority = 0, lastExec = self.counter })
end

function VastOS:subscribeToTopic(topicName, handler)
	local topic = self.topics[topicName]
	if topic then
		table.insert(topic.subscribers, handler)
	else
		topic = { subscribers = { handler } }
		self.topics[topicName] = topic
	end
end

function VastOS:sendToTopic(topicName, data)
	local topic = self.topics[topicName]
	if not topic then
		topic = { subscribers = {} }
		self.topics[topicName] = topic
	end
	for _, v in ipairs(topic.subscribers) do
		if type(v) == "function" then
			v(data)
		elseif type(v) == "thread" then
			while coroutine.status(v) ~= "dead" do
				coroutine.resume(v, data)
			end
		end
	end
end

function VastOS:registerService(serviceName, handler)
	local service = { handler = handler }
	self.services[serviceName] = service
end

function VastOS:callService(serviceName, ...)
	local service = self.services[serviceName]
	if service then
		local handler = service.handler
		if type(handler) == "function" then
			handler(...)
		elseif type(handler) == "thread" then
			while coroutine.status(handler) ~= "dead" do
				coroutine.resume(handler, ...)
			end
		end
	end
end

function VastOS:tick()
	local result = true
	if #self.threads > 0 then
		local mostImportantThrId = -1
		local mostImportantThrVal = -1
		for k, v in ipairs(self.threads) do
			local val = (self.counter - v.lastExec + 1) * (v.priority + v.bonusPriority)
			if val > mostImportantThrVal then
				mostImportantThrVal = val
				mostImportantThrId = k
			end
		end

		self.threads[mostImportantThrId].lastExec = self.counter
		coroutine.resume(self.threads[mostImportantThrId].co)

		local status = coroutine.status(self.threads[mostImportantThrId].co)
		if status == "dead" then
			table.remove(self.threads, mostImportantThrId)
		end
	else
		result = false
	end

	self.counter = self.counter + 1

	return result
end

return VastOS
