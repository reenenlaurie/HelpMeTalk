---- Main Love Functions ----
function love.load()
	local lfs = love.filesystem
	filesTable = lfs.getDirectoryItems("words")
	--filesTable = recursiveEnumerate("words")
	words = {}
	folders = {}
	wordcount = 0
	files = {}
	folderImg = love.graphics.newImage("folder.png")
	
	for i,v in ipairs(filesTable) do

		name = string.split(v, ".")[1]
		ext = string.split(v, ".")[2]

		-- I need error checking.
		-- All .png must have .ogg else it's ignored, similarly all .png must have a .ogg or is ignored
		-- Should not be case sensitive
		-- Folders can have a .png and .ogg in them with their name, but is not needed
		

		if words[name] == nil and ext ~= "lua" and not lfs.isDirectory("words/" .. v) then
			words[name] = {}
			words[name]["image"] = love.graphics.newImage("words/" .. name .. ".png")
			words[name]["snd"] = love.audio.newSource("words/" ..name .. ".ogg")
			wordcount = wordcount + 1
		end
		
		if words[name] == nil and lfs.isDirectory("words/" .. v) then
			words[name] = {}
			if lfs.exists("words/" .. name .. "/" .. name .. ".png") then
				words[name]["image"] = love.graphics.newImage("words/" .. name .. "/" .. name .. ".png")
			else
				words[name]["image"] = folderImg
			end
			if lfs.exists("words/" .. name .. "/" .. name .. ".ogg") then
				words[name]["snd"] = love.audio.newSource("words/" .. name .. "/" .. name .. ".ogg")
			end
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
	-- for key,v in pairs(words) do
	for key,v in pairsByKeys(words) do
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
	for key,v in pairsByKeys(words) do
		--lg.draw(v["image"], r*rowheight, c*colwidth)
		w = words[key]["image"]:getWidth()
		h = words[key]["image"]:getHeight()
		
		blockratio = colwidth/rowheight
		imageratio = w/h

		scalex = colwidth / w
		scaley = rowheight / h
		


		if imageratio > blockratio then 
			scale = scalex
			yoffset = rowheight/2 - h*scale/2
			xoffset = 0
		else
			scale = scaley
			yoffset = 0
			xoffset = colwidth/2 - w*scale/2
		end

		
		lg.draw(words[key]["image"],c*colwidth+xoffset,r*rowheight+yoffset,0,scale,scale)
		if words[key]["image"] == folderImg then
			lg.print(key,c*colwidth-xoffset/2,r*rowheight-yoffset/2)
		end
		--lg.draw(words[key]["image"],c*colwidth,r*rowheight)
		if c >= columns-1 then 
			r = r + 1
			c = -1
		end
		c=c+1
	end
end

function love.mousepressed(x, y, button)
	local testx = math.floor(x / colwidth)
	local testy = math.floor(y / rowheight)
	print(testx)
	print(testy)

	for key,v in pairs(words) do
		print("Word: " .. key .. "	 Left: " ..words[key]["left"])
		print("Word: " .. key .. "	 Top: " ..words[key]["top"])
		if testx == words[key]["left"] and testy == words[key]["top"] then
			love.audio.play(words[key]["snd"])
			print("Clicked word " .. key)
		end
	end
end

----  Helper functions	----
function pairsByKeys (t, f)
	--- From http://www.lua.org/pil/19.3.html .. I believe official lua docs
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0		 -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

function string:split(sep) 
	-- CalinLeafshade on IRC wrote this
	local sep, fields = sep or ":", {} 
	local pattern = string.format("([^%s]+)", sep) 
	self:gsub(pattern, function(c) fields[#fields+1] = c end) 
	return fields 
end 

function recursiveEnumerate(folder, fileTree)
    local lfs = love.filesystem
    local filesTable = lfs.getDirectoryItems(folder)
    for i,v in ipairs(filesTable) do
        local file = folder.."/"..v
        if lfs.isFile(file) then
            fileTree = fileTree.."\n"..file
        elseif lfs.isDirectory(file) then
            fileTree = fileTree.."\n"..file.." (DIR)"
            fileTree = recursiveEnumerate(file, fileTree)
        end
    end
    return fileTree
end