--
-- main.lua
-- Kevin Lynx
-- 3.14.2012
--
require("object")
require("utils")
require("rapanui-sdk/rapanui")
require("egg")
require("pannel-data")
require("pannel")
require("button")
require("floatcloud")
require("mainui")
require("preface")

-- director has many bugs right now
local director = RNDirector:new()
local listener = nil

local function onTouch(event)
    if event.phase == "began" and not director:isTransitioning() then
        director:showScene("mainui", "pop")
        RNListeners:removeEventListener("touch", listener)
    end
end

function setWindowSize()
    local view = RNFactory.screen.viewport
    local sizes = config.sizes[config.device]
    view:setSize(sizes[3], sizes[4])
    view:setScale(sizes[1], -sizes[2])
end

function init()
    setWindowSize()
    math.randomseed(os.time())
    director:addScene("preface")
    director:addScene("mainui")
    director:setTime(1000)
    director:showScene("preface", "pop")
    listener = RNListeners:addEventListener("touch", onTouch)
end

init()

