local stringUtils = {}

function stringUtils.toUpperCamelCase(str: string): string
	return (
		str:gsub("(%a)([%w_']*)", function(first, rest)
			return first:upper() .. rest:lower()
		end):gsub("[ _]", "")
	)
end

return stringUtils
