local VastOSLogger = {}
VastOSLogger.__index = VastOSLogger

--Create new logger instance in given VastOS instance, in specific topic (defaults to "Log"), with specific prefix (defaults to "Log: "), and specific log function (defaults to print).
function VastOSLogger:new(vastOSInstance, logTopicName, logPrefix, logCallback)
	local o = {}
	setmetatable(o, self)
	o.vastOSInstance = vastOSInstance
	o.logTopicName = logTopicName or "Log"
	o.logPrefix = logPrefix or "Log: "
	o.logCallback = logCallback or print
	vastOSInstance:subscribeToTopic(o.logTopicName, function(data)
		o.logCallback(o.logPrefix .. data)
	end)
	return o
end

--Send message to log topic.
function VastOSLogger:print(msg)
	self.vastOSInstance:sendToTopic(self.logTopicName, msg)
end

return VastOSLogger
