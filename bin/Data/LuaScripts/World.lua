local uiManager = require "LuaScripts/ui/UI_Manager"
local gameAudio = require "LuaScripts/Audio"

local world = {}

world.DoneSettingUp = false

---@type Node
world.PlayerNode = nil

---@type Player
world.PlayerScript = nil

---@type Node
world.DynamicContentParent = nil


function world.CreateDynamicContent()

    CurGameState = GAMESTATE_STARTING

    world.DynamicContentParent = Scene_:CreateChild("DynamicContent")

    -- set up watcher
    local watcherNode = Scene_:GetChild("cameraSpawn"):GetChild("watcher")
    watcherNode:CreateScriptObject("Watcher")

    local ballSpawnsParent = Scene_:GetChild("monsterSpawns")
    local randomBallSpawn = ballSpawnsParent:GetChild(RandomInt(1, ballSpawnsParent:GetNumChildren(false)))
    -- Create player character
    world.CreateCharacter(randomBallSpawn.worldPosition)
end


function world.CreateCharacter(position)
    -- local playerXml = cache:GetResource("XMLFile", "Data/Objects/mballs/mball.xml")
    -- world.PlayerNode = world.DynamicContentParent:CreateChild("PlayerBall")
    world.PlayerNode = Scene_:InstantiateXML(fileSystem:GetProgramDir().."Data/Objects/mballs/mball.xml", position, Quaternion.IDENTITY)
    world.PlayerNode:SetParent(world.DynamicContentParent)

    ---@type Player
    world.PlayerScript = world.PlayerNode:CreateScriptObject("Player") -- Create a ScriptObject to handle character behavior

end


---@param spawnPos Vector2
---@param isInFlippedWorld boolean
function world.CreateEnemy(spawnPos, isInFlippedWorld)

    local node = world.DynamicContentParent:CreateChild("Enemy")
    node.position2D = spawnPos

    ---@type Enemy
    local enemyScript = node:CreateScriptObject("Enemy")

    enemyScript:SetupFlipDependentData(isInFlippedWorld)

    return node
end


---@param victory boolean
function world.EndGame(victory)
    if CurGameState ~= GAMESTATE_ENDED then
        CurGameState = GAMESTATE_ENDED

        world.PlayerScript.canCountTime = false
        world.PlayerScript.canMove = false

        uiManager.HideUI("Game")

        ---@type EndGameScreenData
        local gameEndData = {
            hasWon = victory
        }

        if victory then
            TimesWon = TimesWon + 1
        else
            gameAudio.PlayOneShotSoundWithFreqVariation("Music/duality/gameplaytransition.ogg", 0.65, 0)
        end

        uiManager.ShowUI("Endgame", gameEndData)
        
    end
end


function world.Cleanup()
    if world.DynamicContentParent ~= nil then
        world.DynamicContentParent:Remove()
        world.DynamicContentParent = nil

        CurGameState = GAMESTATE_ENDED
    end
end

function world.SpawnOneShotParticleEffect(worldPosition, effectPath)
    local particleNode = Scene_:CreateChild("Emitter")
    particleNode:SetPosition(worldPosition)
    ---@type ParticleEmitter
    local particleEmitter = particleNode:CreateComponent("ParticleEmitter")
    particleEmitter:SetAutoRemoveMode(REMOVE_NODE)
    particleEmitter.effect = cache:GetResource("ParticleEffect", effectPath)
    
    
    coroutine.start(function()
        coroutine.sleep(particleEmitter.effect:GetMinTimeToLive())
        particleEmitter:SetEmitting(false)
    end)

    return particleEmitter
end


---@param from Vector2
---@param to Vector2
---@return number
function world.DistanceBetween(from, to)

    ---@type Vector2
    local subtractedVec = to - from

    return subtractedVec:Length()

end

function world.SaveScene(initial)
    local filename = DemoFilename
    if not initial then
        filename = DemoFilename .. "InGame"
    end

    Scene_:SaveXML(fileSystem:GetProgramDir() .. "Data/Scenes/" .. filename .. ".xml")
end

return world