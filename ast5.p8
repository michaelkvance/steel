pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- let's actually implement impulse and draw a triangle

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

function vec2d_init(x, y)
	local v = { x = x, y = y }
	return v
end

function vec2d_add(a, b)
	local x = a.x + b.x
	local y = a.y + b.y
	local v = { x = x, y = y }
	return v
end

function vec2d_mul(a, b)
	local x = a.x * b.x
	local y = a.y * b.y
	local v = { x = x, y = y }
	return v
end

function vec2d_scale(v, s)
	local x = v.x * s
	local y = v.y * s
	local vp = { x = x, y = y }
	return vp
end

function vec2d_wrap(v, nv, mv)
	local x = wrap(v.x, nv.x, mv.x)
	local y = wrap(v.y, nv.y, mv.y)
	local vp = vec2d_init(x, y)
	return vp
end

function vec2d_tostring(v)
	local s = v.x .. "," .. v.y
	return s
end

function vec2d_rotate(v, theta)
	local t = theta/360.0
	local st = sin(t)
	local ct = cos(t)
	local vx = v.x
	local vy = v.y
	local xp = (vx * ct) - (vy * st)
	local yp = (vx * st) + (vy * ct)
	return vec2d_init(xp, yp)
end

function ship_init()
	local s = {
			size = vec2d_init(7, 7),
			origin = vec2d_init(64, 64),
			angles = { theta = 0, normal = vec2d_init(1, 0) },
			velocity = vec2d_init(0, 0)
		}
	return s
end

function ship_thrust(ship, impulse)
	local normal = ship.angles.normal
	local deltav = vec2d_scale(normal, impulse)
	local velocity = vec2d_add(ship.velocity, deltav)
	ship.velocity = velocity
	-- exciting bug here!
	-- local translation = vec2d_mul(normal, velocity)
	-- ship.origin = vec2d_add(ship.origin, translation)
	local origin = vec2d_add(ship.origin, velocity)
	origin = vec2d_wrap(origin, vec2d_init(0,0), vec2d_init(128,128))
	ship.origin = origin
end

function ship_turn(ship, theta)
	ship.angles.theta = wrap(ship.angles.theta + theta, 0, 360)
	local base = vec2d_init(1, 0)
	ship.angles.normal = vec2d_rotate(base, ship.angles.theta)
end

function ship_draw(ship)
	local normal = ship.angles.normal
	local scaled = vec2d_mul(normal, ship.size)
	local origin = ship.origin
	local target = vec2d_add(origin, scaled)
	local tip = vec2d_add(origin, vec2d_scale(scaled, 0.5))
	local sharpness = 140
	local left = vec2d_add(origin, vec2d_scale(vec2d_rotate(scaled, sharpness), 0.5))
	local right = vec2d_add(origin, vec2d_scale(vec2d_rotate(scaled, -sharpness), 0.5))
	local color = 7
	line(tip.x, tip.y, left.x, left.y, color)
	line(tip.x, tip.y, right.x, right.y, color)
	line(left.x, left.y, origin.x, origin.y, color)
	line(right.x, right.y, origin.x, origin.y, color)
end

ship = ship_init()

function _draw()
	cls()
	ship_draw(ship)
end

function _update()
	local impulse = 0
	local spin = 0
	if (btn(0)) then spin += 1 end
	if (btn(1)) then spin -= 1 end
	if (btn(2)) then impulse += 1 end
	if (btn(3)) then impulse -= 1 end
	ship_turn(ship, spin * 3.333)
	ship_thrust(ship, impulse * 0.01)
end
