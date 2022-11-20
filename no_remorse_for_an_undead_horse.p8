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
	enemy_m=1
	pts_m=1
	last=time()

	player={
		s=1
		,flip=false
		,dir="down"
		,x=screenwidth/2
		,y=screenheight/2
		,w=8
		,h=8
		,pts_up=false
		,pts_up_t=0
		,enemy_up=false
		,enemy_up_t=0
		,upd=playerupdate
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
		s=9
		,active=false
		,flipx=false
		,flipy=false
		,t=0
		,x=player.x
		,y=player.y
		,w=8
		,h=8
		,dx=0
		,dy=0
		,upd=usecat
		,draw=catdraw
	}
	bomb={
		active=false
		,t=0
		,r=1
		,x=cat.x
		,y=cat.y
		,w=8
		,h=8
		,upd=explode
		,draw=bombdraw
	}

	pwrups={}
	enemies={}

	sfx(2)
end

function _update()
	if scene==0 then
		titleupdate()
	elseif scene==1 then
		gameupdate()
	elseif scene==2 then
		helpupdate()
	elseif scene==3 then
		enemyhelpupdate()
	end
end

function _draw()
	if scene==0 then
		titledraw()
	elseif scene==1 then
		gamedraw()
	elseif scene==2 then
		helpdraw()
	elseif scene==3 then
		enemyhelpdraw()
	end
end

-- update fxns
function titleupdate()
	--prevent user from clicking through too fast
	if (time() - last) < 20 then
		return
	end
	if btnp(4) then
		scene=1
	elseif btnp(5) then
		scene=2
	end
end

function helpupdate()
	if btnp(4) then
		scene=0
	end
	if btnp(5) then
		scene=3
	end
end

function enemyhelpupdate()
	if btnp(4) then
		scene=0
	end
end

function gameupdate()
	timer-=1
	--colon implies "self" passed as arg
	player:upd()
	if cat.active then cat:upd(player) end
	if bomb.active then bomb:upd() end
	if pole.active then pole:upd(player) end

	if timer%90==0 then
		spawn_powerup()
	end

	if timer%(30/enemy_m)==0 then
		spawn_enemy(timer/30)
	end

	for p in all(pwrups) do
		p:upd()
	end

	for e in all(enemies) do
		e:upd()
	end

	if timer==0 then
		hiscore=max(hiscore,score)
		scene=0
		timer=1800
		last=time()
	end
end

-- draw fxns
function titledraw()
	cls(0)
	local titletxt="no remorse"
	local titletxt2="for an undead horse!"
	local starttxt="press z to start"
	local helptxt="press x for instructions"
	local scoretxt="high score: "..hiscore

	print(titletxt, hcenter(titletxt), screenheight/4, 11)
	print(titletxt2, hcenter(titletxt2), screenheight/4+8, 11)
	print(scoretxt, hcenter(scoretxt), 3*screenheight/8, 7)
	print(starttxt, hcenter(starttxt), (screenheight/4)+(screenheight/2),7)
	print(helptxt, hcenter(helptxt), (screenheight/4)+(screenheight/2)+8,7)
end

function helpdraw()
	cls(0)
	local help="beat as many (un)dead horses"
	local help2="as you can in a minute."
	local helpz="z"
	local helpz2="touch it with"
	local helpz3="a 10-foot pole"
	local helpx="x"
	local helpx2="let the cat"
	local helpx3="out of the bag"
	local helpdir="wasd"
	local helpdir2="move player"
	local helpscorem="points x2"
	local helpenemym="spawn x2"
	local returntext="z - back"
	local moretext="x - enemy info"

	print(help, hcenter(help), screenheight/16, 7)
	print(help2, hcenter(help2), (screenheight/16)+8, 7)
	print(helpz, 32, screenheight/4,7)
	print(helpz2, 64, screenheight/4,7)
	print(helpz3, 64, (screenheight/4)+8,7)
	print(helpx, 32, (7*screenheight/16),7)
	print(helpx2, 64, (7*screenheight/16),7)
	print(helpx3, 64, (7*screenheight/16)+8,7)
	print(helpdir, 32, (5*screenheight/8),7)
	print(helpdir2, 64, (5*screenheight/8),7)
	spr(32,8,(3*screenheight/4))
	print(helpscorem, 20, (3*screenheight/4),7)
	spr(33,64,(3*screenheight/4))
	print(helpenemym, 76, (3*screenheight/4),7)
	print(returntext, 5, screenheight-8,9)
	print(moretext, 70, screenheight-8,9)
end

function enemyhelpdraw()
	cls(0)
	local title="enemies"
	local enemy1="zombie horse"
	local enemy2="eligor"
	local enemy3="armored horse"
	local returntext="z - back"

	print(title, hcenter(title), screenheight/16, 7)
	spr(6,32, screenheight/4)
	print(enemy1, 64, screenheight/4,7)
	spr(12,32, screenheight/2, 2, 2)
	print(enemy2, 64, screenheight/2,7)
	spr(16,32, (3*screenheight/4))
	print(enemy3, 64, (3*screenheight/4),7)
	print(returntext, 5, screenheight-8,9)
end

function gamedraw()
	cls(3)
	map(0,1,0,8,16,15)

	rectfill(0,0,screenwidth,8,0)
	print("score " .. score, 5, 1, 7)
	print("timer ".. ceil(timer/30), 90, 1, 7)
	if player.pts_up then
		spr(32,64,0)
	end
	if player.enemy_up then
		spr(33,72,0)
	end

	player:draw()
	if pole.active then pole:draw() end
	if cat.active then cat:draw() end
	if bomb.active then bomb:draw() end

	for p in all(pwrups) do
		p:draw()
	end

	for e in all(enemies) do
		e:draw()
	end
end

--util_fxns
function spawn_powerup()
	local types = {"pts_up", "enemy_up"}
	local type=rnd(types)
	local sp=type=="pts_up" and 32 or 33
	add(pwrups, {
		t=0
		,type=type
		,sp=sp
		,x=flr(rnd(120))
		,y=flr(rnd(112))+8
		,w=8
		,h=8
		,upd=pwrupupdate
		,draw=pwrupdraw
	})
end

function pwrupupdate(self)
	if self.t==150 then
		del(pwrups,self)
		return
	end
	self.t+=1

	if collide(player,self) then
		if self.type=="pts_up" then
			player.pts_up = true
			pts_m = 2
			sfx(7)
		elseif self.type=="enemy_up" then
			player.enemy_up = true
			enemy_m = 2
			sfx(8)
		end
		del(pwrups,self)
	end
end

function pwrupdraw(self)
	spr(self.sp,self.x, self.y)
end

function spawn_enemy(timer)
	local lr=true
	local dx=-1
	local dy=-1
	if rnd(1)<0.5 then dx=1 end
	if rnd(1)<0.5 then dy=1 end
	if rnd(1)<0.5 then lr=false end

	local horsefunc = {addhorse} --horse
	if timer<51 then add(horsefunc, addeligor) end	--eligor
	if timer<41 then add(horsefunc, addarmor) end	--armor

	add(enemies, rnd(horsefunc)(dx, dy, lr))

end

function addhorse(dx, dy, lr)
	return {
		s=6
		,alive=true
		,x=(lr and (dx>0 and 0 or 119) or flr(rnd(120)))
		,y=(lr and flr(rnd(112)) or (dy>0 and 0 or 111))+8
		,w=8
		,h=8
		,dx=(lr and dx or 0)
		,dy=(lr and 0 or dy)
		,t=0
		,upd=horseupdate
		,draw=horsedraw
	}
end

function horseupdate(self)
	self.x+=self.dx
	self.y+=self.dy
	self.t+=1

	if self.alive then
		if self.t%8<3 then self.s=7 else self.s=6 end
	else
		self.s = 8
		self.dx = 0
		self.dy = 0
		self.w=0
		self.h=0
	end

	if self.t==128 then
		del(enemies,self)
		return
	end

	if self.alive
	and ((collide(pole,self) and pole.active)
	or (collide(cat,self) and cat.active)
	or (collide(bomb,self) and bomb.active)) then
		-- leave blood pile
		sfx(1)
		kill_enemy(self)
	end
end

function horsedraw(self)
	spr(self.s,self.x,self.y,1,1,(self.dx>0 and true))
end

function addeligor(dx, dy, lr)
	return {
		s=12
		,alive=true
		,x=(lr and (dx>0 and 0 or 119) or flr(rnd(120)))
		,y=(lr and flr(rnd(112)) or (dy>0 and 0 or 111))+8
		,w=16
		,h=16
		,dx=(lr and dx or 0)
		,dy=(lr and 0 or dy)
		,t=0
		,upd=eligorupdate
		,draw=eligordraw
	}
end

function eligorupdate(self)
	self.x+=self.dx
	self.y+=self.dy
	self.t+=1

	if self.alive then
		if self.t%8<3 then self.s=14 else self.s=12 end
	else
		self.s = 8
		self.dx = 0
		self.dy = 0
		self.w=0
		self.h=0
	end

	if self.t==128 then
		del(enemies,self)
		return
	end

	if self.alive
	and ((collide(pole,self) and pole.active)
	or (collide(cat,self) and cat.active)
	or (collide(bomb,self) and bomb.active)) then
		sfx(5)
		kill_enemy(self)
	end
end

function eligordraw(self)
	local w=1
	local h=1
	if self.alive then
		w=2
		h=2
	end
	spr(self.s,self.x,self.y,w,h,(self.dx>0 and true))
end

function addarmor(dx, dy, lr)
	return {
		s=16
		,alive=true
		,x=(lr and (dx>0 and 0 or 119) or flr(rnd(120)))
		,y=(lr and flr(rnd(112)) or (dy>0 and 0 or 111))+8
		,w=8
		,h=8
		,dx=(lr and dx or 0)
		,dy=(lr and 0 or dy)
		,t=0
		,upd=armorupdate
		,draw=horsedraw --same as horse
	}
end

function armorupdate(self)
	self.x+=self.dx
	self.y+=self.dy
	self.t+=1

	if self.alive then
		if self.t%8<3 then self.s=17 else self.s=16 end
	else
		self.s = 8
		self.dx = 0
		self.dy = 0
		self.w=0
		self.h=0
	end

	if self.t==128 then
		del(enemies,self)
		return
	end

	-- only damage with explosion. Interrupt attack
	if self.alive then
		if (collide(pole,self) and pole.active) then
			sfx(6)
			pole.active = false
		end
		if (collide(cat,self) and cat.active) then
			cat.active = false
			bomb.active = true
			sfx(1)
			kill_enemy(self)

		end
		if (collide(bomb,self) and bomb.active) then
			sfx(1)
			kill_enemy(self)
		end
	end
end

function kill_enemy(self)
	self.alive=false
	self.t=64
	score +=(1*pts_m)
end

function playerupdate(self)
	playercontrol(self)

	if self.pts_up then
		self.pts_up_t +=1
		if self.pts_up_t > 150 then
			self.pts_up = false
			self.pts_up_t = 0
			pts_m = 1
		end
	end

	if self.enemy_up then
		self.enemy_up_t +=1
		if self.enemy_up_t > 150 then
			self.enemy_up = false
			self.enemy_up_t = 0
			enemy_m = 1
		end
	end

end

function playercontrol(self)
	if btn(0) then moveleft(self)
	elseif btn(1) then moveright(self)
	elseif btn(2) then moveup(self)
	elseif btn(3) then movedown(self) end

	if btn(4) then pole.active=true end
	if btn(5) then cat.active=true end

	-- check if the player is still onscreen
	self.x=mid(0, self.x, screenwidth - self.w)
	self.y=mid(8, self.y, screenheight - self.h)
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

	-- Stop using pole
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
	rectfill(self.x, self.y, self.x+self.w, self.y+self.h, 4)
end

function usecat(self,pl)
	self.flipx=false
	self.flipy=false

	-- explode and despawn
	if self.t>30 then
		self.dx=0
		self.dy=0
		self.t=0
		self.active=false
		bomb.x=self.x
		bomb.y=self.y
		bomb.active=true
		sfx(4)
		return
	end

	-- catbomb instead of bag
	if self.t>8 then
		self.t+=1
		self.s=9
		self.x+=self.dx
		self.y+=self.dy
		return
	end

	--init sprite position
	self.dx=0
	self.dy=0
	local bag_s=10
	if pl.dir=="left" or pl.dir=="right" then
		self.y = pl.y+1
		self.dx=1.5
		if pl.dir=="left" then
			self.x = pl.x - self.w
			self.flipx=true
			self.dx*=-1
		else
			self.x = pl.x + self.w
		end
	else
		bag_s=11
		self.x = pl.x+1
		self.dy=1.5
		if pl.dir=="up" then
			self.y = pl.y - self.h
			self.flipy=true
			self.dy*=-1
		else
			self.y = pl.y + self.h
		end
	end

	if self.t==0 then sfx(3) end
	self.t+=1

	if self.t<3 then self.s=bag_s end
end

function catdraw(self)
	spr(self.s, self.x, self.y, 1, 1, self.flipx, self.flipy)
end

function explode(self)
	self.r=min(16,self.r+1)
	self.w=max(self.r,cat.w)
	self.h=max(self.r,cat.h)
	self.t+=1
	if self.t==20 then
		self.active=false
		self.t=0
		self.r=1
		self.x=cat.x
		self.y=cat.y
		self.w=8
		self.h=8
	end
end

function bombdraw(self)
	local c=0
	circfill(self.x+4,self.y+4,self.r,c)
	if self.t%6<2 then
		fillp(0b1101101101101101.1)
		c=10
	elseif self.t%6<4 then
		fillp(0b1011011011011011.1)
		c=9
	else
		fillp(0b0110110110110110.1)
		c=8
	end
	circfill(self.x+4,self.y+4,self.r,c)
	-- reset so pattern doesnt affect other rect and circ elts
	fillp(0000000000000000.1)
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
00000000009999000099990000999900009999000099990005b0000005b000000000000006000060000000000999999900057000000000000005700000000000
0000000009f999900999999009999f0009999f0009f99990585b0000585b0000000000000e6006e0999999990999999900555700000000000055570000000000
00700700095f5f9009999990099f5f00099f5f00095f5f905555b0005555b000000000000e6666e099999990099ccc9905155770000000000515577000000000
0007700000fffe00009999000099ff000099ff0000fffe000055555000555550000000006656656699ccc999099c9c9955555577000000005555557700000000
000770000eeeeee00eeeeee00eeeee00feeeeeef0eeeeee00055550b0055550b0bb80b006666666699c99990099c9c9950505557700000005050555770000000
007007000feeee0f0f0eee0f0f0eee00000eee00f0eeeef00055550b0055550b8b8b8b8b6656656699ccc9990999999905005555570000000500555557000000
0000000000ee0e00000e0e00000ff00000f00f0000e0ee00005005000500005088bbb8b806655660999999900999999900005555555577000000555555557700
000000000077000000070000000ee0000e0000e00000770000b00b00b00000b00b8b800800666600999999990909090900005555555557700000555555555770
06800000068000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555507770000555555550777
68680000686800000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555500770000555555550077
55668000556680000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555500770000555555550077
00666650006666500000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555500070005555555555007
0066660b0066660b0000000000000000000000000000000000000000000000000000000000000000000000000000000000005500005500000055500000055500
0066660b0066660b0000000000000000000000000000000000000000000000000000000000000000000000000000000000005500005500000555000000005500
00500500050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000007700007700007750000000007700
00b00b00b00000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000007700007700007700000000007700
01111110022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111771272272220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111171277277220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17171771277777720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11711711277277220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17171771272272220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000003440000000000006677777777777777776600777777770066777777777777777777777777660000000000000000000000000000000000
00000000005666000044334000000000006677777777777777776600777777770066777777777777777777777777660000000000000000000000000000000000
00b000b0056676600034443066666666006677777777777777776600777777776666777777777777777777777777666600000000000000000000000000000000
00bb0b00056777600044443066666666006677777777777777776600777777776666777777777777777777777777666600000000000000000000000000000000
000bb000056676600034443077777777006677777777777777776600666666667777777766667777777766667777777700000000000000000000000000000000
00444400056676600034444077777777006677777777777777776600666666667777777766667777777766667777777700000000000000000000000000000000
04444440004444400043334077777777006677777777777777776600000000007777777700667777777766007777777700000000000000000000000000000000
00000000004440400004440077777777006677777777777777776600000000007777777700667777777766007777777700000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0081810000848586000081818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0080800000848586000082008280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
838383838388858b838383838383838300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8585858585858585858585858585858500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
878787878789858a878787878787878700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0081810000848586000081818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0082000000848586000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000848586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000c0001b4501b4501b4501b4501b4501a4501a4501945018450164501445013450104500e4500e4501500013000110000f0000d0001b00000000000000000000000000000000000000000000000000000
00040000152501b2501f250212502325024250242502325021250242502525022250202501e2501b2501725013250112501025008500085001d0000c0000c0000c0000e0001000010000100000d000110000f000
14140000145501455018550185501c5501c5501e5501e550235502355023550235502755027550275501800000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002215024150261502715028150281502815026150251502415022150201501e1501c1501b1501b15000300003000000000000000000000000000000000000000000000000000000000000000000000000
000400001f6501a6501765015650136501265011650106500e6500e6500e6500e6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000535007350093500b3500d3500f350113501235012350123500f3500f3500f350103500e3500b35009350063500335000350085001d0000c0000c0000c0000e0001000010000100000d000110000f000
000100000000039350393503935039350393503935039350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000221502415026150281501300014000281502a1502b1502c150230002d1502e15030150321500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000875008750087500875008750097500a7500b7500c7500e7501075014750187501d750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
