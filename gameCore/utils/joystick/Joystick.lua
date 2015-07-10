-- 
-- 虚拟摇杆
-- Date: 2015-07-06 16:20:01
--

local DEFAULT_NAME = "Joystick"

-- local joysticks = {} --虚拟摇杆列表

Joystick = class("Joystick", function(self,name,type,pos)
    local temp = display.newNode("")

    name = name or DEFAULT_NAME
    temp._name = name
    temp._stickBg = nil
    temp._stickDot = nil
    temp._activity = false
    temp._rad = 0
    temp._startPoint = cc.p(0,0)
    temp._power = 0  --强度
    temp:setPosition(pos.x, pos.y)
    temp._type = type

    return temp
end)

function Joystick:ctor()
    -- joysticks[self._name] = self

    self._stickBg = display.newSprite("joystick/joystick_bg.png"):addTo(self)
    self._stickDot = display.newSprite("joystick/joystick_dot.png"):addTo(self)
    self._rad = self._stickBg:getBoundingBox().width*0.5
    if self._type == Joystick.FreeType then
        self:setVisible(false)
    end
    self:initEvent()

end

--设置皮肤，不调用此方法设置则绘制默认形状
function Joystick:setSkin(bgFile,barFile)
    self._stickBg:setTexture(bgFile)
    self._stickDot:setTexture(barFile)
    self._rad = self._stickBg:getBoundingBox().width*0.5
end

local preDir = 0
function Joystick:initEvent()
    self:setTouchEnabled(true)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        local locationInNode = self:convertToNodeSpace(cc.p(event.x,event.y))
        -- print("====locationInNode===",locationInNode.x,locationInNode.y)
        if event.name == "began" then
            self._stickDot:setPosition(locationInNode.x,locationInNode.y)
            return true

        elseif event.name == "moved" then
            local dotLen = cc.pGetDistance(locationInNode, self._startPoint)
            if dotLen >= self._rad then
                self._stickDot:setPosition(cc.pAdd( self._startPoint,cc.pMul(cc.pNormalize(locationInNode,self._startPoint),self._rad)))
                self._power = 1
            else
                self._stickDot:setPosition(locationInNode.x,locationInNode.y)
                self._power = dotLen / self._rad
            end

            if(preDir ~= self:getDirection())then
                preDir = self:getDirection()
                -- print("发送转向协议：" .. preDir ..",".. net.SocketTCP.getTime())

            end
            
        elseif event.name == "ended"  then
            if self._type == Joystick.FreeType then
                self:ShowAndActivity(false)
                self._power = 0
            else
                self._stickDot:setPosition(0,0)
            end
        end
    end)

end

function Joystick:getStickBoxSize()
    return self._stickBg:getBoundingBox()
end

function Joystick:HandlTouch(point)
    print("====HandlTouch===")
    local locationInNode = point
    self._stickDot:setPosition(locationInNode.x,locationInNode.y)
    local dotLen = cc.pGetDistance(locationInNode, self._startPoint)
    if dotLen >= self._rad then
        self._stickDot:setPosition(cc.pAdd( self._startPoint,cc.pMul(cc.pNormalize(locationInNode,self._startPoint),self._rad)))
        self._power = 1
    else
        self._stickDot:setPosition(locationInNode.x,locationInNode.y)
        self._power = dotLen / self._rad
    end
end

function Joystick:ShowAndActivity(activity,pos)
    if self._type == Joystick.FreeType then
        self._activity = activity
        if(pos ~= nil) then
            self:setPosition(pos.x, pos.y)  
        end
        if activity == true then
            self:stop()
            self._stickBg:stop()
            self._stickDot:stop()
            self._stickDot:setPosition(0,0)
            self:setVisible(activity)
            self:setOpacity(255)
            self._stickBg:setOpacity(255)
            self._stickDot:setOpacity(255)
        else
            local time = 0.5
            self._stickBg:runAction(cca.fadeOut(time))
            self._stickDot:runAction(cca.fadeOut(time))
            local sequ = transition.sequence({cca.fadeOut(time),cc.CallFunc:create(function()
                    self:setVisible(activity)
                end)})
            
            self:runAction(sequ)
        end
    end
end

--获取当前指向的方向方向 (0,360)
function Joystick:getDirection()
    local angle = math.floor(math.radian2angle(cc.pToAngleSelf(cc.p(self._stickDot:getPositionX(),self._stickDot:getPositionY()))))
    if angle <=0  then
       angle =  360+angle
    end
    return angle

end

--滑动的强度，距离越远强度越大
function Joystick:getPower()
    return self._power
end

--获取位置:return x,y
function Joystick:getDotPosition()

    return 0,0
end

-- --销毁
-- function Joystick:dispose()
--     joysticks[self._name] = nil

--     --其他操作
-- end


--设置方式 固定 ：1 ，自由位置：2 
Joystick.FixedType = 1
Joystick.FreeType = 2


-- --静态方法:通过名字获取Joystick
-- function Joystick.getJoystick(name)
--     return joysticks[name]
-- end

-- function Joystick:getJoystickList()
--     return joysticks
-- end