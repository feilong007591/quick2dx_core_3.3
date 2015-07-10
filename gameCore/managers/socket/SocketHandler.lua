--
-- Author: ffl
-- Date: 2015-07-08 16:02:32
--
SocketHandler = class("SocketHandler", function(self,protocol)
    local temp = {}

    if(nil == protocol)then
        protocol = 0
        printError("Socket处理协议号参数错误")
    end
    
    temp.protocol = protocol --协议编号

    return temp
end)

--override
--协议处理
function SocketHandler:execute(bytes)
    
end