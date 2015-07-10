--
-- Date: 2015-07-07 14:19:05
--


EffectManager = class("EffectManager", function()
    local temp = {}

    return temp
end)


 function EffectManager.setAnimationCacheByTempl(tempId)
    local tem =  animTemplateList:getTemplate(tempId)
    -- dump(tem)
    EffectManager.setAnimationCache(tem.name,tem.plist,tem.png,tem.pattern,tem.start,tem.length,tem.frame)
 end

--参数：动画名字，图集名 ，图片名 ，字串 ，起始值 ，长度， 帧率 
function EffectManager.setAnimationCache(animationName,plist,png,pattern,start,len,speed)
    display.addSpriteFrames(plist, png)
    local frames = display.newFrames(pattern, start, len)
    if(nil ~= frames)then
        if(nil == animation)then
            animation = display.newAnimation(frames, 1/speed*1.0)
        end
        display.setAnimationCache(animationName, animation) 
    end
end

--根据缓存中的 动画名字 来获取动画
function EffectManager.getAnimation(animationName)
    return display.getAnimationCache(animationName)
end

--根据模板表中的 ID 获取 动画
function EffectManager.getAnimationByTempl(tempId)
    local tem =  animTemplateList:getTemplate(tempId)
    return display.getAnimationCache(tem.name)
end


--从模板表中获取粒子效果
function EffectManager.getPartical(plist)
    local particleSys = cc.ParticleSystemQuad:create(plist)
    particleSys:setPosition(0,0)
    particleSys:setPositionType(cc.POSITION_TYPE_GROUPED)
    return particleSys
end

--根据动画名字 删除 动画缓存
function EffectManager.removeAnimationCache(animationName)
    display.removeAnimationCache(animationName)
end

--根据模板表中的 ID 删除 动画缓存
function EffectManager.removeAnimationCache(tempId)
    local tem =  animTemplateList:getTemplate(tempId)
    display.removeAnimationCache(tem.name)
end