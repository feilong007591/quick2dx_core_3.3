--
-- Author: Your Name
-- Date: 2015-05-12 20:25:49
--
--全局方法定义

--cc.Director:getInstance():getEventDispatcher().addCustomEventListener
function addCustomEventListener(eventName,callback)
    cc.Director:getInstance():getEventDispatcher().addCustomEventListener(eventName,callback)
end

--ccui.Button添加点击事件
function addButtonClickHandler(button,callback,playSound)
    if(nil == playSound)then
        playSound = true
    else
        playSound = false
    end

    local function touchHandler(obj,type)
        if type == ccui.TouchEventType.ended then
            if(playSound)then
                audio.playSound(MUSIC_BTN_SND, false)
            end
            callback()
        end
    end
    button:addTouchEventListener(touchHandler)
end

--ccui.Button  callback（tagnum） 带参数 添加点击事件
function addButtonClickHandler2(button,callback,playSound)
    if(nil == playSound)then
        playSound = true
    else
        playSound = false
    end
    local function touchHandler(obj,type)
        if type == ccui.TouchEventType.ended then
            if(playSound)then
                audio.playSound(MUSIC_BTN_SND, false)
            end
            local tagnum = obj:getTag()
            callback(tagnum)
        end
    end
    button:addTouchEventListener(touchHandler)
end

--为Node添加点击事件
function addNodeClickHandler(node,callback)
    -- 允许node接受触摸事件
    node:setTouchEnabled(true)
    -- 注册触摸事件
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        -- event.name 是触摸事件的状态：began, moved, ended, cancelled
        -- event.x, event.y 是触摸点当前位置
        -- event.prevX, event.prevY 是触摸点之前的位置
        -- printf("sprite: %s x,y: %0.2f, %0.2f",event.name, event.x, event.y)
        -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
        -- 则必须返回 true
        if event.name == "began" then
            return true
        elseif event.name == "ended" then
            callback(node)
        end
    end)
end

--获取特效
function gg_getEffect()
    return nil
end


--表浅赋值
function gg_mergeTableA2B(tbA,tbB)
    for m,v in pairs(tbA) do
        tbB[m] = v
    end
end

--获取数组索引
function gg_getIndex(tbl,val)
    for i=1,#tbl do
        if(val == tbl[i])then
            return i
        end
    end
    return -1
end

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(不含有空串)
function gg_string_split(str, split_char,removeEmpty)
    if(nil == removeEmpty)then
        removeEmpty = true
    end
    local sub_str_tab = {};
    -- print(str,split_char)
    while (true) do
        local pos = string.find(str, split_char);
        -- print("pos:",pos)
        if (not pos) then
            if(str ~= "" or not removeEmpty)then
                sub_str_tab[#sub_str_tab + 1] = str;
            end
            break
        end
        local sub_str = string.sub(str, 1, pos - 1);
        if(sub_str ~= ""  or not removeEmpty)then
            sub_str_tab[#sub_str_tab + 1] = sub_str;
        end
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(不含有空串)
function gg_string_split_2number(str, split_char,removeEmpty)
    if(nil == removeEmpty)then
        removeEmpty = true
    end
    local sub_str_tab = gg_string_split(str, split_char)
    for i=1,#sub_str_tab do
        local content = sub_str_tab[i]
        if(content ~= "" or not removeEmpty)then
            sub_str_tab[i] = tonumber(content)
        end
    end
    return sub_str_tab;
end


function gg_string_join(arr,join_str)
    local result = ""
    for i=1,#arr do
        if(i == #arr)then
            result = result .. arr[i]
        else
            result = result .. arr[i] .. join_str
        end
        
    end
    return result
end

-- /** 
-- * 检测两个矩形是否碰撞 
-- * @return 
-- */  
function isCollsionWithRect( x1,  y1,  w1,  h1,  x2, y2,  w2,  h2)
    if (x1 >= x2 and  x1 >= x2 + w2) then
        return false
    elseif (x1 <= x2 and  x1 + w1 <= x2) then  
        return false
    elseif (y1 >= y2 and y1 >= y2 + h2) then 
        return false
    elseif (y1 <= y2 and y1 + h1 <= y2) then 
        return false
    end
    return true;  
end

--格式化时间串，返回00'00
function formatTickStr(tickCount)
    local secend = math.floor(tickCount / 60.0)
    local ms = math.floor(((tickCount % 60) / 60.0) * 100)
    local timeStr = string.format("%02d'%02d",secend,ms)
    return timeStr
end