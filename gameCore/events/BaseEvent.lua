BaseEvent = class("BaseEvent",function(self,aType,aTarget,aData)
  local be = {}
  setmetatable(be,BaseEvent)
  be.type = aType
  be.target = aTarget
  be.data = aData
  be.stopImmediately = false

  return be
end)