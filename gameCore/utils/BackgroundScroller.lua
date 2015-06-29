--
-- 背景滚动工具类
-- Author: Hy
-- Date: 2015-05-21 21:10:00
--

BackgroundScroller = class("BackgroundScroller", function()
    local temp = display.newNode()
    --参照节点
    temp._reference = nil
    --背景节点
    temp._backbgs = {}
    --背景移动系数
    temp._bgrates = {}
    temp._startpos={}
    temp._maxpos = cc.p(0,0)
    temp._isloop = true

   	-- temp._loopbg1 = nil
   	-- temp._loopbg2 = nil
   	-- temp._loopstartpos1 = cc.p(0,0)
   	-- temp._loopstartpos2 = cc.p(0,0)
    -- temp._loopsx = nil
    -- temp._loopsy = nil

    temp._reference_prex = 0
    temp._reference_prey = 0
    temp._movex = 0
    temp._movey = 0
    return temp
end)

function BackgroundScroller:setScrolLoop(offloop)
     self._isloop = false
end

function BackgroundScroller:setreference(reference)
    self._reference = reference
end

function BackgroundScroller:start()
    for i=1,#self._backbgs do
        print("各个地图的 size",self._backbgs[i]:getCascadeBoundingBox().width)
    end
    self:UpdateScrollBy()
end


--添加滚动层 
--percent 相对于参照物的滚动百分比
-- params = {
-- 	   reference = referncenode
--     backbg1 = bgnode1 , bgrate1 = 0.8,
--     backbg2 = bgnode2 , bgrate2 = 0.7,
--     backbg3 = bgnode3 , bgrate3 = 0.7,
-- }

function BackgroundScroller:addBgScroller(bgnodes,moverate)

    table.insert(self._backbgs,bgnode)

    table.insert(self._bgrates,moverate)

    local temppos = cc.p(0,0)
    temppos.x , temppos.y = bgnode:getPosition()
    table.insert(self._startpos,temppos)
    if self._maxpos.x > temppos.x then
        self._maxpos.x = temppos.x
    end
    if self._maxpos.y > temppos.y then
        self._maxpos.y = temppos.y
    end
    --dump(_backbgs)
end


--自动增量滚动
function BackgroundScroller:UpdateScrollBy()
	--print("----------------开启更新-----------------------")
    self:schedule(function(dt)
    	local xx , yy = self._reference:getPosition()
        local valuex = xx - self._reference_prex
        local valuey = yy - self._reference_prey
        --瞬间转化的时候，按照之前的移动值
        if valuex <= 0 then
            self._movex = valuex
        end
        if valuey <= 0 then
            self._movey = valuey
        end
    	--print("参照场景x "..xx.."  参照场景y "..yy)
	    for i=1,#self._backbgs do
	    	if self._backbgs[i] ~= nil  then
	    		 self._backbgs[i]:setPosition( self._backbgs[i]:getPositionX() + self._bgrates[i]*self._movex, self._backbgs[i]:getPositionY() + self._bgrates[i]*self._movey)
	    	end
	    end
        self._reference_prex = xx
        self._reference_prey = yy

        if self._isloop == true then
            self:CheckToLoopTwoBg()
        end
    end,1/60.0)
end

-- 拼接多个不同的背景
function BackgroundScroller:CheckToLoopTwoBg()

    for i=1,#self._backbgs do
       local conv1 = self._backbgs[i]:convertToWorldSpace(cc.p(0,0))
        --print("第 1 个地图的屏幕坐标",self._backbgs[1]:convertToWorldSpace(cc.p(0,0)).x)
        print("第 2 个地图的屏幕坐标",self._backbgs[2]:convertToWorldSpace(cc.p(0,0)).x)
        --print("第 3 个地图的屏幕坐标",self._backbgs[3]:convertToWorldSpace(cc.p(0,0)).x)
        --print("第 4 个地图的屏幕坐标",self._backbgs[4]:convertToWorldSpace(cc.p(0,0)).x)
        if i <= 1 then
            if conv1.x < -self._backbgs[i]:getCascadeBoundingBox().width then
                self._backbgs[i]:setPositionX(self._backbgs[#self._backbgs]:getPositionX() + self._backbgs[#self._backbgs]:getCascadeBoundingBox().width+self._startpos[i].x)
            end
        else
            if conv1.x < -self._backbgs[i]:getCascadeBoundingBox().width then
                --print("=======进行循环===i>1",self._backbgs[i-1]:getPositionX() + (self._startpos[i].x - self._startpos[i-1].x))
                self._backbgs[i]:setPositionX(self._backbgs[i-1]:getPositionX() + (self._startpos[i].x - self._startpos[i-1].x))
            end
        end
    end
end

--一个背景复制两份 循环拼接
-- param 
function BackgroundScroller:LoopOneBg(loopbg1,loopposx)

end