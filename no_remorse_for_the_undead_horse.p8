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
	screenwidth = 127
	screenheight = 127
	timer=1800

	player={
		s=1
		,flips=false
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
		,box={
			x0=player.x
			,y0=player.y
			,x1=player.x
			,y1=player.y
		}
		,upd=usepole
		,draw=poledraw
	}

	cat={
	}

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
end

-- draw fxns
function titledraw()
	local titletxt="no remorse"
	local titletxt2="for an undead horse!"
	local starttxt="press 🅾️/z to start"
	local helptxt="press ❎/x for instructions"

	rectfill(0,0,screenwidth, screenheight, 5)

	print(titletxt, hcenter(titletxt), screenheight/4, 11)
	print(titletxt2, hcenter(titletxt2), screenheight/4+8, 11)
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
end

--util_fxns
function playercontrol(self)
	if btn(0) then moveleft(self)
	elseif btn(1) then moveright(self)
	elseif btn(2) then moveup(self)
	elseif btn(3) then movedown(self) end

	if btn(4) then pole.active=true end
	if btn(5) then usecat(self) end

	-- check if the player is still onscreen
	self.x = mid(0, self.x, screenwidth - self.w)
	self.y = mid(0, self.y, screenheight - self.h)

end

function playerdraw(self)
	spr(self.s,self.x,self.y,1,1,self.flip_s)
end

function moveleft(self)
	self.x-=1
	self.flip_s=true
	if self.x%8<4 then self.s=3 else self.s=4 end
end

function moveright(self)
	self.x+=1
	self.flip_s=false
	if self.x%8<4 then self.s=3 else self.s=4 end
end

function moveup(self)
	self.y-=1
	self.s=2
	self.flip_s=false
	if self.y%8<4 then self.flip_s=true end
end

function movedown(self)
	self.y+=1
	self.s=1
	self.flip_s=false
	if self.y%8<4 then self.s=5 end
end

function usepole(self,pl)
	local flip=false
	local x=true
	--direction of char
	if (pl.s==1 or pl.s==5) then
		x=false
	elseif (pl.s==2) then
		flip=true
		x=false
	elseif (pl.flip_s) then
		flip=true
	end

	if x then
		if flip then
			self.box.x1 = pl.x
			self.box.x0 = self.box.x1 - 30
		else
			self.box.x0 = pl.x + 8
			self.box.x1 = self.box.x0 + 30
		end
		self.box.y0 = pl.y+5
		self.box.y1 = self.box.y0+1
	else
		self.box.x0 = pl.x+4
		self.box.x1 = self.box.x0+1
		if flip then
			self.box.y1 = pl.y
			self.box.y0 = self.box.y1 - 30
		else
			self.box.y0 = pl.y + 8
			self.box.y1 = self.box.y0 + 30
		end
	end

	if self.t==0 then sfx(0) end

	self.t+=1
	if self.t==15 then
		self.t=0
		self.active=false
		self.box={
			x0=0
			,x1=0
			,y0=0
			,y1=0
		}
	end

end

function poledraw(self)
	rectfill(self.box.x0, self.box.y0, self.box.x1, self.box.y1, 2)
end

function usecat(self)

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
00000000554444555544445555444455554444555544445500000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000054f444455444444554444f5554444f5554f4444500000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700540f0f4554444445544f0f55544f0f55540f0f4500000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700055fffe55554444555544ff555544ff5555fffe5500000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005eeeeee55eeeeee55eeeee55feeeeeef5eeeeee500000000000000000000000000000000000000000000000000000000000000000000000000000000
007007005feeee5f5f5eee5f5f5eee55555eee55f5eeeef500000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055ee5e55555e5e55555ff55555f55f5555e5ee5500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005577555555575555555ee5555e5555e55555775500000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000028450234501e4501a45015450124500e450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
