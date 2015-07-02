--
-- Author: ffl
-- Date: 2015-05-25 16:21:18
--

------------------------------------------------------
-- 列表基类
------------------------------------------------------
BaseTemplate = class("BaseTemplate", function()
    local temp = {}
    temp.templateId = 0 --模板ID
    return temp
end)

function BaseTemplate:ctor()
    self:initData()
end

function BaseTemplate:initData()

end

function BaseTemplate:parse(bytes)
    self.templateId = bytes:readInt()
end

function BaseTemplate:parseCustom(bytes)
    
end

------------------------------------------------------
-- 列表基类
------------------------------------------------------
BaseTemplateList = class("BaseTemplateList", function()
    local temp = {}
    temp.list = {} --模板表列表

    temp._templateClass = nil --模板类

    return temp
end)

function BaseTemplateList:setTemplate(templateClass)
    self._templateClass = templateClass
end

--加载模板表
function BaseTemplateList:loadFile(fileName)
    print("模板表初始化：",fileName)
    if(nil == self._templateClass)then
        printError("temlatelist err: no template....")
        return
    end
    local bytes = BinaryUtils:getBytes(fileName);
    local len = bytes:readInt()
    for i=1,len do
        local template = self._templateClass:new()
        template:parse(bytes)
        table.insert(self.list,template)
    end
end

--根据模板表ID获取模板表
function BaseTemplateList:getTemplate(templateId)
    for i=1,#self.list do
        local template = self.list[i]
        if(templateId == template.templateId)then
            return template
        end
    end
    print("====================",templateId)
    printError("模板表未找到：id=%d", templateId)
    return nil
end

--根据模板表索引获取模板表
function BaseTemplateList:getTemplateByIndex(i)
    return self.list[i]
end