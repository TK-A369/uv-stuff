local VastOS = {
	counter = 0,
	threads = {},
	topics = {},
	services = {},
}

--Create new VastOS instace.
function VastOS:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

--Create new thread.
function VastOS:mkThread(co, priority)
	priority = priority or 1
	table.insert(self.threads, { co = co, priority = priority, bonusPriority = 0, lastExec = self.counter })
end

--When data is sent to that topic, execute handler function or coroutine.
function VastOS:subscribeToTopic(topicName, handler)
	local topic = self.topics[topicName]
	if topic then
		table.insert(topic.subscribers, handler)
	else
		topic = { subscribers = { handler } }
		self.topics[topicName] = topic
	end
end

--Sends data to the given topic.
function VastOS:sendToTopic(topicName, data)
	local topic = self.topics[topicName]
	if not topic then
		topic = { subscribers = {} }
		self.topics[topicName] = topic
	end
	for _, v in ipairs(topic.subscribers) do
		if type(v) == "function" then
			print("Invoking topic handler function!")
			v(data)
		elseif type(v) == "thread" then
			print("Resuming topic handler coroutine!")
			while coroutine.status(v) ~= "dead" do
				coroutine.resume(v, data)
			end
		end
	end
end

--Create new service. When it's called, executes handler function or coroutine.
function VastOS:registerService(serviceName, handler)
	local service = { handler = handler }
	self.services[serviceName] = service
end

--Call service (if it exists), and return its reply.
function VastOS:callService(serviceName, ...)
	local service = self.services[serviceName]
	if service then
		local handler = service.handler
		if type(handler) == "function" then
			return handler(...)
		elseif type(handler) == "thread" then
			local results = {}
			while coroutine.status(handler) ~= "dead" do
				results = table.pack(coroutine.resume(handler, ...))
			end
			return table.unpack(results)
		end
	end
end

--This should be called continuously. This function resumes threads. Returns false when all threads terminated, otherwise true.
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
