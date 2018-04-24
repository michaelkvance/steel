local vec2d_t = {}
do
	local meta = {
		_metatable = "Private metatable for vec2d_t",
		_DESCRIPTION = "2D vector interface"
	}

	meta.__index = meta

	function meta:__tostring()
		return ("{%g, %g}"):format(self.x, self.y)
	end

	function meta:__add(v)
		return vec2d_t(self.x + v.x, self.y + v.y)
	end

	function meta:__mul(v)
		return vec2d_t(self.x * v.x, self.y * v.y)
	end

	function meta:length2()
		return self.x * self.x + self.y * self.y
	end

	function meta:length()
		return math.sqrt(self:length2())
	end

	function meta:rotate(theta)
		local t = theta * math.pi/180.0
		local st = math.sin(t)
		local ct = math.cos(t)
		local r00 = ct
		local r01 = -st
		local r10 = st
		local r11 = ct
		local vx = self.x
		local vy = self.y
		local xp = (vx*ct)-(vy*st)
		local yp = (vx*st)+(vy*ct)
		return vec2d_t:new(xp, yp)	
	end

	setmetatable( vec2d_t, {
		__call = function( v, x, y )
			return setmetatable( {x=x, y=y}, meta )
		end
	} )
end

vec2d_t.__index = vec2d_t

return vec2d_t
