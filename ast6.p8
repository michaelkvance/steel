pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- let's continue to build state in an exciting way!

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

local function ship_init()
	local s = {
			size = vec2d_init(7, 7),
			origin = vec2d_init(64, 64),
			angles = {
				theta = 0,
				normal = vec2d_init(1, 0)
			},
			velocity = vec2d_init(0, 0),
			bullets = {}
		}
	return s
end

local function ship_thrust(ship, impulse)
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

local function ship_turn(ship, theta)
	ship.angles.theta = wrap(ship.angles.theta + theta, 0, 360)
	local base = vec2d_init(1, 0)
	ship.angles.normal = vec2d_rotate(base, ship.angles.theta)
end

local function ship_fire(ship)
	local normal = ship.angles.normal

end

local function ship_draw(ship)
	local normal = ship.angles.normal
	local scaled = vec2d_mul(normal, ship.size)
	local origin = ship.origin
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

local function button_init()
	local b = {
		previous = false,
		current = false,
		pressed = 0,
		released = 0
	}
	return b
end

local function state_init()
	local s = {
		tick = 0,
		buttons = {},
		world = {
			ship = ship_init()
		}
	}
	for index = 1,4 do
		s.buttons[index] = button_init()
	end
	return s
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

local function state_tick(state)
	state.tick = state.tick + 1
	-- not we can optimize ths by using btn naked, which returns
	-- a bitmask of all button states
	for index = 1,4 do
		-- we havent really discussed how every variable is a value
		-- but some types are reference-values, like tables
		local b = state.buttons[index]
		b.previous = b.current
		b.current = btn(index - 1)
		if button_pressed(b) then
			b.pressed = state.tick
		elseif button_released(b) then
			b.released = state.tick
		end
	end
end

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

state = state_init()

function _draw()
	local world = state.world
	local ship = world.ship
	cls()
	ship_draw(ship)
end

function _update()
	local world = state.world
	local ship = world.ship
	state_tick(state)
	local impulse = 0
	local spin = 0
	if (state_button_down(state, 0)) then spin +=1 end
	if (state_button_down(state, 1)) then spin -= 1 end
	if (state_button_down(state, 2)) then impulse += 1 end
	if (state_button_down(state, 3)) then impulse -= 1 end
	ship_turn(ship, spin * 3.333)
	ship_thrust(ship, impulse * 0.03)
end
