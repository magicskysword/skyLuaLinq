local skyLinqInner = require("skyLinqInner")

---@field func function
---@field param table
---@class skyLinqCommand
local skyLinqCommand = {}

function skyLinqCommand.create(func, ...)
    local command = {
        func = func,
        param = { ... }
    }
    return command
end

function skyLinqCommand.where(current, comparator)
    local result = {}
    local curComparator;
    if type(comparator) == "function" then
        curComparator = comparator
    elseif type(comparator) == "table" then
        curComparator = function(o)
            for i, v in ipairs(comparator) do
                if v == o then
                    return true
                end
            end
            return false
        end
    else
        curComparator = function(o)
            return comparator == o
        end
    end
    for i, v in ipairs(current) do
        if (curComparator(v)) then
            table.insert(result, v);
        end
    end
    return result
end

function skyLinqCommand.whereDictionary(current, comparator)
    local result = {}
    local curComparator;
    if type(comparator) == "function" then
        curComparator = comparator
    elseif type(comparator) == "table" then
        curComparator = function(o)
            for i, v in pairs(comparator) do
                if v == o then
                    return true
                end
            end
            return false
        end
    else
        curComparator = function(k,v)
            return comparator == v
        end
    end
    for k, v in pairs(current) do
        if (curComparator(k,v)) then
            result[k] = v
        end
    end
    return result
end

function skyLinqCommand.select(current, getter)
    local result = {}
    local curGetter;
    if type(getter) == "function" then
        curGetter = getter
    else
        curGetter = function(o)
            return o
        end
    end
    for k, v in pairs(current) do
        table.insert(result,curGetter(v))
    end
    return result
end

function skyLinqCommand.selectDictionary(current, getter)
    local result = {}
    local curGetter;
    if type(getter) == "function" then
        curGetter = getter
    else
        curGetter = function(k,o)
            return o
        end
    end
    for k, v in pairs(current) do
        result[k] = curGetter(k,v)
    end
    return result
end



function skyLinqCommand.orderby(current, minFunc)
    local result = {}
    for index, value in ipairs(current) do
        result[index] = value
    end
    local curMinFunc
    if type(minFunc) == "function" then
        curMinFunc = minFunc
    else
        curMinFunc = function(a,b)
            return a < b and a or b
        end
    end
    skyLinqInner.mergeSort(result,curMinFunc)
    return result
end

function skyLinqCommand.orderbyDescending(current, minFunc)
    local result = {}
    for index, value in ipairs(current) do
        result[index] = value
    end
    local curMaxFunc
    if type(minFunc) == "function" then
        curMaxFunc = function(a,b)
            return minFunc(a,b) == a and b or a
        end
    else
        curMaxFunc = function(a,b)
            return a < b and b or a
        end
    end
    skyLinqInner.mergeSort(result,curMaxFunc)
    return result
end


return skyLinqCommand