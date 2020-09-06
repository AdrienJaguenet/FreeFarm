settings = {
	MAP_HEIGHT = 10,
	MAP_WIDTH = 10
}

Tile = {}
function Tile:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

function love.load()
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
		}
	}
	settings.TILE_WIDTH = gfx.tiles['grass']:getWidth()
	settings.TILE_HEIGHT = gfx.tiles['grass']:getHeight()
end

function love.update(dt)
end

function drawTile(t, i, j)
	love.graphics.draw(gfx.tiles[t.terrain], i * settings.TILE_WIDTH, j * settings.TILE_HEIGHT)
end

function love.draw()
	for i=1,settings.MAP_WIDTH do
		for j=1,settings.MAP_HEIGHT do
			drawTile(terrain[i][j], i, j)
		end
	end
end

function love.mousepressed(x, y, k)
	if k == 1 then
		-- get tile where the click has happened
		local tx = math.floor(x / settings.TILE_WIDTH)
		local ty = math.floor(y / settings.TILE_HEIGHT)
		if tx > 0 and tx < settings.MAP_WIDTH and ty > 0 and ty < settings.MAP_HEIGHT then
			terrain[tx][ty].terrain = 'soil'
		end
	end
end

