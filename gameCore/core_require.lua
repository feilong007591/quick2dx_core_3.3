--
-- Author: Your Name
-- Date: 2015-05-12 22:05:20
--

--conf
require "gameCore.conf.CommonConf"

--events
require "gameCore.events.BaseEvent"
require "gameCore.events.FunctionData"
require "gameCore.events.EventDispatcher"
require "gameCore.events.GameDispatcher"

--template
require "gameCore.template.BaseTemplate"

--utils
require "gameCore.utils.CommonDefine"
require "gameCore.utils.ShakeAction"

require "gameCore.utils.joystick.Joystick"

cc.utils = require("framework.cc.utils.init")
ByteArray = cc.utils.ByteArray
ByteArrayVarint = cc.utils.ByteArrayVarint


gameDispatcher = GameDispatcher:new()

audio = require("gameCore.audio")
audio:initEvent()

scheduler = require("framework.scheduler")