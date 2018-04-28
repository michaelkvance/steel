pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- extends the composite type example with implicit operators

vec2d_t = { }
vec2d_mt_t = { __index = vec2d_t }

function vec2d_t:new(x, y)
	return setmetatable({x=x,y=y},vec2d_mt_t)
end 

function vec2d_t:set(x,y)
	return vec2d_t:new(x,y)
end

function vec2d_t:__add(a,b)
	return vec2d_t:new(a.x+b.x, a.y+b.y)
end

function vec2d_t:__mul(a,b)
	return vec2d_t:new(a.x*b.x, a.y*b.y)
end

function vec2d_t:rotate(theta)
	t = theta/360.0
	st = sin(t)
	ct = cos(t)
	vx = self.x
	vy = self.y
	xp = (vx*ct)-(vy*st)
	yp = (vx*st)+(vy*ct)
	return vec2d_t:new(xp, yp)	
end

origin=vec2d_t:new(64,64)
theta=0
radius=20

function _draw()
	cls()
	print("theta = " .. theta)
	print("radius = " .. radius)
	l = vec2d_t:new(radius,0)
	lp = l:rotate(theta)
	x = origin.x
	y = origin.y
	line(x,y,x+lp.x,y+lp.y,7)
end

function clamp(x, nx, mx)
	if (x < nx) return nx
	if (x > mx) return mx
	return x
end

function wrap(x, nx, mx)
	if (x < nx) return mx
	if (x > mx) return nx
	return x
end

function _update()
	if (btn(0)) then theta += 1 end
	if (btn(1)) then theta -= 1 end
	if (btn(2)) then radius += 1 end
	if (btn(3)) then radius -= 1 end
	theta = wrap(theta, 0, 360)
	radius = clamp(radius, 0, radius)
end
