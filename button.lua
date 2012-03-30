--
-- button.lua
-- Kevin Lynx
-- 3.16.2012
--
Button = {}

local function loadImage(name, x, y, parent)
    local image = RNFactory.createImage(name, { top = y, left = x, parentGroup = parent })
    image:bringToFront()
    return image
end

local function getBoundRect(button)
    local image = button.normal_img
    local halfW = image.originalWidth / 2
    local halfH = image.originalHeight / 2
    return image.x - halfW, image.y - halfH, image.x + halfW, image.y + halfH
end

local function intersect(x, y, button)
    local left, right, top, bottom
    left, top, right, bottom = getBoundRect(button)
    return x >= left and x < right and y >= top and y < bottom
end

local function fixTextPos(button, xoff, yoff)
    xoff = xoff or 0
    yoff = yoff or 0
    local textbox = button.text_inst.textbox
    local left, right, top, bottom, width, height
    left, top, right, bottom = textbox:getStringBounds(1, string.len(button.text))
    width = right - left
    height = bottom - top
    left, top, right, bottom = getBoundRect(button)
    left, top = left + (right - left - width) / 2, top + (bottom - top - height) / 2
    textbox:setRect(left + xoff, top + yoff, left + width + xoff, top + height + yoff)
end

function Button:new(text, x, y, onclick, parent)
    local obj = {
        text = text,
        onclick = onclick,
        normal_img = nil,
        text_inst = nil,
        hover_img = nil,
    }
    obj = newObject(obj, Button)
    obj.normal_img = loadImage("res/stonebutton_i.png", x, y, parent)
    obj.hover_img = loadImage("res/stonebutton_n.png", x, y, parent)
    obj.hover_img.visible = false
    obj.text_inst = RNFactory.createText(obj.text, { size = 10, top = y, left = x, 
        parentGroup = parent, 
        font = "res/arial-rounded", width = obj.normal_img.originalWidth,
        height = obj.normal_img.originalHeight })
    obj.text_inst.textbox:setAlignment(MOAITextBox.CENTER_JUSTIFY)
    fixTextPos(obj)
    return obj
end

function Button:onTouchDown(x, y)
    if intersect(x, y, self) then
        self.normal_img.visible = false
        self.hover_img.visible = true
        fixTextPos(self, 2, 2)
    end
end

function Button:onTouchUp(x, y)
    if intersect(x, y, self) then
        self.normal_img.visible = true
        self.hover_img.visible = false
        fixTextPos(self, -2, -2)
        if self.onclick then
            self.onclick(self)
        end
    end
end

