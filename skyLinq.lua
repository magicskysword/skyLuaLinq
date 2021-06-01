local pairs = pairs

local skyLinqInner = {}

function skyLinqInner.mergeSort(t,comparator)
    local len = 0
    local a = t
    local b = {}
    for index, value in ipairs(t) do
        len = len + 1
        b[index] = 0
    end

    local seg  = 1
    while seg <= len do
        local start = 1
        while start <= len do
            local low = start
            local mid = math.min(start + seg, len)
            local high =  math.min(start + seg + seg, len+1)
            local k = low
            local start1 = low
            local end1 = mid
            local start2 = mid
            local end2 = high
            while start1 < end1 and start2 < end2 do
                if comparator(a[start1],a[start2]) then
                    b[k] = a[start1]
                    start1 = start1 + 1
                else
                    b[k] = a[start2]
                    start2 = start2 + 1
                end
                k = k + 1
            end
            while start1 < end1 do
                b[k] = a[start1];
                k = k + 1
                start1 = start1 + 1
            end
            while start2 < end2 do
                b[k] = a[start2];
                k = k + 1
                start2 = start2 + 1
            end
            start = start + seg + seg
        end
        a,b = b,a
        seg = seg + seg
    end
end

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



---@field linqCommand skyLinqCommand[]
---@field source table
---@class Linq
local skyLinq = { }
local skyLinqMateTable = {
    __linqFlag = true,
    __index = skyLinq,
    __pairs = function(o)
        return pairs(o:run())
    end
}

---* create a linq query
---@param source table
---@return Linq
function skyLinq.from(source)
    assert(type(source) == "table","source is not a table.")
    local o
    if source["__linqFlag"] then
        o = {
            source = rawget(source,"source"),
            linqCommand = {},
        }
        ---@param value skyLinqCommand
        for key, value in pairs(rawget(source,"linqCommand")) do
            addCommand(o,skyLinqCommand.create(value.func,table.unpack(value.param)))
        end
    else
        o = {
            source = source,
            linqCommand = {},
        }
    end

    setmetatable(o,skyLinqMateTable)
    return o
end

---* Add a command to linq
---@param func function
local function addCommand(self,command)
    table.insert(self.linqCommand,command)
end

---* Run all command and return result
---* If you want a fixed result,you must run this function
---@return table
function skyLinq:run()
    local result = self.source
    for key, value in pairs(self.linqCommand) do
        result = value.func(result,table.unpack(value.param))
    end
    return result
end

---* Trans a table to array table
---@generic TKey
---@generic TValue
---@generic TNewValue
---@param selector fun(key : TKey,value : TValue) : TNewValue such as function(key,value) return value end
---@return Linq
function skyLinq:toArray(selector)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.toArray,selector))
    return self
end

---* Trans a table to hash table
---** The selector has two returned value
---@generic TKey
---@generic TValue
---@generic TNewKey
---@generic TNewValue
---@param selector fun(key : TKey,value : TValue) : TNewKey,TNewValue such as function(key,value) return key,value end
---@return Linq
function skyLinq:toDictionary(selector)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.toDictionary,selector))
    return self
end

---* Select the value that passed the comparator
---* If comparator is function,the value will be used as the parameter
---* If comparator is table,the value will be compare to all value from the table
---* Else the value will be compare to the comparator
---@generic TValue
---@param comparator fun(value : TValue):boolean such as function(value) return value > 0 end
---@param comparator table
---@param comparator any
---@return Linq
function skyLinq:where(comparator)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.where,comparator))
    return self
end

---* Select the key and value that passed the comparator
---* If comparator is function,the key and value will be used as the parameter
---* If comparator is table,the value will be compare to all value from the table
---* Else the value will be compare to the comparator
---@generic TKey
---@generic TValue
---@param comparator fun(key : TKey,value : TValue):boolean such as function(key,value) return key > 5 and value > 0 end
---@param comparator table
---@param comparator any
---@return Linq
function skyLinq:whereDictionary(comparator)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.whereDictionary,comparator))
    return self
end

---* Select some value from value in table
---@generic TValue
---@generic TNewValue
---@param comparator fun(value : TValue):TNewValue such as function(value) return value.name end
---@return Linq
function skyLinq:select(getter)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.select,getter))
    return self
end

---* Select some value from key and value in table
---@generic TKey
---@generic TValue
---@generic TNewValue
---@param comparator fun(key : TKey,value : TValue):TNewValue such as function(key,value) return {id = key,name = value} end
---@return Linq
function skyLinq:selectDictionary(getter)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.selectDictionary,getter))
    return self
end

---* Sort value in array
---* In comparator,if compare a and b is true,a will go in front of b
---@generic TValue
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a < b end
---@return Linq
function skyLinq:orderby(comparator)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.orderby,comparator))
    return self
end

---* Sort value in array descending
---* In comparator,if compare a and b is true,a will go in back of b
---@generic TValue
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a < b end
---@return Linq
function skyLinq:orderbyDescending(comparator)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.orderbyDescending,comparator))
    return self
end

return skyLinq