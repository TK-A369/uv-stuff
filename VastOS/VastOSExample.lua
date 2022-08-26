local VastOSCore = require("VastOSCore")

local vastOS = VastOSCore:new()

vastOS:mkThread(
	coroutine.create(function()
		vastOS:subscribeToTopic("testTopic", function(data)
			print("Thread 1 received data: " .. data)
		end)
		print("Thread 1")
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

vastOS:subscribeToTopic("testTopic", function(data)
	print("Main program received data: " .. data)
end)

vastOS:sendToTopic("testTopic", "I'm main program!")

while vastOS:tick() do
end
