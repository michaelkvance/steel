pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- let's fix a bug in the shooty bits and add a lovely starfield

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
	local t = theta / 360.0
	local st = sin(t)
	local ct = cos(t)
	local r00 = ct
	local r01 = -st
	local r10 = st
	local r11 = ct
	local vx = v.x
	local vy = v.y
	local xp = (vx * ct) - (vy * st)
	local yp = (vx * st) + (vy * ct)
	return vec2d_init(xp, yp)
end

local function button_init()
	local b = {
		previous = false,
		current = false,
		pressed = 0,
		released = 0
	}
	return b
end

local function button_down(button)
	return button.current
end

local function button_up(button)
	return not button.current
end

local function button_pressed(button)
	return button.current and not button.previous
end

local function button_released(button)
	return not button.current and button.previous
end

local function button_held(button)
	return button.current and button.previous
end

local function bullet_init()
	local b = {
		alive = false,
		origin = vec2d_init(0, 0),
		velocity = vec2d_init(0, 0),
		age = 0
	}
	return b
end

local function bullet_tick(bullet)
	if not bullet.alive then return end
	if bullet.age > 300 then
		bullet.age = 0
		bullet.alive = false
		return
	end
	bullet.origin = vec2d_add(bullet.origin, bullet.velocity)
	bullet.age = bullet.age + 1
end

local function bullet_fire(bullet, origin, direction)
	bullet.alive = true
	bullet.origin = origin
	local speed = 3
	bullet.velocity = vec2d_scale(direction, speed)
	bullet.age = 0
end

local function ship_init()
	local s = {
		size = vec2d_init(7, 7),
		origin = vec2d_init(64, 64),
		angles = {
			theta = 0,
			normal = vec2d_init(1, 0)
		},
		velocity = vec2d_init(0, 0),
		bullets = {},
		heat = 0
	}
	for index = 1, 4 do
		s.bullets[index] = bullet_init()
	end
	return s
end

local function ship_thrust(ship, impulse)
	local normal = ship.angles.normal
	local deltav = vec2d_scale(normal, impulse)
	local velocity = vec2d_add(ship.velocity, deltav)
	ship.velocity = velocity
	local origin = vec2d_add(ship.origin, velocity)
	origin = vec2d_wrap(origin, vec2d_init(0,0), vec2d_init(128,128))
	ship.origin = origin
end

local function ship_turn(ship, theta)
	ship.angles.theta = wrap(ship.angles.theta + theta, 0, 360)
	local base = vec2d_init(1, 0)
	ship.angles.normal = vec2d_rotate(base, ship.angles.theta)
end

local function ship_next_bullet(ship)
	-- XXX highest number?
	local oldest = 0
	local which = 1
	for i, b in pairs(ship.bullets) do
		if b.alive == false then
			return b
		end
		if b.age >= oldest then
			which = i
			oldest = b.age
		end
	end
	return ship.bullets[which]
end

local function ship_fire(ship)
	if ship.heat != 0 then return end

	local direction = ship.angles.normal
	local scaled = vec2d_mul(direction, ship.size)
	local origin = ship.origin
	local tip = vec2d_add(origin, vec2d_scale(scaled, 0.5))
	local bullet = ship_next_bullet(ship)
	bullet_fire(bullet, tip, direction)
	ship.heat = 15
end

local function ship_tick(ship, buttons)
	local impulse = 0
	local spin = 0
	local fire = false

	if (button_down(buttons[1])) then spin += 1 end
	if (button_down(buttons[2])) then spin -= 1 end
	if (button_down(buttons[3])) then impulse += 1 end
	if (button_down(buttons[4])) then impulse -= 1 end
	if (button_down(buttons[5])) then fire = true end

	ship_turn(ship, spin * 3.333)
	ship_thrust(ship, impulse * 0.01)

	if fire then ship_fire(ship) end

	for index = 1,4 do
		b = ship.bullets[index]
		bullet_tick(b)
	end

	if ship.heat > 0 then ship.heat -= 1 end
end

local function bullet_draw(bullet)
	local origin = bullet.origin
	local color = 15
	if bullet.age > 30 then
		color = 13
	elseif bullet.age > 15 then
		color = 14
	end
	pset(origin.x, origin.y, color)
end

local function ship_draw(ship)
	local normal = ship.angles.normal
	local scaled = vec2d_mul(normal, ship.size)
	local origin = ship.origin
	local tip = vec2d_add(origin, vec2d_scale(scaled, 0.5))
	local sharpness = 140
	local left = vec2d_add(origin, vec2d_scale(vec2d_rotate(scaled, sharpness), 0.5))
	local right = vec2d_add(origin, vec2d_scale(vec2d_rotate(scaled, -sharpness), 0.5))
	local color = 12
	line(tip.x, tip.y, left.x, left.y, color)
	line(tip.x, tip.y, right.x, right.y, color)
	line(left.x, left.y, origin.x, origin.y, color)
	line(right.x, right.y, origin.x, origin.y, color)

	for k,b in pairs(ship.bullets) do
		bullet_draw(b)
	end
end

local function stars_init(speed)
	local s = {
		points = {},
		velocity = vec2d_init(speed, 0)
	}
	for index = 1,4 do
		s.points[index] = vec2d_init(0,0)
	end
	return s
end

local function starfield_init()
	local s = {
		planes = {}
	}
	return s
end

local function world_init()
	local w = {
		ship = ship_init(),
		starfield = starfield_init()
	}
	return w
end

local function world_tick(world, buttons)
	local ship = world.ship
	ship_tick(ship, buttons)
end

local function state_init()
	local s = {
		tick = 0,
		buttons = {},
		world = world_init()
	}
	for index = 1,6 do
		s.buttons[index] = button_init()
	end
	return s
end

local function state_draw(state)
	local world = state.world
	local ship = world.ship
	ship_draw(ship)
end

-- for below, pico-8 button index is 0-based
local function state_button_down(state, index)
	local button = state.buttons[index + 1]
	return button_down(button)
end

local function state_button_pressed(state, index)
	local button = state.buttons[index + 1]
	return button_pressed(button)
end

local function state_button_released(state, index)
	local button = state.buttons[index + 1]
	return button_released(button)
end

local function state_button_held(state, index)
	local button = state.buttons[index + 1]
	return button_held(button)
end

local function state_tick(state)
	state.tick = state.tick + 1

	-- note we can "optimize" this by calling btn w/o args, which returns
	-- a bitmask of all button states
	for index = 1,6 do
		local b = state.buttons[index]
		b.previous = b.current
		-- pico-8 button index is 0-based again
		b.current = btn(index - 1)
		if button_pressed(b) then
			b.pressed = state.tick
		elseif button_released(b) then
			b.released = state.tick
		end
	end

	local world = state.world
	world_tick(world, state.buttons)
end

state = state_init()
cleared = false

function _draw()
	if not cleared then
		-- cleared = true
		cls()
	end	
	state_draw(state)
end

function _update()
	state_tick(state)
end
