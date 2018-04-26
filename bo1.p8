pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
bx=62 by=60
vx=1  vy=1   vspd=3
px=52 py=120
m=0 p=30 l=3

g={1,1,0,1,1,0,1,1,
   1,1,0,1,1,0,1,1,
   1,1,0,1,1,0,1,1,
   1,1,0,1,1,0,1,1}

function enter_ready()
 m=0 p=30
 if (l==0) l=3
 b={}
 for i in all(g) do
  add(b,i)
 end
end

function update_ready()
 if (p>0) p-=1
 if (p==0) enter_play()
end

function enter_play()
 m=1 p=0
end

function update_play()
 if (p>0) p-=1
 if (btn(0)) px=px-5
 if (btn(1)) px=px+5
 if (px<0) px=0
 if (px>104) px=104
 for i=1,vspd do
  bx=bx+vx
  by=by+vy
  if (bx>124) bx=124 vx=-vx
  if (bx<0) bx=0 vx=-vx 
  if (by>124) by=124 vy=-vy p=3
  if (by<0) by=0 vy=-vy
  if bx+4>px and bx<px+24 and by>py-4 then
   vy=-vy
   by=py-4
  end
  for y=0,3 do
   for x=0,7 do
    if b[1+y*8+x] == 1 then
     tx=x*16
     ty=16+y*8
     yd=min(by+4,ty+8)-max(by,ty)
     xd=min(bx+4,tx+16)-max(bx,tx)
     if xd>0 and yd>0 then
      bx=bx-vx
      by=by-vy
      if (xd>=yd) vy=-vy
      if (yd>=xd) vx=-vx
      b[1+y*8+x]=0
     end
    end
   end
  end
 end
 if (p==3) l-=1
 if (l==0) enter_ready()
end

function _update()
 if (m==0) then
  update_ready()
 end
 if (m==1) then
  update_play()
 end
end

function _draw()
 cls(p)
 spr(1,px,py)
 spr(1,px+8,py)
 spr(1,px+16,py)
 for y=0,3 do
  for x=0,7 do
   if b[1+y*8+x] == 1 then
    spr(3,x*16,16+y*8,1,1,false,false)
    spr(3,x*16+8,16+y*8,1,1,true,false)
   end
  end
 end
 spr(2,bx,by)
 for i=1,l do
  spr(0,i*8-8,0)
 end
end

enter_ready()

__gfx__
00000000ddddddd50440000004444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d6666667499a000048888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700d6666667499a000048888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000577777770aa0000048888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000048888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000048888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000048888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000002222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000000000160501b0501f0502105023050240502105018050170501d050200502305027050280502d0502e050330503605000000000000000000000000000000000000000000000000000000000000000000
