local vec2d_t = require 'vec2d_t'

local lhs = vec2d_t(1,1)
local rhs = vec2d_t(2,2)
print(lhs)
print(rhs)
local summed = lhs + rhs
local mulled = lhs * rhs
print(summed)
print(mulled)
print(mulled:length())