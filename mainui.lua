--
-- mainui.lua
-- Kevin Lynx
-- 3.16.2012
--
MainUI = {}

MainUI.sceneGroup = RNGroup:new()

local function onClickHint(button)
    Pannel.playHint()
end

local function onTouch(event)
    if event.phase == "began" then 
        MainUI.hint:onTouchDown(event.x, event.y)
    elseif event.phase == "ended" then
        MainUI.hint:onTouchUp(event.x, event.y)
    end
end

local function loadBackground()
    local back = RNFactory.createImage("res/sky.jpg", { parentGroup = parent, left = 0, top = 0 })
    local image = RNFactory.createImage("res/floatisland.png", { parentGroup = parent, left = 0, top = 0 })
    back:setLevel(0)
    image:setLevel(2)
    image:setAlpha(0.8)
end

function MainUI.create(parent)
    RNFactory.createImage("res/infopannel.png", { parentGroup = parent, left = 0, top = 0 })
    loadBackground()
    MainUI.hint = Button:new("HINT", 610, 350, onClickHint, parent)
    RNListeners:addEventListener("touch", onTouch)
end

local last_update = os.clock()
local function updateFrame()
    local now = os.clock()
    Cloud.loop((now - last_update) * 1000)
    last_update = now
end

function MainUI.onCreate()
    local sceneGroup = MainUI.sceneGroup
    Pannel.create(sceneGroup)
    MainUI.create(sceneGroup)
    RNListeners:addEventListener("enterFrame", updateFrame)
    return sceneGroup
end

function MainUI.onEnd()
end

return MainUI

