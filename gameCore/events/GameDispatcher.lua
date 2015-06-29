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

function GameDispatcher:dispatchEvent(evt)
    self._dispatcher:dispatchEvent(evt)
end

