#!/usr/bin/env coffee

path = require "path"
fs = require "fs"
p = require "commander"
_ = require "underscore"
child_process = require 'child_process'
walk = require "walk"
assert = require "assert"
debuglog = require("debug")("binding-to-snippet")

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

walker = walk.walk p.input, followLinks: false

walker.on "file", (root, fileStats, next) ->

  pathToFile = "#{root}/#{fileStats.name}"

  unless path.extname(pathToFile) is ".lua"
    debuglog "[on file] ignore none lua file: #{pathToFile}"
    return next()

  debuglog "[binding-to-snippet::on file] process:#{pathToFile}"
  next()
  return

walker.on "errors", (root, nodeStatsArray, next)->
  console.log "[binding-to-snippet::on errors] fail to continue, root:#{root}"
  process.exit(1)
  return

walker.on "end", -> console.log "all done"










