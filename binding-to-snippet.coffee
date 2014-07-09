#!/usr/bin/env coffee

path = require "path"
fs = require "fs"
p = require "commander"
_ = require "underscore"
child_process = require 'child_process'
walk = require "walk"
assert = require "assert"
debuglog = require("debug")("binding-to-snippet")
readlines = require "readlines"

## 更新外部配置
p.version("0.1")
  .option('-o, --output [VALUE]', 'output file path')
  .option('-i, --input [VALUE]', 'input directory')
  .parse(process.argv)

p.input = path.resolve __dirname, p.input || ''
p.output = path.resolve __dirname, p.output || ''

assert(fs.existsSync(p.input), "invalid input path:#{p.input}")
assert(fs.existsSync(p.output), "invalid output path:#{p.output}")

console.log "[binding-to-snippet] START on :#{p.input}, output to:#{p.output}"

RESULT = []

# convert data object to snippet string
obj2snippet = (obj)->
  unless Array.isArray obj.params
    signature = "#{obj.module}.#{obj.method}!"  # module.function!
    code = signature
  else if obj.params.length is 1 and obj.params[0] is "self"
    signature = "#{obj.module}\\#{obj.method}!"  # module\function!
    code = signature
  else if obj.params[0] is "self"
    obj.params.shift()
    signature = "#{obj.module}\\#{obj.method}(#{obj.params.join("\\,")})"
    # c.t2point(${1:t})
    count = 1
    code = "#{obj.module}\\#{obj.method}(#{obj.params.map((p)->"${#{count++}:#{p}}").join(", ")})"
  else
    signature = "#{obj.module}.#{obj.method}(#{obj.params.join("\\,")})"
    count = 1
    code = "#{obj.module}.#{obj.method}(#{obj.params.map((p)->"${#{count++}:#{p}}").join(", ")})"

  return "snippet #{signature} \"csxV3: #{obj.module}::#{obj.method} \"\n\t#{code}\n\n"

walker = walk.walk p.input, followLinks: false

walker.on "file", (root, fileStats, nextFile) ->

  pathToFile = "#{root}/#{fileStats.name}"

  unless path.extname(pathToFile) is ".lua"
    debuglog "[on file] ignore none lua file: #{pathToFile}"
    return nextFile()

  debuglog "[binding-to-snippet::on file] process:#{pathToFile}"

  currentModuleName = ""
  currentObj = {}

  lines = readlines.readlinesSync pathToFile

  for line, i in lines

    # when splitter
    if ~line.indexOf "------------------------------"
      RESULT.push currentObj if JSON.stringify(currentObj).length > 10  # ignore empty currentObj
      currentObj = {} # new one
      continue

    # when module defination
    if ~line.indexOf "-- @module"
      currentModuleName = (line.split("@module") || [])[1] || ""
      debuglog "[method] currentModuleName:#{currentModuleName}"
      continue

    # when function defination
    if ~line.indexOf "-- @function [parent"
      arr = line.match(/@function\s+\[parent\=\#(\w+)\]\s+(\w+)/)
      if arr.length < 3
        console.log "[binding-to-snippet] WARNING! Fail to parse function @ file:#{pathToFile} line:#{i + 1}"
        currentObj = {}
        continue

      currentObj.module = arr[1]
      currentObj.method = arr[2]
      debuglog "[on line] got function: #{arr[1]}::#{arr[2]}"
      continue

    # when param defination
    if ~line.indexOf "-- @param"
      arr = line.split(" ")
      currentObj.params or= []
      currentObj.params.push _.last(arr)
      debuglog "[on line] got param: #{_.last(arr)}"
      continue

    # when return defination
    if ~line.indexOf "-- @return"
      # -- @return Action#Action ret (return value: cc.Action)
      arr = line.split("(return value:")
      arr = _.last(arr).replace(")", "").trim()
      currentObj.return = arr
      debuglog "[on line] got return: #{arr}"
      continue

  nextFile()

  return

walker.on "errors", (root, nodeStatsArray, next)->
  console.log "[binding-to-snippet::on errors] fail to continue, root:#{root}"
  process.exit(1)
  return

walker.on "end", ->
  content = RESULT.map((item)->obj2snippet(item)).join("\n")
  console.log  content










