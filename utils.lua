--
-- utils.lua
-- Kevin Lynx
-- 3.17.2012
--
Utils = {}

function Utils.fixTextPos(textbox, x, y, text)
    local left, right, top, bottom, width, height
    left, top, right, bottom = textbox:getStringBounds(1, string.len(text))
    width = (right - left) / 2 
    height = (bottom - top) / 2
    textbox:setRect(x - width, y - height, x + width + 1, y + height)
end
