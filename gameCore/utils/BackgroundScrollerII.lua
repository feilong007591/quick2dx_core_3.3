--
-- 背景滚动工具类
-- Date: 2015-05-21 21:10:00
--
local scheduler = require("framework.scheduler")

BackgroundScrollerII = class("BackgroundScrollerII", function(self,reference,direction)
    local temp = display.newNode()
    --参照节点
    temp._reference = reference
    temp._direction = direction

    print("..........................................................................")
    print("temp._direction:",temp._direction)

    temp._reference_prex = reference:getPositionX()
    temp._reference_prey = reference:getPositionY()

    temp._handle = nil
    temp._scrollBgs = {} --滚动背景
    return temp
end)

function BackgroundScrollerII:ctor()
    self:initEvent()
end

--设置参照物
function BackgroundScrollerII:setReference(reference)
    self._reference = reference
end

function BackgroundScrollerII:addScroller(bgNodes,moverate,isLoop)
    local scroll = ScrollBg:new(self._direction,bgNodes,moverate,isLoop)
    table.insert(self._scrollBgs,scroll)
end

function BackgroundScrollerII:initEvent()
    local function tick()
        if(nil == self._reference)then
            return
        end
        local nowX,nowY = self._reference:getPosition()

        if(nowX == self._reference_prex and nowY == self._reference_prey)then
            return
        end
        self._reference_prex = nowX
        self._reference_prey = nowY

        for i=1,#self._scrollBgs do
            local scroll = self._scrollBgs[i]
            scroll:referenceTo(nowX,nowY)
        end
    end
    -- self.handle = scheduler.scheduleGlobal(tick,GAME_FPS)
    self:schedule(tick,GAME_FPS)
end

function BackgroundScrollerII:removeEvent()
    -- scheduler.unscheduleGlobal(self.handle)
end

function BackgroundScrollerII:dispose()
    self:removeEvent()
end

--滚动背景
ScrollBg = class("ScrollBg", function(self,direction,bgNodes,moverate)
    local temp = {}
    temp._currentX = 0
    temp._currentY = 0
    temp._direction = direction
    temp._isLoop = isLoop or true
    temp._bgNodes = bgNodes --滚动背景列表
    temp._moverate = moverate --滚动系数

    temp._deltaList = nil --背景间间距列表,{point}


    local zOrder = temp._bgNodes[1]:getLocalZOrder()
    temp._parent = display.newNode():addTo(temp._bgNodes[1]:getParent(),zOrder)
    --粗暴的设置父层级为同一个
    for i=1,#temp._bgNodes do
        temp._bgNodes[i]:removeFromParent(false)
        temp._bgNodes[i]:addTo(temp._parent)
    end

    return temp
end)

function ScrollBg:ctor()
    self:initData()
end

function ScrollBg:initData()
    self._deltaList = {}
    for i=1,#self._bgNodes do
        local node = self._bgNodes[i]

        local posX,posY = self._bgNodes[i]:getPosition()
        if(1 == i)then
            node.deltaX = posX
            node.deltaY = posY
        else
            local preNode = self._bgNodes[i - 1]
            node.deltaX = posX - preNode:getPositionX() - preNode:getCascadeBoundingBox().width
            node.deltaY = posY - preNode:getPositionY() - preNode:getCascadeBoundingBox().height
        end
    end
end

--参照物移动到的位置
function ScrollBg:referenceTo(valX,valY)
    self._currentX = valX * self._moverate
    self._currentY = valY * self._moverate

    self._parent:pos(self._currentX, self._currentY)
    
    for i=1,#self._bgNodes do
        local node  = self._bgNodes[i]
        local conv1 = node:convertToWorldSpace(cc.p(0,0))
        if(BackgroundScrollerII.HORIZONTAL == self._direction)then
            if(conv1.x + node:getCascadeBoundingBox().width < 0)then
                if(#self._bgNodes > 1)then
                    table.remove(self._bgNodes,i)
                    local lastNode = self._bgNodes[#self._bgNodes]
                    local lastX,lastY = lastNode:getPosition()
                    node:setPositionX(node.deltaX + lastX + lastNode:getCascadeBoundingBox().width)
                    table.insert(self._bgNodes,node)
                else
                    node:pos(node.deltaX,node.deltaY)
                end
                -- print("移动背景：",conv1.x,node:getCascadeBoundingBox().width,#self._bgNodes)
                -- print("新位置：",node:getPositionX(),node:getPositionY())
                break
            end
        else
            if(conv1.y + node:getCascadeBoundingBox().height < 0)then
                if(#self._bgNodes > 1)then
                    table.remove(self._bgNodes,i)
                    local lastNode = self._bgNodes[#self._bgNodes]
                    local lastX,lastY = lastNode:getPosition()
                    node:setPositionY(node.deltaY + lastY + lastNode:getCascadeBoundingBox().height)
                    table.insert(self._bgNodes,node)
                else
                    node:pos(node.deltaX,node.deltaY)
                end
                -- print("移动背景：",conv1.x,node:getCascadeBoundingBox().width,#self._bgNodes)
                -- print("新位置：",node:getPositionX(),node:getPositionY())
                break
            end
        end
        
    end
end


BackgroundScrollerII.HORIZONTAL = 1
BackgroundScrollerII.VERTICAL = 2

return BackgroundScrollerII