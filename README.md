# skyLuaLinq

这是一个在lua中使用linq的库

目前支持：

|函数|功能|
|-|-|
|from||
|toArray||
|toDictionary||
|where||
|whereDictionary||
|select||
|selectDictionary||
|orderby||
|orderbyDescending||


范例：
```lua
arrayA = {1,2,3,a = 1,b = 2,c = 3}

arrayB = skyLinq.from(arrayA)
    :toArray(function(k,v)return {k,v.a} end)
    :orderby(function(a,b)return a[2] < b[2] end)

for k,v in pairs(arrayB) do
    print(k,v[1],v[2])
end
```

输出：
```
1       a       1
2       b       3
3       c       4
4       d       6
```

* 注意：所有查询都是延迟，只有当遍历时，或执行linq:run()，才会生成结果