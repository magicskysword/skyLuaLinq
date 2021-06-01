local skyLinq = require("skyLinq")

local function serialize (o)
    if o == nil then
        io.write("nil")
        return
    end
    if type(o) == "number" then
        io.write(o)
    elseif type(o) == "string" then
        io.write(string.format("%q", o))
    elseif type(o) == "table" then
        io.write("{\n")
        for k,v in pairs(o) do
            io.write(" [");
            serialize(k);
            io.write("] = ")
            serialize(v)
            io.write(",\n")
        end
        io.write("}")
    elseif type(o) == "boolean" then
        io.write( o and "true" or "false" )
    elseif type(o) == "function" then
        io.write( "function" )
    else
        error("cannot serialize a " .. type(o))
    end
end

local arrayA
local arrayB
local arrayC

print("Test Empty Array Linq")
arrayA = {1,2,3,4,5,6}
arrayB = skyLinq.from(arrayA)
serialize(arrayB)

print("Test Empty Dictionary Linq")
arrayA = {a = 1,b = 2,c = 3}
arrayB = skyLinq.from(arrayA)
serialize(arrayB)

print("Test Empty Mixed Linq")
arrayA = {1,2,3,a = 1,b = 2,c = 3}
arrayB = skyLinq.from(arrayA)
serialize(arrayB)

print("Test [Where Array] Command")
arrayA = {1,2,3,4,5,6}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):where(function(num) return num % 2 == 1 end)
serialize(arrayB)

print("Test [Where Dictionary] Command")

arrayA = {a = 1,b = 2,c = 3}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):whereDictionary(function(key,value) return value % 2 == 1 end)
serialize(arrayB)

print("Test [Where Mixed] Command")

arrayA = {1,2,3,a = 1,b = 2,c = 3}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):whereDictionary(function(key,value) return value % 2 == 1 end)
serialize(arrayB)

print("Test [Orderby] Command")

arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderby()
serialize(arrayB)

print("Test [Orderby Change] Command")

arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderby()
serialize(arrayB)

print("after2")
table.insert(arrayA,10)
table.insert(arrayA,12)
serialize(arrayB)

print("Test [Copy Orderby Change] Command")

arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderby()
serialize(arrayB)

print("after2")
table.insert(arrayA,10)
table.insert(arrayA,12)
arrayC = skyLinq.from(arrayB):toArray(function(index,value)return {index,value} end)
serialize(arrayC)

print("Test [Orderby Mixed] Command")

arrayA = {1,5,2,4,6,3,7,8,a = 1,b = 2,c = 3}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderby()
serialize(arrayB)

print("Test [OrderbyDescending] Command")
arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderbyDescending()
serialize(arrayB)

print("Test [Orderby and Where] Command")

arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderby():where(function(num) return num >= 5 end)
serialize(arrayB)

print("Test [Select] Command")

arrayA = {
    {a = 1},
    {a = 2},
    {a = 3},
    {a = 4},
    {a = 5}
}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):select(function(o)return o.a end)
serialize(arrayB)

print("Test [SelectDictionary] Command")

arrayA = {
    a = {a = 1},
    b = {a = 3},
    c = {a = 4},
    d = {a = 6}
}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):selectDictionary(function(k,v)return v.a end)
serialize(arrayB)

print("Test [ToArray] Command")

arrayA = {
    a = {a = 1},
    b = {a = 3},
    c = {a = 4},
    d = {a = 6}
}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):toArray(function(k,v)return {k,v.a} end):orderby(function(a,b)return a[2] < b[2] end)

serialize(arrayB)


print("All Test Complete")