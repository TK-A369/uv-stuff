local VastOSCore = require("VastOSCore")

local vastOS = VastOSCore:new()

vastOS:mkThread(coroutine.create(function()
	print("Thread 1")
end))
vastOS:mkThread(
	coroutine.create(function()
		print("Thread 2a")
		coroutine.yield()
		print("Thread 2b")
		coroutine.yield()
		print("Thread 2c")
	end),
	2
)
vastOS:mkThread(coroutine.create(function()
	print("Thread 3a")
	print("Thread 3b")
	print("Thread 3c")
end))
vastOS:mkThread(coroutine.create(function()
	print("Thread 4")
end))

while vastOS:tick() do
end
