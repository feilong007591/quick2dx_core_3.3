DateUtils = class("DateUtils",function(self)
    local temp = {}
    setmetatable(temp, self)
    self.__index = self
    
    temp.millsecondsOfDay = 24 * 3600 * 1000
    
    return temp
end)

--根据当前时区 将秒数转换为日期
--param seconds:int return date
--year(4位),month(1-12),day(1-31),hour(0-23),min(0-59),sec(0-61),wday(1-7,周日为1),yday(年内天数)
function DateUtils:getDate(seconds)
    local fixSeconds = seconds + globalData.systemDateInfo.timeZone * 3600
    return os.date("*t",fixSeconds)
end

--根据起始结束时间戳获取间隔天数(不足1天算0天)(hours为时区，有时候需要判断0点整点变化的情况)
--param startDate:number endDate:number return int
function DateUtils:getBetweenTimeDay(startDate,endDate,hours)
    if(hours == nil) then hours = 0 end
    local startDay = math.floor((startDate + hours * 3600000) / self.millsecondsOfDay)
    local endDay = math.floor((endDate + hours * 3600000)/ self.millsecondsOfDay)
    return endDay - startDay
end

--根据时间戳判断是当天的多少毫秒
function DateUtils:getTodayTime(time)
	return time % self.millsecondsOfDay
end

--根据起始结束时间戳获取间隔日期(时分秒,不能end小于start)
--param startDate:number endDate:number return date
--hour(0-23),min(0-59),sec(0-59),millisec(0-999)
function DateUtils:getCounterInfo(startDate,endDate)
    local result = {}
    local targetTimer = endDate - startDate
    result.hour = self:millisecondsToHours(targetTimer)
    result.min = self:secondsToMinutes(self:millsecondsToSecond(targetTimer)) - self:hoursToMinutes(result.hour)
    result.sec = self:millsecondsToSecond(targetTimer) - self:minutesToSeconds((self:hoursToMinutes(result.hour) + result.min))
    result.millisec = targetTimer - self:secondsToMillSeconds((self:minutesToSeconds((self:hoursToMinutes(result.hour) + result.min)) + result.sec))
  return result
end

--毫秒转天数
--param milliseconds:number return int
function DateUtils:millisecondsToDays(milliseconds)
    return self:hoursToDays(self:minutesToHours(self:secondsToMinutes(self:millsecondsToSecond(milliseconds))))
end

--毫秒转小时
--param milliseconds:number return int
function DateUtils:millisecondsToHours(milliseconds)
    return self:minutesToHours(self:secondsToMinutes(self:millsecondsToSecond(milliseconds)))
end

--毫秒转分钟
--param milliseconds:number return int
function DateUtils:millsecondsToMinutes(milliseconds)
    return self:secondsToMinutes(self:millsecondsToSecond(milliseconds))
end

--毫秒转秒
--param milliseconds:number return int
function DateUtils:millsecondsToSecond(millseconds)
    return math.floor(millseconds / 1000)
end

--秒转分钟
--param seconds:int return int
function DateUtils:secondsToMinutes(seconds)
    return math.floor(seconds / 60)
end

--分钟转小时
--param minutes:int return int
function DateUtils:minutesToHours(minutes)
    return math.floor(minutes / 60)
end

--小时转天数
--param hours:int return int
function DateUtils:hoursToDays(hours)
    return math.floor(hours / 24)
end

--天数转小时
--param days:int return int
function DateUtils:daysToHours(days)
    return days * 24
end

--小时转分钟
--param hours:int return int
function DateUtils:hoursToMinutes(hours)
    return hours * 60
end

--分钟转秒
--param minutes:int return int
function DateUtils:minutesToSeconds(minutes)
    return minutes * 60
end

--秒转毫秒
--param seconds:int return number
function DateUtils:secondsToMillSeconds(seconds)
    return seconds * 1000
end
    
--根据当前时区 将秒数转换为日期并返回hh:mm:ss
--param seconds:int return string
function DateUtils:secondsToDateString(seconds)
    -- local time = self:getDate(seconds)
    local time = {}
    time.hour = (math.floor(seconds / 3600) + globalData.systemDateInfo.timeZone) % 24 
    time.min = math.floor(seconds / 60) % 60
    time.sec = seconds % 60
    return self:singleToDouble(time.hour)..":"..self:singleToDouble(time.min)..":"..self:singleToDouble(time.sec)
end

--将秒数转换成XX分XX秒  副本倒计时用到
function DateUtils:secondsToDateString2(seconds)
    return self:singleToDouble(math.floor(seconds / 60)).."分"..self:singleToDouble(seconds % 60).."秒"
end

--将秒数转换成XX:XX  活动面板用到
function DateUtils:secondsToDateString3(seconds)
	seconds = math.floor(seconds / 60)
    return self:singleToDouble(math.floor(seconds / 60))..":"..self:singleToDouble(seconds % 60)
end

--返回二个数，分和秒
function DateUtils:secondsToMinAndSec(seconds)
    return math.floor(seconds / 60),seconds % 60
end
--将个数转换为两位数格式0~9->00~09 
--param num:int return string
function DateUtils:singleToDouble(num)
    if(num > 9) then
        return num
    else
        return "0"..num
    end
end


--获取指定年月的天数和第一天的星期
function DateUtils:getDays(year, month)        
    --31天的月份
    local bigmonth = {1,3,5,7,8,10,12}
    local week = os.date("*t", os.time{year = year, month = month, day = 1})["wday"]
    if month == 2 then
        if year % 4 == 0 or (year % 400 == 0 and year % 400 ~= 0) then
            return 29, week
        else
            return 28, week
        end
    elseif globalManager.commonUtils:getIndexOfTable(bigmonth,month) ~= -1 then
        return 31, week
    else
        return 30, week
    end
end