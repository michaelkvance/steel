-- Walk the table and print its key-value pairs.
local function printkvps(a)
	for k, v in pairs(a) do
		print(k .. "=" .. v)
	end
end

-- Here we see a simple implicit integer indexed
-- table.
local a = { 1, 2, 3 }
printkvps(a)
--- Here we have a 'proper' named key table.
local b = { x = 0, y = 1, z = 2 }
printkvps(b)

-- We can also print a table via implicit integer
-- indices.
for index = 1,3 do
	print(a[index])
end
