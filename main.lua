settings = {
	MAP_HEIGHT = 15,
	MAP_WIDTH = 20
}

inventory = {
	rye = 0
}

toolfuncs = {}

function toolfuncs.till(i, j)
	local tile = terrain[i][j]
	if tile.terrain == 'grass' then
		tile.terrain = 'soil'
	end
end

function toolfuncs.plant(i, j)
	local tile = terrain[i][j]
	if not tile.seed and tile.terrain == 'soil' then
		tile.seed = 'rye'
		tile.growth = 1
	end
end

function toolfuncs.harvest(i, j)
	local tile = terrain[i][j]
	if tile.growth and tile.growth == 5 then
		inventory[tile.seed] = inventory[tile.seed] + math.random(2,3)
		tile.seed = nil
	end
end

Tile = {}
function Tile:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

function love.load()
	love.window.setMode(640, 480)
	terrain = {}
	for i=1,settings.MAP_WIDTH do
		terrain[i] = {}
		for j=1,settings.MAP_HEIGHT do
			terrain[i][j] = Tile:new {terrain = 'grass'}
		end
	end

	gfx = {
		tiles = {
			['grass'] = love.graphics.newImage('resources/gfx/grass.png'),
			['soil'] = love.graphics.newImage('resources/gfx/soil.png')
		},
		plants = {
			rye = {
				love.graphics.newImage('resources/gfx/rye1.png'),
				love.graphics.newImage('resources/gfx/rye2.png'),
				love.graphics.newImage('resources/gfx/rye3.png'),
				love.graphics.newImage('resources/gfx/rye4.png'),
				love.graphics.newImage('resources/gfx/rye5.png')
			}
		},
		tools = {
			shovel = love.graphics.newImage('resources/gfx/shovel.png'),
			seedbag = love.graphics.newImage('resources/gfx/seedbag.png'),
			scythe = love.graphics.newImage('resources/gfx/scythe.png')
		},
	}
	gfx.cursors = {
		shovel = love.mouse.newCursor(love.image.newImageData('resources/gfx/shovel.png')),
		seedbag = love.mouse.newCursor(love.image.newImageData('resources/gfx/seedbag.png')),
		scythe = love.mouse.newCursor(love.image.newImageData('resources/gfx/scythe.png'))
	}
	settings.TILE_WIDTH = gfx.tiles['grass']:getWidth()
	settings.TILE_HEIGHT = gfx.tiles['grass']:getHeight()
	tools = {
		shovel = {
			gfx = gfx.tools.shovel,
			action = toolfuncs.till,
			cursor = gfx.cursors.shovel
		},
		seedbag = {
			gfx = gfx.tools.seedbag,
			action = toolfuncs.plant,
			cursor = gfx.cursors.seedbag
		},
		scythe = {
			gfx = gfx.tools.scythe,
			action = toolfuncs.harvest,
			cursor = gfx.cursors.scythe
		}
	}
	current_tool = tools.shovel
	love.mouse.setCursor(current_tool.cursor)
end

function love.update(dt)
	for i=1,settings.MAP_WIDTH do
		for j=1,settings.MAP_HEIGHT do
			local tile = terrain[i][j]
			if tile.seed and tile.growth < 5 and math.random(1,10) == 1 then
				tile.growth = tile.growth + 1
			end
		end
	end
end

function drawTile(t, i, j)
	local screenx = (i-1) * settings.TILE_WIDTH
	local screeny = (j-1) * settings.TILE_HEIGHT
	love.graphics.draw(gfx.tiles[t.terrain], screenx, screeny)
	if t.seed then
		love.graphics.draw(gfx.plants[t.seed][t.growth], screenx, screeny)
	end
end

function drawInventory()
	str = ''
	for k,v in pairs(inventory) do
		str = str..(k..': '..v..'\n')
	end
	love.graphics.print(str, 0, 0)
end

function love.draw()
	drawInventory()
	for i=1,settings.MAP_WIDTH do
		for j=1,settings.MAP_HEIGHT do
			drawTile(terrain[i][j], i, j)
		end
	end
end

function love.mousepressed(x, y, k)
	if k == 1 then
		-- get tile where the click has happened
		local tx = math.ceil(x / settings.TILE_WIDTH)
		local ty = math.ceil(y / settings.TILE_HEIGHT)
		if tx > 0 and tx <= settings.MAP_WIDTH and ty > 0 and ty <= settings.MAP_HEIGHT then
			current_tool.action(tx, ty)
		end
	end
end

function love.wheelmoved(x, y)
	if y > 0 then
		if current_tool == tools.shovel then
			current_tool = tools.seedbag
		elseif current_tool == tools.seedbag then
			current_tool = tools.scythe
		elseif current_tool == tools.scythe then
			current_tool = tools.shovel
		end
	elseif y < 0 then
		if current_tool == tools.shovel then
			current_tool = tools.scythe
		elseif current_tool == tools.seedbag then
			current_tool = tools.shovel
		elseif current_tool == tools.scythe then
			current_tool = tools.seedbag
		end
	end
	love.mouse.setCursor(current_tool.cursor)
end

