--
-- preface.lua
-- Kevin Lynx
-- 3.17.2012
--
Preface = {}
Preface.sceneGroup = RNGroup:new()

function Preface.onCreate()
    local w = config.sizes[config.device][3]
    Preface.background = RNFactory.createImage("res/MAINback.jpg", { paraentGroup = Preface.sceneGroup, top = 0, left = 0 })
    local text = "Touch to play"
    Preface.text = RNFactory.createText(text, { size = 10, parentGroup = Preface.sceneGroup, top = 0, left = 0,
        font = "res/arial-rounded", width = 300, height = 30 })
    Utils.fixTextPos(Preface.text.textbox, w / 2, 400, text)
    return Preface.sceneGroup
end

function Preface.onEnd()
    Preface.background:remove()
    Preface.text:remove()
end

return Preface

