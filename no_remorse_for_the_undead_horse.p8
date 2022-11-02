pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- No Remorse for an Undead Horse
-- Shaun Adkins (Github: adkinsrs)

-- global vars
scene=0
score=0
screenwidth = 127
screenheight = 127
timer=1800

-- Entities (aka Player, enemies, etc)
Entity = {}
Entity.__index = Entity

function Entity.create(x,y,w,h)
	local new_entity = {}
	setmetatable(new_entity, Entity)

	new_entity.x = x
	new_entity.y = y
	new_entity.h = h
	new_entity.w = w

	return new_entity
end

function Entity:collide(other_entity)
	return other_entity.x < self.x + self.w and self.x < other_entity.x + other_entity.w
        and other_entity.y < self.y + self.h and self.y < other_entity.y + other_entity.h
end

-- Add other vars as convenience to this player entity
-- for example, the sprite number or the lives left ;)
player = Entity.create(screenwidth/2,screenheight/2,8,8)

-- game loop

function _init()
-- This function runs as soon as the game loads
	cls()
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
-- update functions
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
	score+=1
	timer-=1
	playercontrol()
end

-- draw functions
function titledraw()
	local titletxt = "no remorse"
	local titletxt2 = "for an undead horse!"
	local starttxt = "press 🅾️/z to start"
	local helptxt = "press ❎/x for instructions"
	rectfill(0,0,screenwidth, screenheight, 5)
	print(titletxt, hcenter(titletxt), screenheight/4, 11)
	print(titletxt2, hcenter(titletxt2), screenheight/4+8, 11)
	print(starttxt, hcenter(starttxt), (screenheight/4)+(screenheight/2),7)
	print(helptxt, hcenter(helptxt), (screenheight/4)+(screenheight/2)+8,7)

end

function helpdraw()
	local help = "beat as many dead horses"
	local help2 = "as you can in a minute."
	local helpz = "🅾️/z"
	local helpz2 = "touch it with a 10-foot pole"
	local helpx = "❎/x"
	local helpx2 = "let the cat out of the bag"
	local helpdir = "⬆️⬇️⬅️➡️ move player    "
	local returntext = "press ❎/x to return"

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

	playerdraw()
end

-- handle button inputs
function playercontrol()
	if btn(0) then player.x-=1 end
	if btn(1) then player.x+=1 end
	if btn(2) then player.y-=1 end
	if btn(3) then player.y+=1 end

	-- check if the player is still onscreen
	player.x = mid(0, player.x, screenwidth - player.w)
	player.y = mid(0, player.y, screenheight - player.h)

end

-- draw player sprite
function playerdraw()
	spr(1, player.x, player.y)
end

-- library functions
--- center align from: pico-8.wikia.com/wiki/centering_text
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
__gfx__
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
