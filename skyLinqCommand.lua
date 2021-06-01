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

function skyLinqCommand.toArray(current,selector)
    local result
    if(type(selector) == "function") then
        result = {}
        for key, value in pairs(current) do
            table.insert(result,selector(key,value))
        end
    else
        result = current
    end
    return result
end

function skyLinqCommand.toDictionary(current,selector)
    local result
    if(type(selector) == "function") then
        result = {}
        for key, value in pairs(current) do
            local newKey,newValue = selector(key,value)
            result[newKey] = newValue
        end
    else
        result = current
    end
    return result
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
        if curComparator(v) then
            if type(i) == "number" then
                table.insert(result, v)
            else
                result[i] = v
            end
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
        if curComparator(k,v) then
            if type(k) == "number" then
                table.insert(result, v)
            else
                result[k] = v
            end
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
        error("The Select's getter is not a function")
    end
    for k, v in pairs(current) do
        if type(k) == "number" then
            table.insert(result, curGetter(v))
        else
            result[k] = curGetter(v)
        end
    end
    return result
end

function skyLinqCommand.selectDictionary(current, getter)
    local result = {}
    local curGetter;
    if type(getter) == "function" then
        curGetter = getter
    else
        error("The Select's getter is not a function")
    end
    for k, v in pairs(current) do
        if type(k) == "number" then
            table.insert(result, curGetter(k,v))
        else
            result[k] = curGetter(k,v)
        end
    end
    return result
end



function skyLinqCommand.orderby(current, comparator)
    local result = {}
    for index, value in pairs(current) do
        if type(index) == "number" then
            table.insert(result,value)
        else
            result[index] = value
        end
    end
    local curComparator
    if type(comparator) == "function" then
        curComparator = comparator
    else
        curComparator = function(a,b)
            return a < b
        end
    end
    skyLinqInner.mergeSort(result,curComparator)
    return result
end

function skyLinqCommand.orderbyDescending(current, comparator)
    local result = {}
    for index, value in pairs(current) do
        if type(index) == "number" then
            table.insert(result,value)
        else
            result[index] = value
        end
    end
    local curComparator
    if type(comparator) == "function" then
        curComparator = function(a,b)
            return not comparator(a,b)
        end
    else
        curComparator = function(a,b)
            return a > b
        end
    end
    skyLinqInner.mergeSort(result,curComparator)
    return result
end


return skyLinqCommand