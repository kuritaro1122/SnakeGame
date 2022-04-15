pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
vec2d = {
	__add=function(a,b)
		return {x=a.x+b.x, y=a.y+b.y}
	end
}
---
blocksize = 8
defaultlength = 3
body = {}
stagesize = { x = 15, y = 15 } setmetatable(stagesize, vec2d)
direction = { x = 0, y = 1 } setmetatable(direction, vec2d)
nowdirection = { x = 0, y = 1 } setmetatable(nowdirection, vec2d)
---
last = 0
span = 0.10
---
play = true
---
fruits = { x = -5, y = -5 }
---

function _init()
	local anchor = { x = 8, y = 0 } setmetatable(anchor, vec2d)
	body = {}
	for i = 1, defaultlength do
        if (i == 1) then
            body[i] = anchor
        else
			local offset = { x = -direction.x, y = -direction.y } setmetatable(offset, vec2d)
            body[i] = body[i - 1] + offset
        end
	end
	play = true
end

function _update()
	if (play == false) return
	if btn(0) then
		if (nowdirection.x == 0) direction = { x = -1, y = 0 }
	elseif btn(1) then
		if (nowdirection.x == 0) direction = { x = 1, y = 0 }
	elseif btn(2) then
		if (nowdirection.y == 0) direction = { x = 0, y = -1 }
	elseif btn(3) then
		if (nowdirection.y == 0) direction = { x = 0, y = 1 }
	end
	if time() - last > span then
		move()
		collision()
		last = time()
		
	end
	eatfruit()
	generatefruit()
end

function move()
	for i = 1, #body do
		index = #body - i + 1
		if (index > 1) then
			body[index].x = body[index - 1].x
			body[index].y = body[index - 1].y
		else
			body[index].x = body[index].x + direction.x
			body[index].y = body[index].y + direction.y
		end
	end
	nowdirection.x = direction.x
	nowdirection.y = direction.y
end
function collision()
	if (body[1].x < 1 or body[1].x > stagesize.x) play = false
	if (body[1].x < 1 or body[1].y > stagesize.y) play = false
	for i = 1, #body do
		if i > 1 then
			if (body[1].x == body[i].x and body[1].y == body[i].y) play = false
		end
	end
end

function eatfruit()
	if (body[1].x == fruits.x and body[1].y == fruits.y) then
		fruits = { x = -5, y = -5 }
		local anchor = { x = body[#body].x, y = body[#body].y } setmetatable(anchor, vec2d)
		body[#body + 1] = anchor
		local offset = { x = -direction.x, y = -direction.y } setmetatable(offset, vec2d)
		body[#body] = body[#body] + offset
	end
end

function generatefruit()
	if (fruits.x < 0) then
		fruits.x = 1 + flr(rnd(stagesize.x))
		fruits.y = 1 + flr(rnd(stagesize.y))
	end
end

function _draw()
	cls()
	local score = "score:"..10*(#body - defaultlength)
	local p = " pos:"..body[1].x..","..body[1].y
	local f = " fruits:"..fruits.x..","..fruits.y
	print(score..p..f)
	local anchor = { x = 0, y = 0 } setmetatable(anchor, vec2d)
	for i = 1, stagesize.x do
        for k = 1, stagesize.y do
            local pos = { x=anchor.x + blocksize * i, y=anchor.y + blocksize * k }
            spr(16, pos.x, pos.y)
        end
    end
    for i = 1, #body do
        local pos = { x=anchor.x + body[i].x * blocksize, y=anchor.y + body[i].y * blocksize }
		if i == 1 then
			if nowdirection.x < 0 then
				spr(1, pos.x, pos.y)
			elseif nowdirection.x > 0 then
				spr(2, pos.x, pos.y)
			elseif nowdirection.y < 0 then
				spr(3, pos.x, pos.y)
			elseif nowdirection.y > 0 then
				spr(4, pos.x, pos.y)
			end
		else
			spr(i % 2 + 5, pos.x, pos.y)
		end
	end
	if (play == false) then
		print("gameover", 127 / 2 - 8, 127 / 2)
	end
	spr(17, anchor.x + fruits.x * blocksize, anchor.y + fruits.y * blocksize)
end
