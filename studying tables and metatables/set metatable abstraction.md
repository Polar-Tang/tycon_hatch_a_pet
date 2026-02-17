I need to insist you the exhausted execution time is not there. I affirm that the issue comes from an improperly state management of a table.
This code is lua 5.1 and it doesn't break:

```lua

Account = { balance=0,

withdraw = function (self, v)

self.balance = self.balance - v

end

}

function Account:deposit (v)

self.balance = self.balance + v

end

Account.deposit(Account, 200.00)

Account:withdraw(100.00)

```

However it lacks inheritance, and privacy, we cannot have several objects with similar behavior. To implement prototypes:
```lua
function Account:new (o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end
```
`self` is equal to `Account`, it have all its methods like withdraw or deposit
```lua
a = Account:new{balance = 0}
a:deposit(100.00)
```
we are actually calling `a.deposit(a, 100.00)`, we are using the a data with the Account functions __index` entry, and other fields that are absent in the new account.

 To make an ability spec to be a prototype for the ability class is like this?
```lua
if data.type == "Defense" then

setmetatable(DefenseBaseAbility, {__index = externalMethods})

skill = setmetatable(DefenseBaseAbility.new(data), data)
```