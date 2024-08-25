function love.load()
    train = {
        x = 50,
        y = love.graphics.getHeight() / 2 - 10,
        width = 60,
        height = 20,
        speed = 100,
        acceleration = 50
    }

    track = {
        y = love.graphics.getHeight() / 2 - 5,
        height = 10
    }

    trackLength = love.graphics.getWidth()
end

function love.update(dt)
    train.x = train.x + train.speed * dt

    if train.x > trackLength then
        train.x = -train.width
    end

    if love.keyboard.isDown("right") then
        train.speed = train.speed + train.acceleration * dt
    elseif love.keyboard.isDown("left") then
        train.speed = train.speed - train.acceleration * dt
    end
end

function love.draw()
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", 0, track.y, trackLength, track.height)

    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", train.x, train.y, train.width, train.height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Speed: " .. math.floor(train.speed), 10, 10)
end
