-- Return a table entry that is an integral-value.
local function foo(thing)
	return thing.z.w
end

-- Construt a new reference-value based on a table entry.
local function bar(thing)
	local z = { w = thing.z.w }
	return z
end

-- Return a reference-value from a table.
local function baz(thing)
	return thing.z
end

local a = { x=0, y=1, z={w=0} }

-- This will be an integral-value.
local z1 = foo(a)
-- This will be a new reference-value, a copy.
local z2 = bar(a)
-- This will be a reference-value into the table.
local z3 = baz(a)

-- This should still print 0 as z1 is an integral-value.
local z1 = 1
print("Should be 0: " .. a.z.w)

-- This should print 0 and then 2 as we're writing to the
-- copy. If this was a reference-value we'd expect the
-- same value.
z2.w = 2
print("Should be 0: " .. a.z.w)
print("Should be 2: " .. z2.w)

-- This should print 3 both times as we're modifying though
-- the reference-value.
z3.w = 3
print("Should be 3: " .. a.z.w)
print("Should be 3: " .. z3.w)

local function printkvps(l)
	for k, v in pairs(l) do
		print(k .. "=" .. v)
	end
end

-- You might think this modifies the table, but it doesn't,
-- because pairs() returns an index and value tuple, not an
-- an index and value-reference tuple.
local b = { 0, 1, 2 }

for k,v in pairs(b) do
	v = v + 1
	-- a[k] = v + 1
end

printkvps(b)

-- Instead you need to manipulate the table directly via
-- the key generated from pairs.
for k,v in pairs(b) do
	b[k] = v + 1
end

printkvps(b)
