pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- demonstrates a simple line drawing + angles, tty output
-- has a simple bug to discover

x=64
y=64
theta=0
radius=20

function _draw()
	cls()
	print("theta = " .. theta)
	print("radius = " .. radius)
	t = theta/360.0
	st = sin(t)
	ct = cos(t)
	-- matrix layout
	-- r00 = ct
	-- r01 = -st
	-- r10 = st
	-- r11 = ct
	x0 = radius
	y0 = 0
	xp = x0 * ct - y0 * st
	yp = x0 * st + y0 * ct
	line(x, y, x + xp, y + yp, 7)
end

function clamp(x, nx, mx)
	if (x < nx) return nx
	if (x > mx) return mx
	return x
end

function _update()
	if (btn(0)) then theta += 1 end
	if (btn(1)) then theta -= 1 end
	if (btn(2)) then radius += 1 end
	if (btn(3)) then radius -= 1 end
	theta = clamp(theta, 0, 360)
	radius = clamp(radius, 0, radius)
end
