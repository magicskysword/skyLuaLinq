local pairs = pairs
local ipairs = ipairs
local unpack = table.unpack

local skyLinqInner = {}

function skyLinqInner.mergeSort(t,comparator)
    local len = 0
    local a = {}
    local b = {}
    for index, value in ipairs(t) do
        len = len + 1
        a[index] = value
        b[index] = 0
    end
    local result = a

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
    return a
end

function skyLinqInner.defaultComparator(a,b)
    return a <= b
end

function skyLinqInner.defaultComparatorDescending(a,b)
    return a >= b
end



---@field func function
---@field params table
---@class skyLinqCommand
local skyLinqCommand = {}
local skyLinqCommandMateTable = {
    __linqFlag = true,
    __index = skyLinqCommand,
}

function skyLinqCommand.create(func, ...)
    local command = {
        func = func,
        params = { ... }
    }
    setmetatable(command,skyLinqCommandMateTable)
    return command
end

function skyLinqCommand:run(current)
    return self.func(current,unpack(self.params))
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
            for index, value in ipairs(comparator) do
                if value == o then
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
    for index, value in ipairs(current) do
        if curComparator(value) then
            if type(index) == "number" then
                table.insert(result, value)
            else
                result[index] = value
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
            for index, value in pairs(comparator) do
                if value == o then
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



function skyLinqCommand.orderBy(current, comparator)
    local result
    local curComparator
    if type(comparator) == "function" then
        curComparator = comparator
    else
        curComparator = skyLinqInner.defaultComparator
    end
    result = skyLinqInner.mergeSort(current,curComparator)
    return result
end

function skyLinqCommand.orderByDescending(current, comparator)
    local result
    local curComparator
    if type(comparator) == "function" then
        curComparator = function(a,b)
            return not comparator(a,b)
        end
    else
        curComparator = skyLinqInner.defaultComparatorDescending
    end
    result = skyLinqInner.mergeSort(current,curComparator)
    return result
end

function skyLinqCommand.max(current,getter,comparator)
    local curGetter
    local curComparator
    if type(getter) == "function" then
        curGetter = getter
    else
        curGetter = function(value)
            return value
        end
    end
    if type(comparator) == "function" then
        curComparator = comparator
    else
        curComparator = skyLinqInner.defaultComparator
    end
    local maxValue = nil
    local curValue
    for key, value in pairs(current) do
        curValue = curGetter(value)
        if maxValue == nil or curComparator(maxValue,curValue)  then
            maxValue = curValue
        end
    end
    return maxValue
end

function skyLinqCommand.min(current,getter,comparator)
    local curGetter
    local curComparator
    if type(getter) == "function" then
        curGetter = getter
    else
        curGetter = function(value)
            return value
        end
    end
    if type(comparator) == "function" then
        curComparator = comparator
    else
        curComparator = skyLinqInner.defaultComparator
    end
    local minValue = nil
    local curValue
    for key, value in pairs(current) do
        curValue = curGetter(value)
        if minValue == nil or not curComparator(minValue,curValue)  then
            minValue = curValue
        end
    end
    return minValue
end

function skyLinqCommand.first(current,defaultValue,getter)
    local curGetter
    if type(getter) == "function" then
        curGetter = getter
    else
        curGetter = function(index,value)
            return value
        end
    end
    for index, value in ipairs(current) do
        return curGetter(index,value)
    end
    return defaultValue
end

function skyLinqCommand.last(current,defaultValue,getter)
    local result = defaultValue
    local curGetter
    if type(getter) == "function" then
        curGetter = getter
    else
        curGetter = function(index,value)
            return value
        end
    end
    for index, value in ipairs(current) do
        result = curGetter(index,value)
    end
    return result
end

---@field last Linq
---@field command skyLinqCommand
---@field source table
---@class Linq
local skyLinq = { }
local skyLinqMateTable = {
    __linqFlag = true,
    __index = skyLinq,
    __pairs = function(o)
        return pairs(o:run())
    end,
    __ipairs = function(o)
        return ipairs(o:run())
    end
}

local function isLinqObject(object)
    return object["__linqFlag"] == true
end

---@return Linq
local function createLinq(lastLinq)
    local o = {
        lastLinq = lastLinq,
        source = nil,
        command = nil,
        isGroupBy = false,
        isThenBy = false
    }
    setmetatable(o,skyLinqMateTable)
    return o
end

---* create a linq query
---@param source table
---@return Linq
function skyLinq.from(source)
    assert(type(source) == "table","source is not a table.")
    local o
    if isLinqObject(source) then
        o = createLinq(source)
    else
        o = createLinq()
        o.source = source
    end

    setmetatable(o,skyLinqMateTable)
    return o
end

---* Add a command to linq
---@param last Linq
---@param command skyLinqCommand
local function addCommand(last,command)
    local newLinq = createLinq(last)
    newLinq.command = command
    return newLinq
end

---* insert current command before last groupBy or thenBy linq
---@param last Linq
---@param command skyLinqCommand
local function insertThenByCommand(last,command)
    assert(last.isGroupBy,"Can't find GroupBy linq")
    local newLinq = createLinq()
    newLinq.command = command
    newLinq.isThenBy = true
    local findLinq = last
    while findLinq ~= nil and findLinq.lastLinq ~= nil do
        if findLinq.lastLinq.isThenBy then
            findLinq = findLinq.lastLinq
            break
        else
            newLinq.lastLinq = findLinq.lastLinq
            findLinq.lastLinq = newLinq
        end
    end
    return last
end

---* Run all command and return result
---* If you want a fixed result,you must run this function
---@return table
function skyLinq:run()
    local current
    local result
    if self.lastLinq ~= nil then
        current = self.lastLinq:run()
    end
    if self.command ~= nil then
        result = self.command:run(current)
    else
        result = self.source
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
    return addCommand(self,skyLinqCommand.create(skyLinqCommand.toArray,selector))
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
    return addCommand(self,skyLinqCommand.create(skyLinqCommand.toDictionary,selector))
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
    return addCommand(self,skyLinqCommand.create(skyLinqCommand.where,comparator))
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
    return addCommand(self,skyLinqCommand.create(skyLinqCommand.whereDictionary,comparator))
end

---* Select some value from value in table
---@generic TValue
---@generic TNewValue
---@param getter fun(value : TValue):TNewValue such as function(value) return value.name end
---@return Linq
function skyLinq:select(getter)
    return addCommand(self,skyLinqCommand.create(skyLinqCommand.select,getter))
end

---* Select some value from key and value in table
---@generic TKey
---@generic TValue
---@generic TNewValue
---@param getter fun(key : TKey,value : TValue):TNewValue such as function(key,value) return {id = key,name = value} end
---@return Linq
function skyLinq:selectDictionary(getter)
    return addCommand(self,skyLinqCommand.create(skyLinqCommand.selectDictionary,getter))
end

---* Sort value in array
---* In comparator,if a small or euqal then b,then return true
---* Warning:Please make sure that when a == b,the comparator return true,else the sort will be instability
---@generic TValue
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a <= b end
---@return Linq
function skyLinq:orderBy(comparator)
    local current = addCommand(self,skyLinqCommand.create(skyLinqCommand.orderBy,comparator))
    current.isGroupBy = true
    return current
end

---* Sort value in array descending
---* In comparator,if a small or euqal then b,then return true
---* Warning:Please make sure that when a == b,the comparator return true,else the sort will be instability
---@generic TValue
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a <= b end
---@return Linq
function skyLinq:orderByDescending(comparator)
    local current = addCommand(self,skyLinqCommand.create(skyLinqCommand.orderByDescending,comparator))
    current.isGroupBy = true
    return current
end

---* Sort value in array before groupBy
---* In comparator,if a small or euqal then b,then return true
---* Warning:Please make sure that when a == b,the comparator return true,else the sort will be instability
---@generic TValue
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a <= b end
---@return Linq
function skyLinq:thenBy(comparator)
    return insertThenByCommand(self,skyLinqCommand.create(skyLinqCommand.orderBy,comparator))
end

---* Sort value in array descending before groupBy
---* In comparator,if a small or euqal then b,then return true
---* Warning:Please make sure that when a == b,the comparator return true,else the sort will be instability
---@generic TValue
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a <= b end
---@return Linq
function skyLinq:thenByDescending(comparator)
    return insertThenByCommand(self,skyLinqCommand.create(skyLinqCommand.orderByDescending,comparator))
end

---* Get the max value in table
---* getter and comparator can be nil
---* if getter is nil,it will ues the value directly
---* if comparator is nil,it will use function(a,b) return a < b end
---* In comparator,if compare a and b is true,a will go in back of b
---@generic TValue
---@generic TNewValue
---@param getter fun(value : TValue):TNewValue such as function(value) return value.index end
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a < b end
---@return TNewValue
function skyLinq:max(getter,comparator)
    assert(type(self) == "table","get value is not a table.")
    if isLinqObject(self) then
        return skyLinqCommand.max(self:run(),getter,comparator)
    else
        return skyLinqCommand.max(self,getter,comparator)
    end
end

---* Get the min value in table
---* getter and comparator can be nil
---* if getter is nil,it will ues the value directly
---* if comparator is nil,it will use function(a,b) return a < b end
---* In comparator,if compare a and b is true,a will go in back of b
---@generic TValue
---@generic TNewValue
---@param getter fun(value : TValue):TNewValue such as function(value) return value.name end
---@param comparator fun(a : TValue,b : TValue):boolean such as function(a,b) return a < b end
---@return TNewValue
function skyLinq:min(getter,comparator)
    assert(type(self) == "table","get value is not a table.")
    if isLinqObject(self) then
        return skyLinqCommand.min(self:run(),getter,comparator)
    else
        return skyLinqCommand.min(self,getter,comparator)
    end
end

---* get the first value in array
---* it only search on array part
---* if getter is nil,it will ues the value directly
---@generic TValue
---@generic TNewValue
---@param defaultValue TNewValue
---@param getter fun(index : number,value : TValue):TNewValue such as function(key,value) return value.name end
---@return TNewValue
function skyLinq:first(defaultValue,getter)
    assert(type(self) == "table","get value is not a table.")
    if isLinqObject(self) then
        return skyLinqCommand.first(self:run(),defaultValue,getter)
    else
        return skyLinqCommand.first(self,defaultValue,getter)
    end
end

---* get the last value in array
---* it only search on array part
---* if getter is nil,it will ues the value directly
---@generic TValue
---@generic TNewValue
---@param defaultValue TNewValue
---@param getter fun(index : number,value : TValue):TNewValue such as function(key,value) return value.name end
---@return TNewValue
function skyLinq:last(defaultValue,getter)
    assert(type(self) == "table","get value is not a table.")
    if isLinqObject(self) then
        return skyLinqCommand.last(self:run(),defaultValue,getter)
    else
        return skyLinqCommand.last(self,defaultValue,getter)
    end
end

return skyLinq