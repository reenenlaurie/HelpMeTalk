function love.load()
	local lfs = love.filesystem
	filesTable = lfs.getDirectoryItems("words")

	words = {}
	names = {}
	exts = {}
	wordcount = 0
    for i,v in ipairs(filesTable) do

    	name = string.split(v, ".")[1]
    	ext = string.split(v, ".")[2]
   		names[i] = name
   		exts[i] = ext
   		-- create buttons
     	if words[name] == nil and ext ~= "lua" then
    		words[name] = {}
    		words[name]["image"] = love.graphics.newImage("words/" .. name .. ".png")
    		words[name]["snd"] = love.audio.newSource("words/" ..name .. ".ogg")
    		wordcount = wordcount + 1
    	end
    end

  	t = wordcount
    rows = math.floor(math.sqrt(t))
    coladd = 0
    if math.floor(rows*1.3+0.5)*rows < t then 
    	coladd = 0
    	while math.floor(rows*1.3+0.5)*rows+coladd < t do
    		coladd = coladd + 1
    	end
    end
    columns = math.floor(rows*1.3+0.5) + coladd
   

    -- adding the grid positions
    col = 0
	row = 0
    i = 1
	for key,v in pairs(words) do
    	-- assign locations to each words
    	words[key]["left"] = col
    	words[key]["top"] = row
		col = col + 1
    	i = i + 1
    	if col >= columns then 
			col = 0
			row = row + 1
		end
    end
end

function love.draw()
	local lg = love.graphics
	
	colwidth = math.floor(love.window.getWidth( ) / columns)
	rowheight = math.floor(love.window.getHeight( ) / rows)

	r = 0
	c = 0
	for key,v in pairs(words) do
    	--lg.draw(v["image"], r*rowheight, c*colwidth)
    	w = words[key]["image"]:getWidth()
    	h = words[key]["image"]:getHeight()
    	
    	blockratio = colwidth/rowheight
    	imageratio = w/h

    	scalex = colwidth / w
    	scaley = rowheight / h

    	if imageratio > blockratio then 
    		scale = scalex
    		yoffset = math.floor((colwidth - w*scaley)/2)
    		xoffset = 0
    	else
    		scale = scaley
    		yoffset = 0
    		xoffset = math.floor((rowheight - h*scalex)/2)
    	end

    	lg.draw(words[key]["image"],c*colwidth-xoffset,r*rowheight-yoffset,0,scale,scale)
    	--lg.draw(words[key]["image"],c*colwidth,r*rowheight)
    	if c >= columns-1 then 
    		r = r + 1
    		c = -1
    	end
    	c=c+1
    end
end

function string:split(sep) 
	-- CalinLeafshade on IRC wrote this
	local sep, fields = sep or ":", {} 
	local pattern = string.format("([^%s]+)", sep) 
	self:gsub(pattern, function(c) fields[#fields+1] = c end) 
	return fields 
end 

function love.mousepressed(x, y, button)
	testx = math.floor(x / colwidth)
	testy = math.floor(y / rowheight)
	print(testx)
	print(testy)

	for key,v in pairs(words) do
		print("Word: " .. key .. "   Left: " ..words[key]["left"])
		print("Word: " .. key .. "   Top: " ..words[key]["top"])
		if testx == words[key]["left"] and testy == words[key]["top"] then
			love.audio.play(words[key]["snd"])
		end
	end
end