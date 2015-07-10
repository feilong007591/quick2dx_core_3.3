--双击管理器
local DOUBLE_CLICK_DELAY = 300 --双击时间间隔 300毫秒

DoubleClickManager = class("DoubleClickManager", function(self)
	local temp = {}

	temp.receiver = nil
	temp.lastClickObj = nil
	temp.lastClickTime = 0

	return temp
end)

function DoubleClickManager:ctor()
	
end

function DoubleClickManager:addClick(clickObj,receiver)
	if(self.lastClickObj ~= nil)then
		if(self.lastClickObj == clickObj)then
			if(self:checkIsDoubleClick())then
				return
			end
		else
			--单击前一个物体
			self.receiver:singleClick(self.lastClickObj)
		end
	end

	self.receiver = receiver
	self.lastClickObj = clickObj
	self.lastClickTime = globalData.systemDateInfo:getSystemTime()

	globalManager.tickManager:addTick(self.tick,self)
end

function DoubleClickManager:tick(delta,tickCount)
	if(self.lastClickObj == nil)then return end
	self:checkIsSingleClick()
end

function DoubleClickManager:checkIsSingleClick()
	local nowTime = globalData.systemDateInfo:getSystemTime()
	if(nowTime - self.lastClickTime >= DOUBLE_CLICK_DELAY)then
		globalManager.tickManager:removeTick(self.tick,self)

		self.receiver:singleClick(self.lastClickObj)
		self.receiver = nil
		self.lastClickObj = nil
		
		return true
	end

	return false
end

function DoubleClickManager:checkIsDoubleClick()
	local nowTime = globalData.systemDateInfo:getSystemTime()
	if(nowTime - self.lastClickTime < DOUBLE_CLICK_DELAY)then
		globalManager.tickManager:removeTick(self.tick,self)
		
		self.receiver:doubleClick(self.lastClickObj)
		self.receiver = nil
		self.lastClickObj = nil
		
		return true
	end

	return false
end

function DoubleClickManager:clear()
	globalManager.tickManager:removeTick(self.tick,self)
	self.receiver = nil
	self.lastClickObj = nil
end