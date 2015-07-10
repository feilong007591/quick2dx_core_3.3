--
-- Author: Your Name
-- Date: 2015-05-12 22:05:20
--

scheduler = require("framework.scheduler")
net = require("framework.cc.net.init")

cc.utils = require("framework.cc.utils.init")
ByteArray = cc.utils.ByteArray
ByteArrayVarint = cc.utils.ByteArrayVarint

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

require "gameCore.utils.jelly.jellyData"
require "gameCore.utils.jelly.JellyEffect"

--managers
require "gameCore.managers.socket.ClientSocket"
require "gameCore.managers.socket.SocketHandler"
require "gameCore.managers.socket.SocketManager"
require "gameCore.managers.TiLiManager"
require "gameCore.managers.DoubleClickManager"
require "gameCore.managers.EffectManager"


gameDispatcher = GameDispatcher:new()

audio = require("gameCore.audio")