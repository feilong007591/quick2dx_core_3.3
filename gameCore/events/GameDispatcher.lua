--##globalManager.gameDispatcher
gameDispatcher = nil
GameDispatcher = class("GameDispatcher",function()
    local gd = {}
    gd._dispatcher = EventDispatcher:new()
    return gd
end)

function GameDispatcher:addEventListener(type,listener,target)
    self._dispatcher:addEventListener(type,listener,target)
end

function GameDispatcher:removeEventListener(type,listener,target)
    self._dispatcher:removeEventListener(type,listener,target)
end

function GameDispatcher:dispatchEvent(evt,data)
    if("table" == type(evt))then
        self._dispatcher:dispatchEvent(evt)
    elseif("string" == type(evt))then
        local newEvt = BaseEvent:new(evt)
        newEvt.data = data
        self._dispatcher:dispatchEvent(newEvt)
    else
        printError("事件类型错误:", evt)
    end
end

