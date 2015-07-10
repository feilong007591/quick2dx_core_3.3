--
-- Author: 果冻效果
-- Date: 2015-07-07 11:08:55
--

local animaData = {
	jellyAnimation1,
	jellyAnimation2,
	jellyAnimation3,
	jellyAnimation4,
	jellyAnimation5,
	jellyAnimation6,
}
local paceTime = 0.025

JellyEffect = class("JellyEffect", function(self,node,index,number,isforever)
	math.randomseed(os.time())
	temp = display.newNode()
	temp.node_ = node
	temp.number_ = number
	temp.currentNum = 1
	temp.currenttime_ = 0
	temp.ispause_ = true
	temp.isforever_ = isforever or false
	temp.dataIndex_ = 1
	temp.paceTime_ = 0
	temp.animaData_ = animaData[index]

	temp._initdata = {}
	temp._initdata.pos = cc.p(temp.node_:getPositionX(),temp.node_:getPositionY())
	temp._initdata.scaleX = temp.node_:getScaleX()
	temp._initdata.scaleY = temp.node_:getScaleY()
	temp._initdata.skewX = temp.node_:getSkewX()
	temp._initdata.skewY = temp.node_:getSkewY()

	temp.node_:addChild(temp)
	return temp
end)

function JellyEffect:ctor()
    self:setNodeEventEnabled(true)
end

function JellyEffect:start()
	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
	self:initEvent()
	self.ispause_ = false
	self.currentNum = 1
	self.dataIndex_ = 1
	self.paceTime_ = 0
	self.currenttime_ = 0
end

function JellyEffect:onEnter()
	self:initEvent()
end

function JellyEffect:onExit()
	self:stop()
end

function JellyEffect:pause()
	self.ispause_ = true
    self.node_:setPosition(self.m_initial_x,self.m_initial_y)
end

function JellyEffect:resume()
	self.ispause_ = false
end

function JellyEffect:initEvent()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:update(dt) end)
    self:scheduleUpdate()
end

function  JellyEffect:stop()
	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
	self.node_:setPosition(self._initdata.pos.x,self._initdata.pos.y)
	self.node_:setScaleX(self._initdata.scaleX)
	self.node_:setScaleY(self._initdata.scaleY)
	self.node_:setSkewX(self._initdata.skewX )
	self.node_:setSkewY(self._initdata.skewY )
end

function JellyEffect:update(dt)
	if self.ispause_ == false then	
		if self.paceTime_ >= paceTime then
			if self.dataIndex_ <= #self.animaData_ then
				local data = self.animaData_[self.dataIndex_]
				if data[1] ~= nil then
					local x = data[1] + self._initdata.pos.x
					local y = data[2] + self._initdata.pos.y
					local scaleX = data[3]
					local scaleY = data[4]
					local skewX = data[5]
					local skewY = data[6]

					self.node_:setPosition(x, y)
					self.node_:setScaleX(scaleX)
					self.node_:setScaleY(scaleY)
					self.node_:setSkewX(skewX)
					self.node_:setSkewY(skewY)
					self.dataIndex_ = self.dataIndex_ + 1
				end
			else
				self.dataIndex_ = 1
				self.currentNum = self.currentNum + 1
				if self.currentNum > self.number_  and self.isforever_ == false	 then
					self:stop()	
				end
			end
			self.paceTime_ = 0
		end
		self.paceTime_ = self.paceTime_ + dt
	end
end
