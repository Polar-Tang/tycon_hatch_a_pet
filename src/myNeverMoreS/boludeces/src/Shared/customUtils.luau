local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observable = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Observable)
local customUtils = {} 


--[=[
	Observes an instance's attribute

	@param instance Instance
	@param attributeName string
	@return Observable<T>
]=]
function customUtils.observeAttribute(instance: Instance, attributeName: string): Observable.Observable<any>
	assert(typeof(instance) == "Instance", "'instance' should be of type Instance")
	assert(type(attributeName) == "string", "'attributeName' should be of type string")
	assert(instance:GetAttribute(attributeName), "'instance' should have " .. attributeName .. " 'attributeName'")

	return Observable.new(function(sub)
		local attribute: any = instance:GetAttribute(attributeName)
		local connection = instance:GetAttributeChangedSignal(attributeName):Connect(function()
			sub:Fire(attribute, instance)
		end)
		sub:Fire(attribute, instance)

		return connection
	end)
end
return customUtils