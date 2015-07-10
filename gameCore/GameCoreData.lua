--
-- Author: ffl
-- Date: 2015-07-07 20:33:14
--


local GameCoreData = class("GameCoreData", function()
    local temp = {}

    temp.data = {}
    temp.data.soundToggle = true
    temp.data.musicToggle = true

    return temp
end)

function GameCoreData:init()
    self.data.soundToggle = true
    self.data.musicToggle = true

    self:save()
end

function GameCoreData:save()
    GameState.save(self.data)
end

function GameCoreData:load()
    local stateListener = function(event)
        if event.errorCode then
            print("ERROR, load:" .. event.errorCode)
            if(GameState.ERROR_STATE_FILE_NOT_FOUND == event.errorCode)then
                print("--------第一次初始化gamestate.......")
                gameCoreData:init()
            end
            return
        end

        if "load" == event.name then
            local str = crypto.decryptXXTEA(event.values.data, "scertKey")
            local tempData = json.decode(str)
            if(nil == tempData)then
                print("--------第一次初始化gamestate.......")
                gameData:init()
            else
                -- gameData.data = tempData
                gg_mergeTableA2B(tempData,gameData.data)
                print("GameState.loaded()********************************")

                gameData:load()
            end
        elseif "save" == event.name then
            local str = json.encode(event.values)
            if str then
                str = crypto.encryptXXTEA(str, "scertKey")
                returnValue = {data = str}
            else
                print("ERROR, encode fail")
                return
            end

            return {data = str}
        end
    end

    GameState.init(stateListener, "gg_core_data.dat", SEED_CRYPTO)
    GameState.load()
end

gameCoreData = GameCoreData:new()