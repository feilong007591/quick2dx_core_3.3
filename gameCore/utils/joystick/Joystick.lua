-- 
-- 虚拟摇杆
-- Date: 2015-07-06 16:20:01
--

local DEFAULT_NAME = "Joystick"
local joysticks = {} --虚拟摇杆列表

Joystick = class("Joystick", function(self,name)
    local temp = {}
    
    name = name or DEFAULT_NAME
    temp._name = name

    return temp
end)

function Joystick:ctor()
    joysticks[self._name] = self
end

--设置皮肤，不调用此方法设置则绘制默认形状
function Joystick:setSkin(bgFile,barFile)

end

--获取当前指向的方向方向
function Joystick:getDirection()
    return 0
end

--获取位置:return x,y
function Joystick:getPosition()
    return 0,0
end

--销毁
function Joystick:dispose()
    joysticks[self._name] = nil

    --其他操作
end


--静态方法:通过名字获取Joystick
function Joystick.getJoystick(name)
    return joysticks[name]
end