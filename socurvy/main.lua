--[[ Screensaver thing wherein colorful curves fall down ]]

-- variable aliasing for random
r = love.math.random
min, max = 1, 500

function love.load()
	ww, wh = love.graphics.getDimensions()

	love.mouse.setVisible(false)

	--[[ set up physics ]]
	world = love.physics.newWorld(0, 180) -- 6 * meter

	-- useless borders just in case of curves going too far to the side
	rEdge = {}
	rEdge.body = love.physics.newBody(world, ww + max, 0, 'static')
	rEdge.shape = love.physics.newRectangleShape(1, wh * 2)
	rEdge.fix = love.physics.newFixture(rEdge.body, rEdge.shape)
	lEdge = {}
	lEdge.body = love.physics.newBody(world, -max - 1, 0, 'static')
	lEdge.shape = love.physics.newRectangleShape(1, wh * 2)
	lEdge.fix = love.physics.newFixture(lEdge.body, lEdge.shape)

	--[[ tables for the 'curves' ]]
	curves = {} -- contain Bezier curve to be drawn
	phc = {} -- contain physicality of curves
end

--[[ magic code modified from: love2d.org/forums/viewtopic.php?t=9524#p59014 ]]
CG = {}
function CG:setColor(c)
	if self.lastColor ~= c then
		self.lastColor = c
		love.graphics.setColor(c)
	end
	return self
end

function CG:drawLine(t, c)
	if c then self:setColor(c) end
	love.graphics.line(t)
	if c then self:setColor({1,1,1,1}) end
	return self
end
--

function love.draw()
	for c in pairs(curves) do
		CG:drawLine(curves[c]:render(), phc[c].color) -- draw the curve
	end
end

function love.update(dt)
	world:update(dt)

	if love.keyboard.isDown('escape') then
		love.event.quit()
	end

	table.insert(phc, createPhysicsCurve()) -- every frame create a new curve

	for c in pairs(phc) do
		if phc[c].body:getY() > wh + max then -- delete curve when it falls off screen
			phc[c].body:destroy()
			phc[c] = nill
			curves[c] = nill
		else -- create the part of the curve that is drawn
			curves[c] = love.math.newBezierCurve(
				phc[c].body:getWorldPoints(
					phc[c].shape:getPoints()))
		end
	end
	--print(love.timer.getFPS())
end

function createPhysicsCurve() --[[ creates the main/physics parts of the curve and spins it ]]
	pc = {} -- contain curve physics and color

	pc.body = love.physics.newBody(world, r(ww - max), -max - 1, 'dynamic')
	pc.shape = love.physics.newChainShape(false,
r(min,max),r(min,max),
r(min,max),r(min,max),
r(min,max),r(min,max),
r(min,max),r(min,max),
r(min,max),r(min,max),
r(min,max),r(min,max),
r(min,max),r(min,max),
r(min,max),r(min,max))
	pc.fix = love.physics.newFixture(pc.body, pc.shape)

	pc.color = {r(), r(), r()}

	pc.body:setInertia(1)
	pc.body:applyTorque(r(-2 * math.pi, 2 * math.pi)) -- Spain without the 'a'

	return pc
end