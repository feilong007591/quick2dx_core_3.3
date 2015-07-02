--
-- Author: Hy
-- Date: 2015-06-30 15:59:51
--

-- /**
-- * 按指定频度范围内抖动[-strength_x,strength_x][-strength_y, strength_y]
-- */
function fgRangeRand(min, max)
	local rnd = math.random()
	return rnd*(max - min) + min
end

ShakeAction = class("ShackAction", function(self,node,duration,strength_x,strength_y,isforever)
	math.randomseed(os.time())
	temp = display.newNode()
	temp.node_ = node
	temp.duration_ = duration
	temp.currenttime_ = 0
	temp.strength_x_ = strength_x
	temp.strength_y_ = strength_y
	temp.m_initial_x = temp.node_:getPositionX()
	temp.m_initial_y = temp.node_:getPositionY()
	temp.ispause = true
	temp.parent = nil
	temp.isforever_ = isforever or false
	return temp
end)

function ShakeAction:start()
    self:setNodeEventEnabled(true)
	if self.ispause == true then
		self.node_:addChild(self)
		self.ispause = false
	end
end

function ShakeAction:onEnter()
	 self:initEvent()
end

function ShakeAction:onExit()
	self:stop()
end

function ShakeAction:pause()
	self.ispause = true
    self.node_:setPosition(self.m_initial_x,self.m_initial_y)
end

function ShakeAction:resume()
	self.ispause = false
end

function ShakeAction:initEvent()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:update(dt) end)
    self:scheduleUpdate()
end

function ShakeAction:update(dt)
	if self.ispause == false then	
		self.currenttime_ = self.currenttime_ + dt
		local randx = fgRangeRand(-self.strength_x_, self.strength_x_)*dt
		local randy = fgRangeRand(-self.strength_y_, self.strength_y_)*dt
		self.node_:setPosition(cc.pAdd(cc.p(self.m_initial_x,self.m_initial_y), cc.p(randx, randy)))

		if self.currenttime_ >= self.duration_ and self.isforever_ == false then
			print("==========unschedule=ShakeAction==========")
			self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
			self:stop()	
		end
	end
end

function ShakeAction:stop()
	temp.currenttime_ = 0
	self.node_:setPosition(self.m_initial_x,self.m_initial_y)
end

-- /**
-- * 线性抖动(剩余时间越短，抖动范围越小)
-- */
FallOffShakeAction = class("FallOffShakeAction", ShakeAction)

function FallOffShakeAction:update(dt)
	if self.ispause == false then	

		self.currenttime_ = self.currenttime_ + dt

		local rate = ((self.duration_*1.0) - self.currenttime_ )/(self.duration_*1.0)
		if rate < 0 then
			rate = 0
		end

		local randx = fgRangeRand(-self.strength_x_, self.strength_x_)*rate
		local randy = fgRangeRand(-self.strength_y_, self.strength_y_)*rate

		self.node_:setPosition(cc.pAdd(cc.p(self.m_initial_x,self.m_initial_y), cc.p(randx, randy)))

		if self.currenttime_ >= self.duration_  then
			print("==========unschedule=FallOffShakeAction==========")
			self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
			self:stop()	
		end
	end
end
