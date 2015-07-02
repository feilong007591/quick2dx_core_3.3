--
-- Author: Your Name
-- Date: 2015-05-12 22:05:20
--

--events
require "core.events.BaseEvent"
require "core.events.FunctionData"
require "core.events.EventDispatcher"
require "core.events.GameDispatcher"

--template
require "core.template.BaseTemplate"

--utils
require "core.utils.CommonDefine"

cc.utils = require("framework.cc.utils.init")
ByteArray = cc.utils.ByteArray
ByteArrayVarint = cc.utils.ByteArrayVarint


gameDispatcher = GameDispatcher:new()

audio = require("core.audio")
audio:initEvent()

scheduler = require("framework.scheduler")