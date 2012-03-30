--
-- egg.lua
-- Kevin Lynx
-- 3.13.2012
--
Egg = {}

Egg.MAX = 36
Egg.WIDTH = 40
Egg.HEIGHT = 40
Egg.main = RNFactory.createMoaiImage("res/eggs.png")

local function getPos(index)
    local x = index % 6
    local y = math.floor(index / 6) 
    return x * Egg.WIDTH, y * Egg.HEIGHT
end

local function createSubImg(index)
    local x, y
    x, y = getPos(index)
    return RNFactory.createCopyRect(Egg.main,
        { srcXMin = x, srcYMin = y, srcXMax = x + Egg.WIDTH, srcYMax = y + Egg.HEIGHT,
          destXMin = 0, destYMin = 0, destXMax = Egg.WIDTH, destYMax = Egg.HEIGHT })
end

function Egg.create(index)
    local egg = {}
    egg.index = index
    egg.image = createSubImg(egg.index)
    return egg
end

