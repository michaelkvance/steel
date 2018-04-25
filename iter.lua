local function foo(a)
	for k, v in pairs(a) do
		print(k .. "=" .. v)
	end
end

local a = { 1, 2, 3 }
foo(a)
local b = { x = 0, y = 1, z = 2 }
foo(b)

for index = 1,3 do
	print(a[index])
end
