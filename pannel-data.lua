--
-- pannel-data.lua
-- algorithm: http://apps.hi.baidu.com/share/detail/34225502
-- Kevin Lynx
-- 3.13.2012
-- 
PannelData = {}

local function value(x, y)
    return PannelData.area[y * PannelData.width + x + 1]
end

local function setValue(x, y, val)
    PannelData.area[y * PannelData.width + x + 1] = val
end

local function getHorLine(x, y)
    local line = { x }
    for i = x - 1, 0, -1 do
        if value(i, y) < 0 then
            line[#line + 1] = i
        else
            break
        end
    end
    for i = x + 1, PannelData.width - 1, 1 do
        if value(i, y) < 0 then
            line[#line + 1] = i
        else
            break
        end
    end
    return line
end

local function getVerLine(x, y)
    local line = { y }
    for i = y - 1, 0, -1 do
        if value(x, i) < 0 then
            line[#line + 1] = i
        else
            break
        end
    end
    for i = y + 1, PannelData.height - 1, 1 do
        if value(x, i) < 0 then
            line[#line + 1] = i
        else
            break
        end
    end
    return line
end

local function intersect(t1, t2)
    local ret = {}
    for i = 1, #t1, 1 do
        for j = 1, #t2, 1 do
            if t1[i] == t2[j] then
                ret[#ret + 1] = t1[i]
                break
            end
        end
    end
    return ret
end

local function hasRoute(line1, line2, min, max, hor)
    local inter = intersect(line1, line2)
    if #inter == 0 then return nil end
    for i = 1, #inter, 1 do
        local empty = true
        local pos = inter[i]
        for j = min + 1, max - 1, 1 do
            if hor then -- [min, max] represents y coordinate
                if value(pos, j) >= 0 then 
                    empty = false 
                    break
                end
            else
                if value(j, pos) >= 0 then
                    empty = false
                    break
                end
            end
        end
        if empty then -- got a route
            return pos
        end
    end
    return nil
end

local function routePoints(sx, sy, dx, dy, points)
    local add_src = true
    local add_dest = true
    for i = 1, #points - 1, 2 do
        if points[i] == sx and points[i + 1] == sy then
            add_src = false
        end
        if points[i] == dx and points[i + 1] == dy then
            add_dest = false
        end
    end
    if add_src then
        table.insert(points, 1, sx)
        table.insert(points, 2, sy)
    end
    if add_dest then
        table.insert(points, dx)
        table.insert(points, dy)
    end
    return points
end

local function checkHorLine(sx, sy, dx, dy)
    if sy == dy then return nil end -- checkVerLine is better in this situaiton
    local line1 = getHorLine(sx, sy)
    local line2 = getHorLine(dx, dy)
    local route = hasRoute(line1, line2, math.min(sy, dy), math.max(sy,dy), true)
    if route then
        return routePoints(sx, sy, dx, dy, { route, sy, route, dy })
    end
    return nil
end

local function checkVerLine(sx, sy, dx, dy)
    if sx == dx then return nil end -- checkHorLine is better
    local line1 = getVerLine(sx, sy)
    local line2 = getVerLine(dx, dy)
    local route = hasRoute(line1,line2, math.min(sx, dx), math.max(sx, dx), false)
    if route then
        return routePoints(sx, sy, dx, dy, { sx, route, dx, route })
    end
    return nil
end

function PannelData.init(max, w, h)
    PannelData.max_value = max
    PannelData.width = w
    PannelData.height = h
    PannelData.remain = 0
    PannelData.area = {} -- [1, max]
    return w * h % 2 == 0
end

-- return the connect routes if can be connected, otherwise return nil
function PannelData.tryConnect(sx, sy, dx, dy)
    -- invalid argument
    if sx == dx and sy == dy then return nil end
    -- not the same type
    if value(sx, sy) ~= value(dx, dy) then return nil end
    return checkHorLine(sx, sy, dx, dy) or checkVerLine(sx, sy, dx, dy)
end

local function checkValidate(validate)
    if not PannelData.hint() then
        print("validate the pannel data")
        PannelData.validate()
        validate()
    end
end

function PannelData.afterConnect(sx, sy, dx, dy, validate)
    -- do not use nil, that will change #area value
    setValue(sx, sy, -1)
    setValue(dx, dy, -1)
    PannelData.remain = PannelData.remain - 2
    if PannelData.remain > 0 then
        checkValidate(validate)
    end
end

function PannelData.isDone()
    return PannelData.remain == 0
end

function PannelData.generate()
    local count = PannelData.width * PannelData.height
    for i = 1, count - 1, 2 do
        local val = math.random(PannelData.max_value)
        PannelData.area[i] = val
        PannelData.area[i + 1] = val
    end
    PannelData.remain = count
    PannelData.validate()
end

function PannelData.validate(try)
    try = try or 20 
    for i = 0, try, 1 do
        PannelData.mess()
        if PannelData.hint() then return true end
    end
    return false
end

function PannelData.mess()
    local try_times = 2 * (PannelData.width + PannelData.height)
    local count = PannelData.width * PannelData.height
    for i = 0, try_times, 1 do
        local p1 = math.random(count - 1) + 1
        local p2 = math.random(count - 1) + 1
        -- swap them
        PannelData.area[p1], PannelData.area[p2] = PannelData.area[p2], PannelData.area[p1]
    end
end

function PannelData.each(fn)
    local w = PannelData.width
    local h = PannelData.height
    for y = 0, h - 1, 1 do
        for x = 0, w - 1, 1 do
            fn(x, y, value(x, y))
        end
    end
end

local function getConnect(sx, sy)
    local w = PannelData.width
    local h = PannelData.height
    for y = 0, h - 1, 1 do
        for x = 0, w - 1, 1 do
            if value(x, y) == value(sx, sy) and not (sx == x and sy == y) then
                local routes = PannelData.tryConnect(sx, sy, x, y)
                if routes then return { x, y, sx, sy } end
            end
        end
    end
    return nil
end

function PannelData.hint()
    local w = PannelData.width
    local h = PannelData.height
    for y = 0, h - 1, 1 do
        for x = 0, w - 1, 1 do
            if value(x, y) >= 0 then
                local conn = getConnect(x, y)
                if conn then return conn end
            end
        end
    end
    return nil
end

function PannelData.dump()
    local w = PannelData.width
    local h = PannelData.height
    for y = 0, h - 1, 1 do
        for x = 0, w - 1, 1 do
            local val = value(x, y)
            if val >= 0 then
                io.write(string.format("%2d, ", value(x, y)))
            else
                io.write("  , ")
            end
        end
        io.write("\n")
    end
end

function PannelData.test()
    PannelData.init(2, 4, 4)
    PannelData.generate()
    PannelData.dump()
end

function PannelData.dumpArea()
    for i = 1, #PannelData.area, 1 do
        local val = PannelData.area[i]
        if val then
            io.write(string.format("%2d, ", val))
        else
            io.write("  ")
        end
    end
    io.write("\n")
end

function PannelData.tryAndDump(sx, sy, dx, dy)
    local routes = PannelData.tryConnect(sx, sy, dx, dy)
    if not routes then
        print("can NOT connect")
        return
    end
    PannelData.afterConnect(sx, sy, dx, dy)
    for i = 1, #routes - 1, 2 do
        io.write(string.format("(%d, %d), ", routes[i], routes[i + 1]))
    end
    io.write("\n")
    PannelData.dump()
end

function PannelData.autoTryAndDump()
    if not PannelData.isDone() then
        local pts = PannelData.hint()
        PannelData.tryAndDump(pts[1], pts[2], pts[3], pts[4])
    else
        print('done')
    end
end

