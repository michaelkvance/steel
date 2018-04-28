pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- demonstrates making a composite variable
-- fixes bug

function make_vec2d(x0, y0)
	v = {x=x0, y=y0}
	return v
end

origin=make_vec2d(64,64)
theta=0
radius=20

function xform(v,theta)
	t = theta/360.0
	st = sin(t)
	ct = cos(t)
	vx = v.x
	vy = v.y
	xp = vx * ct - vy * st
	yp = vx * st + vy * ct
	vp = make_vec2d(xp,yp)
	return vp
end

function _draw()
	cls()
	print("theta = " .. theta)
	print("radius = " .. radius)
	l = make_vec2d(radius,0)
	lp = xform(l, theta)
	x = origin.x
	y = origin.y
	line(x, y, x + lp.x, y + lp.y, 7)
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
