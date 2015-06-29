--
-- 云层滚动类
-- Author: Hy
-- Date: 2015-05-25 20:10:00
--
CloudScroller = class("CloudScroller", function(self,speed,direction,rangey_min,rangey_max)
   	local temp = display.newNode()
    temp._Cloubs = {}
    temp._direction = direction
    temp._speed = speed
    temp._rangey_min = rangey_min
    temp._rangey_max = rangey_max
    self.handle = nil

    return temp
end)

function CloudScroller:ctor()
    display.addSpriteFrames("ccsui/common/common_2.plist", "ccsui/common/common_2.png") --成就图标图集
	self:initView()
	self:scroll()

end

function CloudScroller:initView()
	local posx = math.random(0,display.right)
	local posy = math.random(self._rangey_min,self._rangey_max)
	for i=1,6 do
		local tempsprite = display.newSprite(IMAGE_CLOUDS[i],posx,posy):addTo(self)
		table.insert(self._Cloubs ,tempsprite)
	end
end

function CloudScroller:scroll()

	function tick()
		local isrunning = true
		if(global.isPause)then
	        isrunning = false
	    end
	    if isrunning then
	    	if  self._direction == 1 then
				for i=1,#self._Cloubs do
		    		local conv = self._Cloubs[i]:convertToWorldSpace(cc.p(0,0))
					local sx = self._Cloubs[i]:getContentSize().width
					if conv.x < -(sx + 50) then
						local posx = math.random(0,100)
						local posy = math.random(self._rangey_min,self._rangey_max)
						self._Cloubs[i]:setPosition(display.right + sx + posx, posy)
					end
					self._Cloubs[i]:setPositionX(self._Cloubs[i]:getPositionX() - self._speed)
				end
			else
				for i=1,#self._Cloubs do
		    		local conv = self._Cloubs[i]:convertToWorldSpace(cc.p(0,0))
					local sy = self._Cloubs[i]:getContentSize().height
					if conv.y < -(sy + 100) then
						local posx = math.random(0,display.right)
						local posy = math.random(0,100)
						self._Cloubs[i]:setPosition(posx, display.top + sy + posy)
					end
					self._Cloubs[i]:setPositionY(self._Cloubs[i]:getPositionY() - self._speed)
				end
	    	end
	    end
	end
    -- self.handle = scheduler.scheduleGlobal(tick,GAME_FPS)

    self:schedule(tick,GAME_FPS)

end

function CloudScroller:removeEvent()
    -- scheduler.unscheduleGlobal(self.handle)
end

CloudScroller.HORIZONTAL = 1
CloudScroller.VERTICAL = 2

return CloudScroller
