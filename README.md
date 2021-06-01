# skyLuaLinq

这是一个在lua中使用linq的库

目前支持：

|函数|功能|
|-|-|
|from|从一个表或查询中创建一个查询|
|toArray|将查询转化为数组|
|toDictionary|将查询转化为字典|
|where|从查询中选择符合条件值|
|whereDictionary|从查询中选择符合条件的键与值|
|select|指定将在执行查询时产生的值的类型（传入值）|
|selectDictionary|指定将在执行查询时产生的值的类型（传入键与值）|
|orderby|对查询出的语句进行升序排序|
|orderbyDescending|对查询出的语句进行降序排序|


范例：
```lua
arrayA = {
    a = {a = 1},
    b = {a = 3},
    c = {a = 4},
    d = {a = 6}
}

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

* 注意：所有返回linq对象的查询都是延迟查询，只有当遍历时，或执行linq:run()，才会生成结果
* 诸如 linq:max() 等返回值得查询，是运算并返回结果的查询