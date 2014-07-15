local rich = require 'richtext'

---- Main Love Functions ----
function love.load()
	printed = {}
	local lfs = love.filesystem
	--filesTable = lfs.getDirectoryItems("words")
	filesTable = recursiveEnumerate("/words","")
	filesTable = string.split(filesTable,"\n")
	
	
	activepath = "/words/"
	words = {}
	folders = {}
	wordcount = 0
	folderImg = love.graphics.newImage("folder.png")
	
	for i,v in ipairs(filesTable) do
		folder, name, ext = splitfilename(v)
		if not folders[folder] then
			folders[folder] = {}
			folders[folder]["cnt"] = 0
		end
		
		name = string.split(name:lower(),".")[1]  -- pesky case sensitive stuff

		if not words[name] and ext == "png" and not lfs.isDirectory(folder .. name) then
			words[name] = {}
			words[name]["image"] = love.graphics.newImage(folder .. name .. ".png")
			words[name]["snd"] = love.audio.newSource(folder .. name .. ".ogg")
			words[name]["folder"] = folder
		end
		
		if not words[name] and lfs.isDirectory(folder .. name) then
			words[name] = {}
			words[name]["folder"] = folder
			words[name]["newfolder"] = folder .. name .. "/"
			if lfs.exists(folder .. name .. "/" .. name .. ".png") then
				words[name]["image"] = love.graphics.newImage(folder .. name.. "/" .. name .. ".png")
			else
				words[name]["image"] = folderImg
			end
			if lfs.exists(folder .. name .. "/" ..name .. ".ogg") then
				words[name]["snd"] = love.audio.newSource(folder .. name .."/" .. name.. ".ogg")
			end
		end 
	end
	
	
	for key,v in pairsByKeys(folders) do
		print("Folder: " .. key)
		for wkey,wv in pairsByKeys(words) do
			if words[wkey]["folder"] == key then
				print (wkey)
				folders[key]["cnt"] = folders[key]["cnt"]+1
			end 
		end
	end
	
	for f,v in pairsByKeys(folders) do
		t = folders[f]["cnt"]
		folders[f]["rows"] = math.floor(math.sqrt(t))
		local rows = folders[f]["rows"]
		coladd = 0
		if math.floor(rows*1.3+0.5)*rows < t then 
			coladd = 0
			while math.floor(rows*1.3+0.5)*rows+coladd < t do
				coladd = coladd + 1
			end
		end
		folders[f]["columns"] = math.floor(rows*1.3+0.5) + coladd	
		local columns = folders[f]["columns"]
		folders[f]["font"] = love.graphics.newFont(50-rows*12)
		
		
		-- adding the grid positions
		col = 0
		row = 0
		i = 1
		-- for key,v in pairs(words) do
		for key,v in pairsByKeys(words) do
			-- assign locations to each words
			if words[key]["folder"] == f then
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
	end
end

function love.draw()
	local lg = love.graphics
	
	r = 0
	c = 0
	for key,v in pairsByKeys(words) do
		local columns = folders[activepath]["columns"]
		local rows = folders[activepath]["rows"]
		
		colwidth = math.floor(love.window.getWidth( ) / columns)
		rowheight = math.floor(love.window.getHeight( ) / rows)

		if activepath == words[key]["folder"] then
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

			-- draw the image
			lg.draw(words[key]["image"],c*colwidth+xoffset,r*rowheight+yoffset,0,scale,scale)
			
			-- draw text over the folder image
			if words[key]["image"] == folderImg then
				lg.setFont(folders[activepath]["font"])
				mainFont = folders[activepath]["font"]
				local x = c*colwidth+colwidth/2-mainFont:getWidth(key)/2
				local y = r*rowheight+rowheight/2-mainFont:getHeight(key)/2
				local textwidth = mainFont:getWidth(key)/2
				local toptext = rich.new{"{white}".. key,textwidth,white={255,255,255}}
				local bottext = rich.new{"{black}".. key,textwidth,black={0,0,0}}
				bottext:draw(x+2,y+2)
				toptext:draw(x,y)
			end
			--lg.draw(words[key]["image"],c*colwidth,r*rowheight)
			if c >= columns -1 then 
				r = r + 1
				c = -1
			end
			c=c+1
		end
	end
end

function love.mousereleased(x, y, button)
	local columns = folders[activepath]["columns"]
	local rows = folders[activepath]["rows"]
	colwidth = math.floor(love.window.getWidth( ) / columns)
	rowheight = math.floor(love.window.getHeight( ) / rows)
	
	local testx = math.floor(x / colwidth)
	local testy = math.floor(y / rowheight)
	print(testx)
	print(testy)

	for key,v in pairs(words) do
		if words[key]["folder"] == activepath then
			print("Word: " .. key .. "	 Left: " ..words[key]["left"])
			print("Word: " .. key .. "	 Top: " ..words[key]["top"])
			if testx == words[key]["left"] and testy == words[key]["top"] then
				if words[key]["newfolder"] then 
					activepath = words[key]["newfolder"] 
					if words[key]["snd"] then love.audio.play(words[key]["snd"]) end
					break
				end
				if words[key]["snd"] and activepath == words[key]["folder"] then 
					love.audio.play(words[key]["snd"]) 
				end
				print("Clicked word " .. key)
			end
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		if activepath == "/words/" then 
			love.event.quit() 
		else
			print(activepath)
			-- this code I don't think works for depths more than 1 directory...
			activepath = "/" .. string.split(activepath,"/")[1] .. "/"
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
            fileTree = fileTree.."\n"..file..""
            fileTree = recursiveEnumerate(file, fileTree)
        end
    end
    return fileTree
end

function splitfilename(strfilename)
	-- Returns the Path, Filename, and Extension as 3 values
	return string.match(strfilename:lower(),"(.-)([^\\/]-%.?([^%.\\/]*))$")
end