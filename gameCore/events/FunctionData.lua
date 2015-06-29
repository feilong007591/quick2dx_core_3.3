FunctionData = class("FunctionData",function(self,func,target)
    local fn = {}
    setmetatable(fn, FunctionData)
    fn.func = func
    fn.target = target
    --是否标记为删除
    fn.removeFlag = false
    return fn
end)