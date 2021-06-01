# skyLuaLinq

这是一个在lua中使用linq进行查询的库

> 该库使用了 emmylua 的注解功能加上了注释，推荐使用该插件对注释进行查看
> emmylua [Intellij版本](https://github.com/EmmyLua/IntelliJ-EmmyLua) [vscode版本](https://github.com/EmmyLua/VSCode-EmmyLua)

目前支持：
## 延迟查询
延迟查询会返回一个Linq对象，对该对象使用查询函数可以继续进行查询

查询会在对该对象进行遍历时开始，也可以对Linq对象执行:run()函数来立即得到结果

|函数|功能|
|-|-|
|from|从一个表或查询中创建一个查询|
|toArray|将查询转化为数组|
|toDictionary|将查询转化为字典|
|where|从查询中选择符合条件值|
|whereDictionary|从查询中选择符合条件的键与值|
|select|指定将在执行查询时产生的值的类型（传入值）|
|selectDictionary|指定将在执行查询时产生的值的类型（传入键与值）|
|orderBy|对查询出的语句进行升序排序|
|orderByDescending|对查询出的语句进行降序排序|
|thenBy|对已排序的语句进行不改变原有排序顺序的二次排序|
|thenByDescending|对已排序的语句进行不改变原有排序顺序的二次降序排序|

## 直接查询
直接查询会返回表中的某个值，通常可以直接传入table，也可以传入Linq对象

如果被查询的对象是Linq对象，则会立即对其进行结果计算

|函数|功能|
|-|-|
|min|查询表中的最大值|
|max|查询表中的最小值|
|max|查询表中的第一个值|

范例：
```lua
local skyLinq = require("skyLinq")

arrayA = {
    a = {a = 1},
    b = {a = 3},
    c = {a = 4},
    d = {a = 6}
}

arrayB = skyLinq.from(arrayA)
    :toArray(function(k,v)return {k,v.a} end)
    :orderBy(function(a,b)return a[2] < b[2] end)

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
* 诸如 linq:max() 等返回值的查询，是会直接进行运算的