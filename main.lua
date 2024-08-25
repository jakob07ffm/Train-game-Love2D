function love.load()
    track = {
        segments = {
            {x = 50, y = love.graphics.getHeight() / 2, angle = 0, length = 200},
            {x = 250, y = love.graphics.getHeight() / 2, angle = math.pi / 4, length = 100},
            {x = 350, y = love.graphics.getHeight() / 2 + 70, angle = -math.pi / 4, length = 100},
            {x = 450, y = love.graphics.getHeight() / 2, angle = 0, length = 200}
        }
    }

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
        angle = 0
    }
end

function love.update(dt)
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
end

function love.draw()
    love.graphics.setColor(0.8, 0.8, 0.8)

    for _, segment in ipairs(track.segments) do
        love.graphics.push()
        love.graphics.translate(segment.x, segment.y)
        love.graphics.rotate(segment.angle)
        love.graphics.rectangle("fill", 0, -5, segment.length, 10)
        love.graphics.pop()
    end

    love.graphics.setColor(0, 0.5, 1)
    love.graphics.push()
    love.graphics.translate(train.x, train.y)
    love.graphics.rotate(train.angle)
    love.graphics.rectangle("fill", -train.width / 2, -train.height / 2, train.width, train.height)
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Speed: " .. math.floor(train.speed), 10, 10)
    love.graphics.print("Segment: " .. train.segmentIndex, 10, 30)
end
