--
-- pannel.lua
-- Kevin Lynx
-- 3.14.2012
--
Pannel = {}
Pannel.width = 10
Pannel.height = 8
Pannel.start_x = 115
Pannel.start_y = 50
Pannel.eggs = {}
Pannel.selected = 0
Pannel.tran = RNTransition:new()

-- pos in tile center
local function tileToPos(x, y)
    return Pannel.start_x + x * Egg.WIDTH + Egg.WIDTH / 2, 
        Pannel.start_y + y * Egg.HEIGHT + Egg.HEIGHT / 2
end

local function loadCursor(parent)
    local cursor = RNFactory.createAnim("res/lock.png", 40, 40, 0, 0, 0.5, 0.5)
    cursor:newSequence("default", {1, 2}, 5, -1)
    cursor:play()
    cursor.visible = false
    cursor:bringToFront()
    return cursor
end

local function loadHintAnim()
    local hand = RNFactory.createAnim("res/hand.png", 40, 50, 0, 0, 0.5, 0.5)
    hand:newSequence("default", {1, 2, 3, 4, 5, 6, 7}, 5, -1)
    hand:play()
    hand.visible = false
    hand:setLevel(1000) -- so that it can on top of all images
    return hand
end

local function hideHand()
    Pannel.hand1.visible = false
    Pannel.hand2.visible = false
end

local function loadHorLightning(scalex, scaley)
    local lightning = RNFactory.createAnim("res/lightning_hor.png", 128, 64, 0, 0,
        scalex, scaley)
    lightning:newSequence("default", {1, 4}, 5, 2)
    return lightning
end

local function playHorLightning(sx, sy, dx, dy)
    sx, sy = tileToPos(sx, sy)
    dx, dy = tileToPos(dx, dy)
    local scalex = (math.abs(dx - sx)) / 128
    local scaley = 0.25
    local lightning = loadHorLightning(scalex, scaley)
    lightning.x = (dx - sx) / 2 + sx
    lightning.y = sy
    lightning:play("default", 5, 2, function () lightning:remove() end)
end

local function loadVerLightning(scalex, scaley)
    local lightning = RNFactory.createAnim("res/lightning_ver.png", 64, 128, 0, 0,
        scalex, scaley)
    lightning:newSequence("default", {1, 4}, 5, 2)
    return lightning
end

local function playVerLightning(sx, sy, dx, dy)
    sx, sy = tileToPos(sx, sy)
    dx, dy = tileToPos(dx, dy)
    local scalex = 0.25 
    local scaley = (math.abs(dy - sy)) / 128
    local lightning = loadVerLightning(scalex, scaley)
    lightning.x = sx
    lightning.y = (dy - sy) / 2 + sy
    lightning:play("default", 5, 2, function () lightning:remove() end)
end

local function getSelectTile(px, py)
    local x = math.floor((px - Pannel.start_x) / Egg.WIDTH)
    local y = math.floor((py - Pannel.start_y) / Egg.HEIGHT)
    return x, y
end

local function getEgg(x, y)
    return Pannel.eggs[x + y * Pannel.width + 1]
end

local function isValidEgg(x, y)
    local egg = getEgg(x, y)
    return egg.image ~= nil
end

local function removeEgg(x, y)
    local egg = getEgg(x, y)
    local image = egg.image
    Pannel.tran:run(image, { type = "scale", xScale = -1, yScale = -1, time = 500, 
        onComplete = function () image:remove() end })
    egg.image = nil
end

local function isValidTile(x, y)
    return x >= Pannel.start_x and y >= Pannel.start_y and
        x < Pannel.width * Egg.WIDTH + Pannel.start_x and
        y < Pannel.height * Egg.HEIGHT + Pannel.start_y
end

local function playLightning(routes)
    for i = 1, #routes - 2, 2 do
        local sx = routes[i]
        local sy = routes[i + 1]
        io.write(string.format("(%d, %d),", sx, sy))
        if i + 3 <= #routes then
            local dx = routes[i + 2]
            local dy = routes[i + 3]
            io.write(string.format("(%d, %d),", dx, dy))
            if sx == dx then
                playVerLightning(sx, sy, dx, dy)
            elseif sy == dy then
                playHorLightning(sx, sy, dx, dy)
            end
        end
    end
    io.write("----------------\n")
end

local function redraw()
    for i = 1, #Pannel.eggs, 1 do
        local egg = Pannel.eggs[i]
        if egg.image then egg.image:remove() end
    end
    Pannel.eggs = {}
    PannelData.each(function (x, y, val)
        if val < 0 then 
            table.insert(Pannel.eggs, {})
        else
            local egg = Egg.create(val)
            egg.image.x, egg.image.y = tileToPos(x, y)
            table.insert(Pannel.eggs, egg)
        end
    end)
end

local function onClick(x, y)
    if not isValidTile(x, y) then
        return 
    end
    x, y = getSelectTile(x, y)
    if not isValidEgg(x, y) then return end
    local cx = x * Egg.WIDTH + Pannel.start_x + Egg.WIDTH / 2
    local cy = y * Egg.HEIGHT + Pannel.start_y + Egg.HEIGHT / 2
    Pannel.cursor.x = cx
    Pannel.cursor.y = cy
    Pannel.cursor.visible = true

    if Pannel.selected == 0 then
        Pannel.sx = x
        Pannel.sy = y
        Pannel.selected = 1
    elseif Pannel.selected == 1 then
        local routes = PannelData.tryConnect(Pannel.sx, Pannel.sy, x, y)
        if not routes then
            Pannel.sx = x
            Pannel.sy = y
            Pannel.selected = 1
        else
            Pannel.selected = 0
            removeEgg(Pannel.sx, Pannel.sy)
            removeEgg(x, y)
            hideHand()
            Pannel.cursor.visible = false
            playLightning(routes)
            PannelData.afterConnect(Pannel.sx, Pannel.sy, x, y, redraw)
            if PannelData.isDone() then
                PannelData.generate()
                redraw()
            end
        end
    end
end

local function onTouch(event)
    if event.phase == "began" then -- mouse down
        onClick(event.x, event.y)
    end
end

function Pannel.create()
    Pannel.cursor = loadCursor()
    Pannel.hand1 = loadHintAnim()
    Pannel.hand2 = loadHintAnim()
    PannelData.init(Egg.MAX - 1, Pannel.width, Pannel.height)
    PannelData.generate()
    redraw()
    RNListeners:addEventListener("touch", onTouch)
end

local function showHand(hand, tx, ty)
    local x, y
    x, y = tileToPos(tx, ty)
    hand.x = x
    hand.y = y - 50
    hand.visible = true
end

function Pannel.playHint()
    local hint = PannelData.hint()
    showHand(Pannel.hand1, hint[1], hint[2])
    showHand(Pannel.hand2, hint[3], hint[4])
end

