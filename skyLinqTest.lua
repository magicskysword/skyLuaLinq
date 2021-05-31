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

print("Test [Where Array] Command")
arrayA = {1,2,3,4,5,6}
print("before")
for key, value in pairs(arrayA) do
    print(key,value)
end

print("after")
arrayB = skyLinq.from(arrayA):where(function(num) return num % 2 == 1 end)
for key, value in pairs(arrayB) do
    print(key,value)
end

print("Test [Where Dictionary] Command")

arrayA = {a = 1,b = 2,c = 3}
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
arrayB = skyLinq.from(arrayA):orderby(math.min)
serialize(arrayB)

print("Test [Orderby Change] Command")

arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderby(math.min)
serialize(arrayB)

print("after2")
table.insert(arrayA,5)
table.insert(arrayA,11)
serialize(arrayB)

print("Test [OrderbyDescending] Command")
arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderbyDescending(math.min)
serialize(arrayB)

print("Test [Orderby and Where] Command")

arrayA = {1,5,2,4,6,3,7,8}
print("before")
serialize(arrayA)

print("after")
arrayB = skyLinq.from(arrayA):orderby(math.min):where(function(num) return num >= 5 end)
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


print("All Test Complete")