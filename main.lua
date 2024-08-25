function love.load()
    -- Track Layout
    generateTrack()

    train = {
        x = track.segments[1].x,
        y = track.segments[1].y,
        width = 60,
        height = 20,
        speed = 100,
        maxSpeed = 300,
        minSpeed = 50,
        acceleration = 100,
        deceleration = 75,
        segmentIndex = 1,
        angle = 0,
        wheelRotation = 0
    }

    background = {
        trees = {},
        clouds = {}
    }

    for i = 1, 10 do
        table.insert(background.trees, {x = math.random(0, love.graphics.getWidth()), y = love.graphics.getHeight() - 100, width = 20, height = 60})
    end

    for i = 1, 5 do
        table.insert(background.clouds, {x = math.random(0, love.graphics.getWidth()), y = math.random(50, 150), size = math.random(30, 80)})
    end

    speedBoosts = {
        {x = 300, y = love.graphics.getHeight() / 2 - 20, radius = 15},
        {x = 550, y = love.graphics.getHeight() / 2 - 20, radius = 15}
    }

    obstacles = {
        {x = 400, y = love.graphics.getHeight() / 2 - 20, radius = 15},
        {x = 700, y = love.graphics.getHeight() / 2 - 20, radius = 15}
    }

    smoke = {}
    timeOfDay = 0 -- Day-Night cycle timer
    cameraOffset = 0
end

function generateTrack()
    track = {
        segments = {}
    }
    local x, y = 50, love.graphics.getHeight() / 2
    local angles = {0, math.pi / 4, -math.pi / 4, math.pi / 2, -math.pi / 2}
    for i = 1, 10 do
        local angle = angles[math.random(1, #angles)]
        local length = math.random(100, 300)
        table.insert(track.segments, {x = x, y = y, angle = angle, length = length})
        x = x + math.cos(angle) * length
        y = y + math.sin(angle) * length
    end
end

function love.update(dt)
    -- Update time of day for the day-night cycle
    timeOfDay = (timeOfDay + dt / 60) % 1

    local segment = track.segments[train.segmentIndex]
    local nextX = train.x + math.cos(segment.angle) * train.speed * dt
    local nextY = train.y + math.sin(segment.angle) * train.speed * dt

    if nextX > segment.x + math.cos(segment.angle) * segment.length or
       nextY > segment.y + math.sin(segment.angle) * segment.length then
        train.segmentIndex = train.segmentIndex + 1

        if train.segmentIndex > #track.segments then
            train.segmentIndex = 1
        end

        segment = track.segments[train.segmentIndex]
        train.x = segment.x
        train.y = segment.y
        train.angle = segment.angle
    else
        train.x = nextX
        train.y = nextY
    end

    if love.keyboard.isDown("right") then
        train.speed = math.min(train.speed + train.acceleration * dt, train.maxSpeed)
    elseif love.keyboard.isDown("left") then
        train.speed = math.max(train.speed - train.deceleration * dt, train.minSpeed)
    end

    -- Update smoke particles
    if train.speed > 0 then
        table.insert(smoke, {x = train.x - math.cos(train.angle) * train.width / 2, y = train.y - math.sin(train.angle) * train.width / 2, alpha = 1})
    end

    for i = #smoke, 1, -1 do
        smoke[i].alpha = smoke[i].alpha - dt
        if smoke[i].alpha <= 0 then
            table.remove(smoke, i)
        end
    end

    -- Collision with speed boosts
    for _, boost in ipairs(speedBoosts) do
        local dist = math.sqrt((train.x - boost.x) ^ 2 + (train.y - boost.y) ^ 2)
        if dist < boost.radius + train.width / 2 then
            train.speed = math.min(train.speed + train.acceleration * dt * 5, train.maxSpeed)
        end
    end

    -- Collision with obstacles
    for _, obstacle in ipairs(obstacles) do
        local dist = math.sqrt((train.x - obstacle.x) ^ 2 + (train.y - obstacle.y) ^ 2)
        if dist < obstacle.radius + train.width / 2 then
            train.speed = math.max(train.speed - train.deceleration * dt * 10, train.minSpeed)
        end
    end

    train.wheelRotation = train.wheelRotation + (train.speed / 20) * dt

    -- Update camera to follow the train
    cameraOffset = train.x - love.graphics.getWidth() / 2
end

function love.draw()
    -- Set background color based on time of day
    local r = 0.6 + 0.4 * math.sin(2 * math.pi * timeOfDay)
    local g = 0.8 + 0.2 * math.sin(2 * math.pi * timeOfDay)
    local b = 1 - 0.5 * math.sin(2 * math.pi * timeOfDay)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Translate for camera
    love.graphics.push()
    love.graphics.translate(-cameraOffset, 0)

    -- Draw background elements
    love.graphics.setColor(0.4, 0.7, 0.1)
    for _, tree in ipairs(background.trees) do
        love.graphics.rectangle("fill", tree.x, tree.y, tree.width, tree.height)
    end

    love.graphics.setColor(1, 1, 1)
    for _, cloud in ipairs(background.clouds) do
        love.graphics.circle("fill", cloud.x, cloud.y, cloud.size)
    end

    -- Draw track
    love.graphics.setColor(0.8, 0.8, 0.8)
    for _, segment in ipairs(track.segments) do
        love.graphics.push()
        love.graphics.translate(segment.x, segment.y)
        love.graphics.rotate(segment.angle)
        love.graphics.rectangle("fill", 0, -5, segment.length, 10)
        love.graphics.pop()
    end

    -- Draw speed boosts
    love.graphics.setColor(1, 0.5, 0)
    for _, boost in ipairs(speedBoosts) do
        love.graphics.circle("fill", boost.x, boost.y, boost.radius)
    end

    -- Draw obstacles
    love.graphics.setColor(0.5, 0, 0)
    for _, obstacle in ipairs(obstacles) do
        love.graphics.circle("fill", obstacle.x, obstacle.y, obstacle.radius)
    end

    -- Draw train
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.push()
    love.graphics.translate(train.x, train.y)
    love.graphics.rotate(train.angle)
    love.graphics.rectangle("fill", -train.width / 2, -train.height / 2, train.width, train.height)

    -- Draw wheels
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", -train.width / 4, train.height / 2, 8)
    love.graphics.circle("fill", train.width / 4, train.height / 2, 8)

    love.graphics.pop()

    -- Draw smoke
    for _, puff in ipairs(smoke) do
        love.graphics.setColor(0.5, 0.5, 0.5, puff.alpha)
        love.graphics.circle("fill", puff.x, puff.y, 10)
    end

    -- Draw HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Speed: " .. math.floor(train.speed), 10 + cameraOffset, 10)
    love.graphics.print("Segment: " .. train.segmentIndex, 10 + cameraOffset, 30)

    love.graphics.pop() -- End camera translation
end
