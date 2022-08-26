local VastOSLogger = {
	vastOSInstance = nil,
	logTopicName = "Log",
}

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

function VastOSLogger:print(msg)
	self.vastOSInstance:sendToTopic(self.logTopicName, msg)
end

return VastOSLogger
