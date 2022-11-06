pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- No Remorse for an Undead Horse
-- Shaun Adkins (Github: adkinsrs)

-- game loop
function _init()
	cls()
	scene=0
	score=0
	hiscore=0
	screenwidth=127
	screenheight=127
	timer=1800

	player={
		s=1
		,flip=false
		,dir="down"
		,x=screenwidth/2
		,y=screenheight/2
		,w=8
		,h=8
		,upd=playercontrol
		,draw=playerdraw
	}

	pole={
		active=false
		,t=0
		,x=player.x
		,y=player.y
		,w=0
		,h=0
		,upd=usepole
		,draw=poledraw
	}

	cat={
	}

	enemies={}

	sfx(2)
	palt(0,false)
	palt(5,true)
end

function _update()
	if scene==0 then
		titleupdate()
	elseif scene==1 then
		gameupdate()
	elseif scene==2 then
		helpupdate()
	end
end

function _draw()
	cls()
	if scene==0 then
		titledraw()
	elseif scene==1 then
		gamedraw()
	elseif scene==2 then
		helpdraw()
	end
end

-- update fxns
function titleupdate()
	if btnp(4) then
		scene=1
	elseif btnp(5) then
		scene=2
	end
end

function helpupdate()
	if btnp(5) then
		scene=0
	end
end

function gameupdate()
	--score+=1
	timer-=1
	--colon implies "self" passed as arg
	player:upd()
	if pole.active then
		pole:upd(player)
	end

	if timer%30==0 then
		spawn_enemy()
	end

	for e in all(enemies) do
		e.x+=e.dx
		e.y+=e.dy
		e.t+=1

		if e.alive then
			if e.t%8<3 then e.s=7 else e.s=6 end
		else
			e.s = 8
			e.dx = 0
			e.dy = 0
			e.w=0
			e.h=0
		end

		if e.t==128 then
			del(enemies,e)
			break
		end

		if collide(pole,e) and pole.active then
			sfx(1)
			-- leave blood pile
			e.alive=false
			e.t=64
			score +=1
		end
	end

	if timer==0 then
		hiscore=max(hiscore,score)
		scene=0
	end
end

-- draw fxns
function titledraw()
	local titletxt="no remorse"
	local titletxt2="for an undead horse!"
	local starttxt="press 🅾️/z to start"
	local helptxt="press ❎/x for instructions"
	local scoretxt="high score: "..hiscore

	rectfill(0,0,screenwidth, screenheight, 5)

	print(titletxt, hcenter(titletxt), screenheight/4, 11)
	print(titletxt2, hcenter(titletxt2), screenheight/4+8, 11)
	print(scoretxt, hcenter(scoretxt), 3*screenheight/8, 7)
	print(starttxt, hcenter(starttxt), (screenheight/4)+(screenheight/2),7)
	print(helptxt, hcenter(helptxt), (screenheight/4)+(screenheight/2)+8,7)
end

function helpdraw()
	local help="beat as many dead horses"
	local help2="as you can in a minute."
	local helpz="🅾️/z"
	local helpz2="touch it with a 10-foot pole"
	local helpx="❎/x"
	local helpx2="let the cat out of the bag"
	local helpdir="⬆️⬇️⬅️➡️ move player    "
	local returntext="press ❎/x to return"

	rectfill(0,0,screenwidth, screenheight, 5)

	print(help, hcenter(help), screenheight/8, 7)
	print(help2, hcenter(help2), (screenheight/8)+8, 7)
	print(helpz, hcenter(helpz), (3*screenheight/8)-8,7)
	print(helpz2, hcenter(helpz2), (3*screenheight/8),7)
	print(helpx, hcenter(helpx), screenheight/2,7)
	print(helpx2, hcenter(helpx2), (screenheight/2)+8,7)
	print(helpdir, hcenter(helpdir), (3*screenheight/4)-8,7)
	print(returntext, hcenter(returntext), (7*screenheight/8),9)
end

function gamedraw()
	rectfill(0,0,screenwidth, screenheight, 5)
	print("score " .. score, 5, 2, 7)
	print("timer ".. ceil(timer/30), 90, 2, 7)

	player:draw()
	pole:draw()

	for e in all(enemies) do
		spr(e.s
			,e.x
			,e.y
			,1
			,1
			,e.dx>0 and true
		)
	end
end

--util_fxns
function spawn_enemy()
	local right=true
	local dx = -1
	local dy = -1
	if rnd(1)<0.5 then dx=1 end
	if rnd(1)<0.5 then dy=1 end
	if rnd(1)<0.5 then right=false end
	add(enemies, {
		s=6
		,alive=true
		,x=(right and (dx>0 and 0 or 119) or flr(rnd(120)))
		,y=(right and flr(rnd(120)) or (dy>0 and 0 or 119))
		,w=8
		,h=8
		,dx=(right and dx or 0)
		,dy=(right and 0 or dy)
		,t=0
	})
end

function playercontrol(self)
	if btn(0) then moveleft(self)
	elseif btn(1) then moveright(self)
	elseif btn(2) then moveup(self)
	elseif btn(3) then movedown(self) end

	if btn(4) then pole.active=true end
	if btn(5) then usecat(self) end

	-- check if the player is still onscreen
	self.x=mid(0, self.x, screenwidth - self.w)
	self.y=mid(0, self.y, screenheight - self.h)
end

function playerdraw(self)
	spr(self.s,self.x,self.y,1,1,self.flip)
end

function moveleft(self)
	self.x-=1
	self.flip=true
	self.dir="left"
	if self.x%8<3 then self.s=3 else self.s=4 end
end

function moveright(self)
	self.x+=1
	self.flip=false
	self.dir="right"
	if self.x%8<3 then self.s=3 else self.s=4 end
end

function moveup(self)
	self.y-=1
	self.s=2
	self.flip=false
	self.dir="up"
	if self.y%8<3 then self.flip=true end
end

function movedown(self)
	self.y+=1
	self.s=1
	self.flip=false
	self.dir="down"
	if self.y%8<3 then self.s=5 end
end

function usepole(self,pl)
	if pl.dir=="left" or pl.dir=="right" then
		self.w = 30
		self.h = 1
		self.y = pl.y+5
		if pl.dir=="left" then
			self.x = pl.x - self.w
		else
			self.x = pl.x + 8
		end
	else
		self.w = 1
		self.h=30
		self.x = pl.x+4
		if pl.dir=="up" then
			self.y = pl.y - self.h
		else
			self.y = pl.y + 8
		end
	end

	if self.t==0 then sfx(0) end

	self.t+=1
	if self.t==15 then
		self.t=0
		self.active=false
		self.x=0
		self.y=0
		self.w=0
		self.h=0
	end

end

function poledraw(self)
	rectfill(self.x, self.y, self.x+self.w, self.y+self.h, 2)
end

function usecat(self)

end

function catdraw(self)
end

function hcenter(s)
	-- string length times the
	-- pixels in a char's width
	-- cut in half and rounded down
	return (screenwidth / 2)-flr((#s*4)/2)
end

function vcenter(s)
	-- string char's height
	-- cut in half and rounded down
	return (screenheight /2)-flr(5/2)
end

function collide(a,b)
	return b.x < a.x + a.w and a.x < b.x + b.w
        and b.y < a.y + a.h and a.y < b.y + b.h
end

__gfx__
00000000554444555544445555444455554444555544445553055555530555555555555500000000000000000000000000000000000000000000000000000000
0000000054f444455444444554444f5554444f5554f4444538305555383055555555555500000000000000000000000000000000000000000000000000000000
00700700540f0f4554444445544f0f55544f0f55540f0f4533330555333305555555555500000000000000000000000000000000000000000000000000000000
0007700055fffe55554444555544ff555544ff5555fffe5555333335553333355555555500000000000000000000000000000000000000000000000000000000
000770005eeeeee55eeeeee55eeeee55feeeeeef5eeeeee555333350553333505338535500000000000000000000000000000000000000000000000000000000
007007005feeee5f5f5eee5f5f5eee55555eee55f5eeeef555333350553333508383838300000000000000000000000000000000000000000000000000000000
0000000055ee5e55555e5e55555ff55555f55f5555e5ee5555355355535555358833383800000000000000000000000000000000000000000000000000000000
000000005577555555575555555ee5555e5555e55555775555055055055555055383855800000000000000000000000000000000000000000000000000000000
__sfx__
000100000000028450234501e4501a45015450124500e450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000000033150361503215036150331503415038150301502b15027150211501c150131500d1500400001000000000000000000000000000000000000000000000000000000000000000000000000000000
14140000145501455018550185501c5501c5501e5501e550235502355023550235502755027550275501800000000000000000000000000000000000000000000000000000000000000000000000000000000000
