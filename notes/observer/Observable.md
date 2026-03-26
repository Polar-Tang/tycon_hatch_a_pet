Observable are especial objects like signals, that do not fire until they subscribe
https://quenty.github.io/NevermoreEngine/api/Observable

Observable takes sub as an argument

 
 The `sub:Fire()` sends values **to the subscriber's callback**
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Observable = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Observable)

	-- Constucts an observable which will emit a, b, c via a subscription
	local observable = Observable.new(function(sub)
		print("Connected")
		sub:Fire("a")
		sub:Fire("b")
		sub:Fire("c")
		sub:Complete() -- ends stream
	end)

	local sub1 = observable:Subscribe() --> Connected
	local sub2 = observable:Subscribe() --> Connected
	local sub3 = observable:Subscribe() --> Connected
	--   ▶ Connected (x4)  -  Server - Main:95
  
	sub1:Destroy()
	sub2:Destroy()
	sub3:Destroy()

	observable:Subscribe(function(value)
	print("Got ", value) -- fire passes its value
	--[[
	20:53:59.049  Got  a  -  Server - Main:111
	20:53:59.049  Got  b  -  Server - Main:111
	20:53:59.049  Got  c  -  Server - Main:111
	]]
```

The Pipe transformers sit **between** the source and the subscriber. Each transformer **intercepts** the `Fire()` and processes it
```lua
-- 1. Create observable from property
local healthObservable = RxInstanceUtils.observeProperty(humanoid, "Health")

-- 2. Add transformers (Pipe)
local processedObservable = healthObservable:Pipe({
    Rx.map(function(health)
        return health * 2
    end)
})

-- 3. Subscribe
processedObservable:Subscribe(function(doubledHealth)
    print("Doubled health:", doubledHealth)
end)
```



```lua

```lua
Rx.of(context):Pipe({
	for _, modifier in ipars(self.)
	Rx.map(function(result)
		return result + 1
	end);
	Rx.map(function(value)
		return string.format("%0.2f", value)
	end);
}):Subscribe(print)
```
```