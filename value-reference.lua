local function foo(thing)
	return thing.z.w
end

local function bar(thing)
	local z = { w = thing.z.w }
	return z
end

local function baz(thing)
	return thing.z
end

a = { x=0, y=1, z={w=0} }
z1 = foo(a)
z2 = bar(a)
z3 = baz(a)
z1 = 1
print(a.z.w)
z2.w = 2
print(z2.w)
z3.w = 3
print(a.z.w)
