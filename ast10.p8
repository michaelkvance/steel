pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- let's add a score screen! and fix our color issues!

console = {}

function console_post(message)
	local c = {
		age = 0,
		text = message
	}
	add(console, c)
end

function console_tick()
	for post in all(console) do
	    if post.age > 30 then
	    	del(console, post)
	    else
	    	post.age = post.age + 1
	    end
	end
end

function console_draw()
	color( 6 )
	cursor( 0, 0 )
	for k,p in pairs(console) do
		print(p.text)
	end
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

function vec2d_init(x, y)
	local v = {x = x, y = y}
	return v
end

function vec2d_add(a, b)
	local x = a.x + b.x
	local y = a.y + b.y
	local v = {x = x, y = y}
	return v
end

function vec2d_sub(a, b)
	local x = a.x - b.x
	local y = a.y - b.y
	local v = {x = x, y = y}
	return v
end

function vec2d_mul(a, b)
	local x = a.x * b.x
	local y = a.y * b.y
	local v = {x = x, y = y}
	return v
end

function vec2d_scale(v, s)
	local x = v.x * s
	local y = v.y * s
	local vp = {x = x, y = y}
	return vp
end

function vec2d_wrap(v, nv, mv)
	local x = wrap(v.x, nv.x, mv.x)
	local y = wrap(v.y, nv.y, mv.y)
	local vp = {x = x, y = y}
	return vp
end

function vec2d_dot(v)
	local d = v.x * v.x + v.y * v.y
	return d
end

function vec2d_length(v)
	local l = sqrt(vec2d_dot(v))
	return l
end

local function vec2d_point_in_circle(p, o, r)
	local delta = vec2d_sub(p, o)
	local distance = vec2d_dot(delta)
	local check = r * r
	return distance < check
end

local function vec2d_circles_intersect(a, ar, b, br)
	local delta = vec2d_sub(a, b)
	local distance = vec2d_dot(delta)
	local check = (ar + br) * (ar + br)
	return distance < check
end

function vec2d_tostring(v)
	local s = v.x .. "," .. v.y
	return s
end

function vec2d_rotate(v, theta)
	local t = theta / 360.0
	local st = sin(t)
	local ct = cos(t)
	local vx = v.x
	local vy = v.y
	local xp = (vx * ct) - (vy * st)
	local yp = (vx * st) + (vy * ct)
	local vp = {x = xp, y = yp}
	return vp
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
	if bullet.origin.x < 0 or bullet.origin.x > 128 or bullet.origin.y < 0 or bullet.origin.y > 128 then
		bullet.age = 0
		bullet.alive = false
		return
	end
	bullet.origin = vec2d_add(bullet.origin, bullet.velocity)
	bullet.age = bullet.age + 1
end

local function bullet_fire(bullet, origin, direction, velocity)
	bullet.alive = true
	bullet.origin = origin
	-- amusing bugs when you shoot at high speeds!
	local speed = 3
	bullet.velocity = vec2d_scale(direction, speed)
	bullet.age = 0
	sfx(0)
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
	local velocity = ship.velocity
	bullet_fire(bullet, tip, direction, velocity)
	ship.heat = 15
end

local function ship_tick(ship, buttons)
	local impulse = 0
	local spin = 0
	local fire = false
	local turbo = false

	if (button_down(buttons[1])) then spin += 1 end
	if (button_down(buttons[2])) then spin -= 1 end
	if (button_down(buttons[3])) then impulse += 1 end
	if (button_down(buttons[4])) then impulse -= 1 end
	if (button_down(buttons[5])) then fire = true end
	if (button_down(buttons[6])) then turbo = true end

	local boost = 1
	if turbo then boost = 3 end

	ship_turn(ship, spin * 3.333)
	ship_thrust(ship, impulse * 0.01 * boost)

	if fire then ship_fire(ship) end

	for index = 1,4 do
		b = ship.bullets[index]
		bullet_tick(b)
	end

	if ship.heat > 0 then ship.heat -= 1 end
end

local function bullet_draw(bullet)
	if not bullet.alive then return end
	local origin = bullet.origin
	local color = 15
	if bullet.age > 24 then
		color = 13
	elseif bullet.age > 12 then
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

local function stars_init(speed, color)
	local s = {
		points = {},
		velocity = vec2d_init(speed, 0),
		color = color
	}
	for index = 1,4 do
		s.points[index] = vec2d_init(rnd(128),rnd(128))
	end
	return s
end

local function starfield_init()
	local s = {
		planes = {}
	}
	local colors = {5, 6, 7}
	for index = 1,3 do
		s.planes[index] = stars_init(index, colors[index])
	end
	return s
end

local function starfield_tick(field)
	for k,p in pairs(field.planes) do
		for sk, sp in pairs(p.points) do
			p.points[sk] = vec2d_add(sp, p.velocity)
			if sp.x > 128 then
				p.points[sk] = vec2d_init(0, rnd(128))
			end
		end
	end
end

local function starfield_draw(field)
	for k,p in pairs(field.planes) do
		for sk, sp in pairs(p.points) do
			pset(sp.x, sp.y, p.color)
		end
	end
end

local function asteroid_init()
	local a = {
		alive = false,
		origin = vec2d_init(0,0),
		angular = 0,
		velocity = vec2d_init(0,0),
		radius = 1,
		color = 4
		-- a set of points for the line drawing?
	}
	return a
end

local function asteroid_tick(roid)
	if not roid.alive then return end
	local origin = roid.origin
	local velocity = roid.velocity
	local deltav = vec2d_add(origin, velocity)
	roid.origin = deltav -- vec2d_wrap(deltav, vec2d_init(0,0), vec2d_init(128,128))
end

local function asteroid_draw(roid)
	if not roid.alive then return end
	local origin = roid.origin
	local radius = roid.radius
	local color = roid.color
	--- xxx 
	circ(origin.x, origin.y, radius, color)
end

local function asteroids_init()
	local f = {
		ready = 0,
		quadrant = 0,
		roids = {},
	}
	for index = 1,4 do
		f.roids[index] = asteroid_init()
	end
	return f
end

local function asteroid_next(field)
	for k,a in pairs(field.roids) do
		if not a.alive then
			return a
		end
	end
	return nil
end

local function asteroids_spawn(field)
	local quadrant = field.quadrant
	field.quadrant = wrap(quadrant + 1, 0, 4)
	local theta = quadrant * 90 + rnd(90)
	local direction = vec2d_rotate(vec2d_init(1,0), theta)
	local perturb = vec2d_rotate(direction, rnd(30) - 15)
	local origin = vec2d_add(vec2d_init(64,64), vec2d_scale(direction, 90.5))
	local velocity = vec2d_scale(perturb, -0.5)
	local next = asteroid_next(field)
	if next != nil then
		next.alive = true
		next.origin = origin
		next.velocity = velocity
		next.radius = rnd(7) + 3
	end
end

local function asteroids_tick(field)
	if field.ready == 15 then
		asteroids_spawn(field)
		field.ready = 0
	else
		field.ready = field.ready + 1
	end
	for k,a in pairs(field.roids) do
		asteroid_tick(a)
	end
end

local function asteroids_draw(field)
	for k,a in pairs(field.roids) do
		asteroid_draw(a)
	end
end

local function world_init()
	local w = {
		starfield = starfield_init(),
		asteroids = asteroids_init(),
		ship = ship_init(),
		score = 0,
	}
	return w
end

local function world_resolve(world)
	local ship = world.ship
	local bullets = ship.bullets
	local field = world.asteroids
	for f,a in pairs(field.roids) do
		if a.alive then
			for k,b in pairs(bullets) do
				if b.alive then
					if vec2d_point_in_circle(b.origin, a.origin, a.radius) then
						field.ready = 0
						b.alive = false
						a.alive = false
						world.score += 1
					end
				end
			end
			if vec2d_circles_intersect(ship.origin, ship.size.x * 0.5, a.origin, a.radius) then
				world.score = 0
			end
		end
	end
end

local function world_tick(world, buttons)
	local stars = world.starfield
	local ship = world.ship
	local field = world.asteroids
	starfield_tick(stars)
	asteroids_tick(field)
	ship_tick(ship, buttons)
	world_resolve(world)
end

local function score_draw(world)
	local score = world.score
	color( 7 )
	cursor( 90, 110 )
	print("Score: " .. score)
end

local function world_draw(world)
	local stars = world.starfield
	local ship = world.ship
	local field = world.asteroids
	starfield_draw(stars)
	asteroids_draw(field)
	ship_draw(ship)
	score_draw(world)
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
	world_draw(world)
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
console_post("startup")

function _draw()
	if not cleared then
		-- cleared = true
		cls()
	end	
	state_draw(state)
	console_draw()
end

function _update()
	state_tick(state)
	console_tick()
end
__sfx__
000100000000000000000000130001300013000130001300013000131002320063200f330243403135024350193500a3400533001320033100230001300013000130001300013000000000000000000000000000
0010000000000000000000000000000000000000000020000200002000020000200001000060000d010140102f050270500a05008030070200500005000050000000000000000000000000000000000000000000
