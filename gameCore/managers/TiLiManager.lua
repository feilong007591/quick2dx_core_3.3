--
-- Author: HY
-- Date: 2015-06-24 14:08:16
--

--自定义事件  更新体力值 体力值不足
UPDATE_TILI_EVENT = "update_tiLi"
TILI_NOT_ENOUGH_EVENT = "tiLi_not_enough"

INIT_LOCAL = 10000
TILI_VALUE = 10001
TILI_MAX_VALUE = 10002
TILI_CD_VALUE = 10003
FOREVET_VALUE = 10004
TILI_LAST_TIME = 10005

local scheduler = require("framework.scheduler")

TiLiManager  = class("TiLiManager", function()
	local temp = {}

	temp.tiLi_ = 0
	temp.tiLiMax_ = 0
	temp.tiLiCD_ = 0
	temp.lastRecordTime_ = 0
    temp.currentTime_ = 0
	temp.isForever_ = 0  --0普通  1为永久
	temp.handle_ = nil
	temp.ext_tiLi_ = gameData:getGoodsCount(GOODS_TILI)   --购买或者奖励的体力值
	return temp
end)

-- params 
--[[
	params = {
		tili = 2,
		tili_max = 10,
		tili_cd = 180,
		isforever = 0
	}
]]

function TiLiManager:init(params)
	local _tili = 0
	local _tili_max = 10
	local _tili_cd = 50
	local _isforevet = 0
	if params.tili then
		_tili = params.tili	
	end
	if params.tili_max then
		_tili_max = params.tili_max	
	end
	if params.tili_cd then
		_tili_cd = params.tili_cd	
	end
	if params.isforever then
		_isforevet = params.isforever	
	end

	self:initEvent()
	--刚启动游戏初始化变量 ，暂时先设置在本地存储，到时候从服务器获取值
	local hasinit = CommonUtils:hasData(INIT_LOCAL)
    if not hasinit then
    	print("======TiLiManager:initTiLi 第一次初始化体力值=======")
		CommonUtils:saveData(INIT_LOCAL,1)
		CommonUtils:saveData(TILI_VALUE,_tili)
		CommonUtils:saveData(TILI_MAX_VALUE,_tili_max)
		CommonUtils:saveData(TILI_CD_VALUE,_tili_cd)
		CommonUtils:saveData(FOREVET_VALUE,_isforevet)
		CommonUtils:saveData(TILI_LAST_TIME,os.time())
    end
    print("======TiLiManager:initTiLi 初始化体力值=======")
    self.tiLi_ = CommonUtils:getIntData(TILI_VALUE)
    self.tiLiMax_ = CommonUtils:getIntData(TILI_MAX_VALUE)
    self.tiLiCD_ = CommonUtils:getIntData(TILI_CD_VALUE)
    self.isForever_ = CommonUtils:getIntData(FOREVET_VALUE)
    self.lastRecordTime_ = CommonUtils:getLongData(TILI_LAST_TIME)

    -- print(self.tiLi_,self.tiLiMax_,self.tiLiCD_,self.isForever_,self.lastRecordTime_)

 --test
 	-- self.tiLi_= 3
  --   self.ext_tiLi_ = 1
  --   self.tiLiMax_ = 10
  --   self.tiLiCD_ = 50
  --   self.isForever_ = 0
  --   self.lastRecordTime_ = os.time() - 65

    self.currentTime_ = self.tiLiCD_
    --调用initTiLi()前先将体力初始化
    self:initTiLi()
    self:RecoveryTiLi()

end

function TiLiManager:initEvent()
    gameDispatcher:addEventListener(EVENT_GOODS_UPDATE, self.UpdateData, self)

end

function TiLiManager:removeEvent()
    gameDispatcher:removeEventListener(EVENT_GOODS_UPDATE, self.UpdateData, self)
end

function TiLiManager:OnExit()
	self:removeEvent()
	if(nil ~= self.handle_)then
        scheduler.unscheduleGlobal(self.handle_)
    end
    self:save()
end

--设置当前体力值
function TiLiManager:setTiLi(tili)
	self.tiLi_ = tiLi
end

function TiLiManager:addExtTiLi(num)
	self.ext_tiLi_ = self.ext_tiLi_ + num
end

--获取当前体力值
function TiLiManager:getTiLi()
	return (self.tiLi_ + self.ext_tiLi_ )
end

--设置最大体力值
function TiLiManager:setTiLiMax(tiliMax)
	self.tiLiMax_ = tiliMax
end

--获取最大的体力值
function TiLiManager:getTiLiMax()
	return self.tiLiMax_
end

--设置多少时间恢复一个体力值
function TiLiManager:setTiLiCD(tilicd)
	self.tiLiCD_ = tilicd
end

--获取多少时间才恢复一个体力
function TiLiManager:getTiLiCD()
	return self.tiLiCD_
end

function TiLiManager:UpdateData()
	self.ext_tiLi_ = gameData:getGoodsCount(GOODS_TILI)
	print("=====TiLiManager:UpdateData()=====ext_tiLi_=====",self.ext_tiLi_)
	gameDispatcher:dispatchEvent(BaseEvent:new(UPDATE_TILI_EVENT))
end

--体力值恢复
function TiLiManager:RecoveryTiLi()
	local function tick()
		if self.tiLi_ < self.tiLiMax_ then
			if os.time() >= self.lastRecordTime_  then
				if os.difftime(os.time(),self.lastRecordTime_) >= self.tiLiCD_ then
					self.tiLi_ = self.tiLi_ + 1
    				self.currentTime_ = self.tiLiCD_
					self:RecordTime(os.time())
					self:RecordCurrentTiLi()
					print("=========增加一个体力值=额外奖励的体力值=====",self.tiLi_,self.ext_tiLi_)
					--更新体力值
					gameDispatcher:dispatchEvent(BaseEvent:new(UPDATE_TILI_EVENT))
				end
			else
				print("被人刻意篡改本地时间")
			end
		end	
	end

    if(nil ~= self.handle_)then
        scheduler.unscheduleGlobal(self.handle_)
    end
    self.handle_ = scheduler.scheduleGlobal(tick,GAME_FPS)
end

--退出游戏需要调用 记录最后一次的时间
function TiLiManager:RecordCurrentTiLi()
	CommonUtils:saveData(TILI_VALUE,self.tiLi_)
end

function TiLiManager:RecordTime(time)
	CommonUtils:saveData(TILI_LAST_TIME,time)
    self.lastRecordTime_ = time
end

--使用体力值
function TiLiManager:UseTiLi()
	if self.isForever_ == 1 then
		return true
	else
		self.ext_tiLi_ = gameData:getGoodsCount(GOODS_TILI)
		print("===UseTiLi()======",self.ext_tiLi_)
		if self.ext_tiLi_ > 0 then
			gameData:setGoodsCount(GOODS_TILI,self.ext_tiLi_ - 1)
	    	self:RecordCurrentTiLi()
		else
			if self.tiLi_ > 0 then
				self.tiLi_ = self.tiLi_ - 1
	    		self:RecordCurrentTiLi()
	    		self:RecordTime(os.time())
				return true
			else
				--提示体力不足
				return false
			end
		end
	end
end

function TiLiManager:CheckIsEnough()
	if self:getTiLi() > 0 then
		return true
	else
		gameDispatcher:dispatchEvent(BaseEvent:new(TILI_NOT_ENOUGH_EVENT))
		return false
	end
end

--初始化体力
function TiLiManager:initTiLi()
	if self.tiLi_ < self.tiLiMax_ then
		if os.time() >= self.lastRecordTime_  then
			local nowtime = os.time()
			local tempTime = os.difftime(nowtime,self.lastRecordTime_)
			local tempTiLi = math.floor(tempTime / self.tiLiCD_) 
			--当前时间为  当前时间和上次记录的时间换算成体力之后的当前时间
			self:RecordTime(nowtime - math.floor(tempTime % self.tiLiCD_))

			self.tiLi_ = self.tiLi_ + tempTiLi
			if self.tiLi_ > self.tiLiMax_ then
				self.tiLi_  = self.tiLiMax_
			end
    		self:save()
		else
			print("被人刻意篡改本地时间")
		end
	end
end

--显示时间倒计时
function TiLiManager:getShowTime()
	if self.isForever_ == 1 then
   	 	return ""
	end
	local timeStr = nil
	if self.tiLi_ < self.tiLiMax_  then
		local temptime = os.difftime(os.time(),self.lastRecordTime_)
		local time = self.currentTime_ - temptime
		-- print("========TiLiManager:getShowTime========",time ,self.currentTime_ , temptime)
		--时间 格式化成 时分秒 0:00:00
		local hour = math.floor(time / 3600.0)
	    local min = math.floor((time % 3600.0) / 60.0)
	    local secend = math.floor(time % 60)
	    timeStr = string.format("%02d:%02d",min,secend)
	    if hour >= 1 then
	    	timeStr = string.format("%d:%02d:%02d",hour,min,secend)
	    end
	else
		timeStr = ""
	end
    return timeStr
end

function TiLiManager:save()
	CommonUtils:saveData(TILI_VALUE,self.tiLi_)
	CommonUtils:saveData(TILI_MAX_VALUE,self.tiLiMax_)
	CommonUtils:saveData(TILI_CD_VALUE,self.tiLiCD_)
	CommonUtils:saveData(FOREVET_VALUE,self.isForever_)
	CommonUtils:saveData(TILI_LAST_TIME,os.time())
end