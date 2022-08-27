local VastOSCore = require("VastOSCore")
local VastOSLogger = require("VastOSLogger")

local vastOS = VastOSCore:new()

local logger1 = VastOSLogger:new(vastOS, "SomeLog", "[INFO] ", function(data)
	for _ = 1, 5 do
		print(data)
	end
end)
local logger2 = VastOSLogger:new(vastOS)

logger1:print("Starting1...")
logger2:print("Starting2...")

vastOS:mkThread(
	coroutine.create(function()
		vastOS:subscribeToTopic("testTopic", function(data)
			print("Thread 1 received data: " .. data)
		end)
		print("Thread 1")
		logger2:print("Thread 1 in log")
	end),
	1
)
vastOS:mkThread(
	coroutine.create(function()
		vastOS:subscribeToTopic("testTopic", function(data)
			print("Thread 2 received data: " .. data)
		end)
		print("Thread 2a")
		coroutine.yield()
		print("Thread 2b")
		coroutine.yield()
		print("Thread 2c")
		print("Thread 2 reply from calling service: " .. vastOS:callService("testService", "Thread 2 calling service!"))
	end),
	1
)
vastOS:mkThread(
	coroutine.create(function()
		vastOS:subscribeToTopic("testTopic", function(data)
			print("Thread 3 received data: " .. data)
		end)
		print("Thread 3a")
		print("Thread 3b")
		print("Thread 3c")
	end),
	1
)
vastOS:mkThread(
	coroutine.create(function()
		vastOS:subscribeToTopic("testTopic", function(data)
			print("Thread 4 received data: " .. data)
		end)
		print("Thread 4")
		vastOS:sendToTopic("testTopic", "I'm thread 4!")
		coroutine.yield()
		coroutine.yield()
		coroutine.yield()
		coroutine.yield()
		vastOS:sendToTopic("testTopic", "I'm thread 4, again!")
	end),
	1
)

logger1:print("Main program in log")

vastOS:subscribeToTopic("testTopic", function(data)
	print("Main program received data: " .. data)
end)

vastOS:sendToTopic("testTopic", "I'm main program!")

vastOS:registerService("testService", function(data)
	print("Main program received service call with data: " .. data)
	return "Some reply"
end)

while vastOS:tick() do
end
