local VastOS = {
	threads = {},
	counter = 0,
}

function VastOS:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function VastOS:mkThread(co, priority)
	priority = priority or 1
	table.insert(self.threads, { co = co, priority = priority, lastExec = self.counter })
end

function VastOS:tick()
	local result = true
	if #self.threads > 0 then
		local mostImportantThrId = -1
		local mostImportantThrVal = -1
		for k, v in ipairs(self.threads) do
			local val = (self.counter - v.lastExec + 1) * v.priority
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
