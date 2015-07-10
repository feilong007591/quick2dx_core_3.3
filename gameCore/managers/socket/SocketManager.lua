--
-- Author: 
--
SocketManager = class("SocketManager", function()
    local temp = {}

    temp._handlers = {}
    
    temp.clientSocket = nil

    return temp
end)

function SocketManager:ctor()
    self:init()
    self:debugPrint()
end

function SocketManager:init()
    self.clientSocket = ClientSocket:new()
end

function SocketManager:connect(__host, __port)
    self.clientSocket:startConnect(__host, __port)
end

function SocketManager:debugPrint()
    net.SocketTCP._DEBUG = true --DEBUG模式
    local time = net.SocketTCP.getTime()
    print("socket time:" .. time)
    print("version is "..net.SocketTCP._VERSION)
end

--添加Handler
function SocketManager:addHandler(socketHandler)
    if(0 >= socketHandler.protocol)then
        printError("协议处理handler无类型:",handler)
        return
    end
    self._handlers[socketHandler.protocol] = socketHandler
end

--处理协议
function SocketManager:doHandler(protocol,bytes)
    local handler = self._handlers[protocol]
    if(nil ~= handler)then
        handler:execute(bytes)
    else
        printError("协议未解析:" .. protocol)
    end
end

--获取协议包头
function SocketManager:getPackage(protocol)
    local bytes = ByteArray.new(ByteArrayVarint.ENDIAN_BIG)
    bytes:writeInt(protocol)
    return bytes
end

--发送协议
function SocketManager:send(bytes)
    self.clientSocket:sendSokcetData(bytes)
end

--关闭socket连接
function SocketManager:close()
    if self.clientSocket.isConnected then
        self.clientSocket:close()
    end
    self.clientSocket:disconnect()
end

socketManager = SocketManager:new()
return SocketManager

