--
-- Author: ffl
-- Date: 2015-07-08 19:14:19
--
local BODY_LEN = 4 -- 消息体长度占4个字节

ClientSocket = class("ClientSocket", function()
    local temp = {}

    temp.socketTcp = net.SocketTCP.new()

    temp.socketTcp:setName("LKCF SocketTcp")
    temp.socketTcp:setTickTime(0.01)
    temp.socketTcp:setReconnTime(6)
    temp.socketTcp:setConnFailTime(4)

    temp.isConnecting = false   --是否真正建立连接

    temp.ip = nil --IP地址
    temp.port = nil --端口号

    temp.buf = ByteArrayVarint.new(ByteArrayVarint.ENDIAN_BIG) -- 数据缓存
    temp.buffLen = 0 --数据长度

    return temp
end)

function ClientSocket:ctor()
    self:init()
end

function ClientSocket:init()
    print("-----init------------")
    self.socketTcp:addEventListener(net.SocketTCP.EVENT_DATA, handler(self, self.tcpDataHandler))
    self.socketTcp:addEventListener(net.SocketTCP.EVENT_CLOSE, handler(self, self.tcpCloseHandler))
    self.socketTcp:addEventListener(net.SocketTCP.EVENT_CLOSED, handler(self, self.tcpClosedHandler))
    self.socketTcp:addEventListener(net.SocketTCP.EVENT_CONNECTED, handler(self, self.tcpConnectedHandler))
    self.socketTcp:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.tcpConnectedFailHandler))
end

function ClientSocket:startConnect(_ip,_port)
    self.isConnecting = true
    self.ip = _ip
    self.port = _port
    print(" 开始建立socket连接:" .. _ip .. ":" .. _port)
    
    self.socketTcp:connect(self.ip, self.port, true)
end

function ClientSocket:sendSokcetData(bytes)
    local msgBytes = ByteArray.new(ByteArrayVarint.ENDIAN_BIG)
    local contentLen = bytes:getLen()
    msgBytes:writeInt(contentLen)
    bytes:setPos(1)
    msgBytes:writeBytes(bytes,1,contentLen)
    
    -- print("发送长度：",contentLen)
    if self.socketTcp.isConnected then
        -- print("--发送---:",self.socketTcp.isConnected)
        self.socketTcp:send(msgBytes:getPack())
    else
        print("socket断开，正在重新连接!")
        self:startConnect(self.ip, self.port)
    end
end


function ClientSocket:closeSocket()
    if self.socketTcp.isConnected then
        self.socketTcp:close()
    end
end


function ClientSocket.getBaseBA()
    return ByteArrayVarint.new(ByteArrayVarint.ENDIAN_BIG)
end


function ClientSocket:tcpDataHandler(event)
    local msg = event.data
    if nil == msg then
        print(" ClientSocket:tcpData is nil")
        return
    end

    -- print("buf len is "..self.buf:getLen())
    self.buf:setPos(self.buf:getLen()+1)
    self.buf:writeBuf(msg)
    self.buf:setPos(1)

    while self.buf:getAvailable() >= BODY_LEN do
        if(0 >= self.buffLen)then
            self.buffLen = self.buf:readInt()
            -- print("读取协议长度："..self.buffLen)
        end
        if(self.buf:getAvailable() >= self.buffLen)then
            
            local prePos = self.buf:getPos()
            -- print("协议长度："..self.buffLen..",总长度:" .. self.buf:getAvailable() ..",POS：" .. self.buf:getPos())
            local protocol = self.buf:readInt()
            -- print("收到协议：" .. protocol)
            socketManager:doHandler(protocol, self.buf)
            -- print("读取完,总长度:" .. self.buf:getAvailable() ..",POS：" .. self.buf:getPos())

            local delta = self.buf:getPos() - (prePos + self.buffLen)
            if(delta > 0)then
                printError(string.format("%s协议内容错误,多读取：%s",protocol,delta))
            elseif(delta < 0)then
                printError(string.format("%s协议内容错误,少读取：%s",protocol,delta))
            end
            self.buf:setPos(prePos + self.buffLen)
            
            self.buffLen = 0
        else
            self.buf:setPos(self.buf:getPos() - BODY_LEN)
            break
        end
    end

    if self.buf:getAvailable() <= 0 then
        self.buf = ClientSocket.getBaseBA()
        self.buffLen = 0
    else
        local __tmp = ClientSocket.getBaseBA()
        __tmp:readBytes(self.buf, 1, self.buf:getAvailable())
        self.buf = __tmp
    end
end

function ClientSocket:tcpCloseHandler()
    self.isConnecting = false
    print(" socket连接已经关闭! ")
    printError("why")
end

function ClientSocket:tcpClosedHandler()
    self.isConnecting = false
    print(" socket连接已经关闭! ") 
end

function ClientSocket:tcpConnectedHandler()
    print(" socket连接建立成功! ")

    self.isConnecting = false
end


function ClientSocket:tcpConnectedFailHandler()
    self.isConnecting = false
    print(" socket连接已经断开! ")
end