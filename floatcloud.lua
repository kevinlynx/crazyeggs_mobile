--
-- floatcloud.lua
-- Kevin Lynx
-- 3.17.2012
--
Cloud = {}

local clouds = {}

local function getTranPos(img)
    local imgw = img.originalWidth / 2
    local w = config.sizes[config.device][3]
    local h = config.sizes[config.device][4]
    local sy = math.random(h - 100) + 50
    local sx = - imgw
    local dx = w + imgw
    if math.random(10) > 5 then
        sx = w + imgw
        dx = - imgw
    end
    return sx, sy, dx, sy
end

local function updateImgPos(o)
    o.img.x = o.x
    o.img.y = o.y
end

local function isDone(o)
    if o.speed < 0 then
        return o.x <= o.dx
    else
        return o.x >= o.dx
    end
end

function Cloud:create()
    local o = {
        x = 0,
        y = 0,
        dx = 0,
        speed = 0,
        img = nil
    }
    local i = math.random(4)
    o.img = RNFactory.createImage("res/cloud"..i..".png")
    local alpha = math.random(6) / 10 + 0.2
    o.img:setAlpha(alpha)
    o.img:setLevel(1)
    o.x, o.y, o.dx, _ = getTranPos(o.img)
    updateImgPos(o)
    if o.x > o.dx then
        o.speed = -math.random(10) / 100
    else
        o.speed = math.random(10) / 100
    end
    return newObject(o, Cloud)
end

function Cloud:update(dt)
    self.x = self.x + self.speed * dt
    updateImgPos(self)
    return isDone(self)
end

function Cloud:remove()
    self.img:remove()
end

function Cloud.loop(dt)
    local i = 1
    while i <= table.maxn(clouds) do
        if clouds[i]:update(dt) then
            clouds[i]:remove()
            table.remove(clouds, i)
        else
            i = i + 1
        end
    end
    if math.random(200) > 190 then
        table.insert(clouds, Cloud:create())
    end
end

