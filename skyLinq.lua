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
        return pairs(o:RunCommand())
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

---* add a command to linq
---@param func function
local function addCommand(self,command)
    table.insert(self.linqCommand,command)
end

---* run all command and return result
---@return table
function skyLinq:RunCommand()
    local result = self.source
    for key, value in pairs(self.linqCommand) do
        result = value.func(result,table.unpack(value.param))
    end
    return result
end

function skyLinq:ToArray()
    return self:RunCommand()
end

function skyLinq:where(comparator)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.where,comparator))
    return self
end

function skyLinq:whereDictionary(comparator)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.whereDictionary,comparator))
    return self
end

function skyLinq:select(getter)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.select,getter))
    return self
end

function skyLinq:selectDictionary(getter)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.selectDictionary,getter))
    return self
end

function skyLinq:orderby(minFunc)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.orderby,minFunc))
    return self
end

function skyLinq:orderbyDescending(minFunc)
    addCommand(self,skyLinqCommand.create(skyLinqCommand.orderbyDescending,minFunc))
    return self
end

return skyLinq