
gameDispatcher = nil
--自定义事件机制
EventDispatcher = class("EventDispatcher",function()
  local ed = {}
  --map<int,vector<FunctionData>>
  ed._listeners = {}
  return ed
end)
  
--param type:string,listener:function
function EventDispatcher:addEventListener(type,listener,target)
  if(type == nil)then
      printError("EventDispatcher：type为空")
      return
  end
  if(listener == nil)then
      printError("EventDispatcher：listener为空")
      return 
  end

  if(self:hasListener(type,listener,target) == -1) then
    if(self._listeners[type] == nil) then
      self._listeners[type] = {}
    end
    local fd = FunctionData:new(listener,target) 
    table.insert(self._listeners[type],fd)
  end
end

--param type:string,listener:function
function EventDispatcher:removeEventListener(type,listener,target)
  if self._listeners == nil then return end
  local list = self._listeners[type]
  if(list ~= nil) then
    local len = table.getn(list)
    for i = 1,len,1 do
      if(list[i].func == listener and list[i].target == target) then
        table.remove(list,i)
        break
      end
    end
  end
end

--param evt:BaseEvent
function EventDispatcher:dispatchEvent(evt)
  if self._listeners == nil then return end
  local event = evt.type
  local list = self._listeners[event]
  if(list ~= nil) then
    local len = table.getn(list)
    for i = 1,len,1 do
        local fd = list[i]
        if(nil == fd.target)then
            fd.func(evt)
        else
            fd.func(fd.target,evt)
        end
        
        if(evt.stopImmediately == true) then
            break
        end
    end 
  end
end

function EventDispatcher:hasListener(type,listener,target)
  local list = self._listeners[type]
  if(list ~= nil) then
    local len = table.getn(list)
    for i = 1,len,1 do
      if(list[i].func == listener and list[i].target == target) then
        return i
      end
    end
  end
  return -1
end

function EventDispatcher:dispose()
    self._listeners = nil
end

return EventDispatcher