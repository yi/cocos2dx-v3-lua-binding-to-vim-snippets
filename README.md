# cocos2dx-v3-lua-binding-to-vim-snippets

a simple coffee script to read in cocos2dx v3 lua binding files and output vim snippets

## 这是什么

这是一个 coffeescript 脚本，作用是将 cocos2dx csxV3 版本中的 [lua binding](https://github.com/chukong/cocos2d-x/tree/csxV3/cocos/scripting/lua-bindings/auto/api) 生成成 vim 的 [MoonScript snippets](./csxV3.snippet)

## 安装

```sh
# 安装全局的 coffee-script
npm install coffee-script -g

# 安装这个项目所依赖的包
npm install .
```

## 如何使用

```sh
# 将 lua binding 的生成结果输出到命令行窗口
./binding-to-snippet.coffee -i path/to/cocos/scripting/lua-bindings/auto/api/ -o csxV3.snippet
```

```sh
# 将 lua binding 的生成结果输写入指定的文件
./binding-to-snippet.coffee -i path/to/cocos/scripting/lua-bindings/auto/api/ -o csxV3.snippet
```

## 如何修改输出模板

这个程序通过解析 lua-bindings 将方法解析成如下的对象结构：

```js
{
  module : String
  method : String
  params : String[] (optional)
  return : String (optional)
}
```

可以通过修改 [./binding-to-snippet.coffee](./binding-to-snippet.coffee) 文件中的 `obj2snippet` 方法将输出调整为你想要的格式。


