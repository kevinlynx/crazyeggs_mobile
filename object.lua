--
-- object.lua
-- Kevin Lynx
-- 3.16.2012
--
local function newindex(self, key, value)
    getmetatable(self).__object[key] = value
end

local function index(self, key)
    return getmetatable(self).__object[key]
end

function newObject(o, class)
    class.__index = class
    setmetatable(o, class)
    return setmetatable({}, { __newindex = newindex, __index = index, __object = o })
end

