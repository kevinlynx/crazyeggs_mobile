--[[
--
-- RapaNui
--
-- by Ymobe ltd  (http://ymobe.co.uk)
--
-- LICENSE:
--
-- RapaNui uses the Common Public Attribution License Version 1.0 (CPAL) http://www.opensource.org/licenses/cpal_1.0.
-- CPAL is an Open Source Initiative approved
-- license based on the Mozilla Public License, with the added requirement that you attribute
-- Moai (http://getmoai.com/) and RapaNui in the credits of your program.
]]

RNTransition = {}

RNTransition.MOVE = "move"
RNTransition.ROTATE = "rotate"
RNTransition.SCALE = "scale"
RNTransition.ALPHA = "alpha"

-- Create a New Transition Object

function RNTransition:new(o)
    o = o or {
        name = ""
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

mainSprite = nil

function RNTransition:run(target, params)

    local toX = target.x
    local toY = target.y

    local xScale = 0
    local yScale = 0

    local time = 1
    local delay = 1
    local type = ""
    local alpha = -1
    local angle = 0
    local mode = MOAIEaseType.SMOOTH

    if (params.type ~= nil) then
        type = params.type
    end

    if (params.x ~= nil) then
        toX = params.x
    end

    if (params.y ~= nil) then
        toY = params.y
    end

    if (params.xScale ~= nil) then
        xScale = params.xScale
    end

    if (params.yScale ~= nil) then
        yScale = params.yScale
    end

    if (params.time ~= nil) then
        time = params.time / 1000
    else
        time = 1
    end

    if (params.delay ~= nil) then
        delay = params.delay / 1000
    else
        delay = 0
    end

    if (params.alpha ~= nil) then
        alpha = params.alpha
    end

    if (params.angle ~= nil) then
        angle = params.angle
    end

    if (params.mode ~= nil) then
        mode = params.mode
    end

    local action

    if (type == RNTransition.MOVE) then
        local px, py

        if target:getType() == "RNObject" then
            px, py = target:getProp():getLoc()
        elseif target:getType() == "RNMap" then
            px, py = target:getLoc();
        end


        local deltax = self:getDelta(px, toX)
        local deltay = self:getDelta(py, toY)


        if (toX < px) then
            deltax = (-1) * deltax
        end

        if (toY < py) then
            deltay = (-1) * deltay
        end

        if target:getType() == "RNObject" then
            action = target:getProp():moveLoc(deltax, deltay, time)
        elseif target:getType() == "RNMap" then
            for key, prop in pairs(target:getAllProps()) do
                action = prop:moveLoc(deltax, deltay, time)
            end
        end
    end



    if (type == RNTransition.ROTATE) then
        if target:getType() == "RNObject" then
            action = target:getProp():moveRot(angle, time)
        elseif target:getType() == "RNMap" then
            for key, prop in pairs(target:getAllProps()) do
                action = prop:moveRot(angle, time)
            end
        end
    end

    if (type == RNTransition.ALPHA) then
        if target:getType() == "RNObject" then
            action = target:getProp():seekColor(alpha, alpha, alpha, alpha, time, mode)
        elseif target:getType() == "RNMap" then
            for key, prop in pairs(target:getAllProps()) do
                action = prop:seekColor(alpha, alpha, alpha, alpha, time, mode)
            end
        end
    end


    if (type == RNTransition.SCALE) then
        if target:getType() == "RNObject" then
            action = target:getProp():moveScl(xScale, yScale, time, mode)
        elseif target:getType() == "RNMap" then
            for key, prop in pairs(target:getAllProps()) do
                action = prop:moveScl(xScale, yScale, time, mode)
            end
        end
    end

    if (params.onComplete ~= nil and action ~= nil) then
        action:setListener(MOAIAction.EVENT_STOP, function() self.updateMapLoc(self, target, toX, toY) params.onComplete(target) end)
    elseif (action ~= nil) then
        action:setListener(MOAIAction.EVENT_STOP, function() self.updateMapLoc(self, target, toX, toY) end)
    end
end

function RNTransition:updateMapLoc(target, x, y)
    if target:getType() == "RNMap" then
        target.mapx = x
        target.mapy = y
    end
end

function RNTransition:getDelta(a, b)
    if (a > b) then
        return a - b
    else
        return b - a
    end
end

return RNTransition