local VastOSLogger = {
	vastOSInstance = nil,
	logTopicName = "Log",
}

--Create new logger instance in given VastOS instance, and in specific topic (defaults to "Log").
function VastOSLogger:new(vastOSInstance, logTopicName, o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	self.vastOSInstance = vastOSInstance
	if logTopicName then
		self.logTopicName = logTopicName
	end
	vastOSInstance:subscribeToTopic(self.logTopicName, function(data)
		print("Log: " .. data)
	end)
	return o
end

--Send message to log topic.
function VastOSLogger:print(msg)
	self.vastOSInstance:sendToTopic(self.logTopicName, msg)
end

return VastOSLogger
