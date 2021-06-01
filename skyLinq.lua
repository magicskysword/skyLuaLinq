local skyLinqCommand = require("skyLinqCommand")
local pairs = pairs

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
    assert(not source["__linqFlag"],"source is a linq object.")
    local o = {
        source = source,
        linqCommand = {},
    }
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