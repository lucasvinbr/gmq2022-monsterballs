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
    -- Create player character
    local watcherEyesNode = Scene_:GetChild("cameraSpawn"):GetChild("watcher"):GetChild("watcher_eyesPoint")
    --GameCameraNode:SetParent(watcherEyesNode) this seems to crash
    GameCameraNode.worldPosition = watcherEyesNode.worldPosition
    GameCameraNode.worldRotation = watcherEyesNode.worldRotation



    -- local ballSpawnsParent = Scene_:GetChild("monsterSpawns")
    -- local randomBallSpawn = ballSpawnsParent:GetChild(RandomInt(1, ballSpawnsParent:GetNumChildren(false)))

    world.CreateCharacter(GameCameraNode.worldPosition + Vector3.RIGHT * 8.0)
end


function world.CreateCharacter(position)
    -- local playerXml = cache:GetResource("XMLFile", "Data/Objects/mballs/mball.xml")
    -- world.PlayerNode = world.DynamicContentParent:CreateChild("PlayerBall")
    world.PlayerNode = Scene_:InstantiateXML("Data/Objects/mballs/mball.xml", position, Quaternion.IDENTITY)
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
            gameAudio.PlayOneShotSound("Music/duality/gameplaytransition.ogg", 0.65, 0)
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

function world.SpawnEffect(node)
    local particleNode = Scene_:CreateChild("Emitter")
    particleNode:SetPosition2D(node.position)
    particleNode:SetScale(node.scale.x * 3)
    ---@type ParticleEmitter2D
    local particleEmitter = particleNode:CreateComponent("ParticleEmitter2D")
    particleEmitter:SetLayer(2)
    particleEmitter.effect = cache:GetResource("ParticleEffect2D", "Urho2D/duality/folhas.pex")
    
    coroutine.start(function()
        coroutine.sleep(1.5)
        particleNode:Remove()
    end)
end


---@param from Vector2
---@param to Vector2
---@return number
function world.DistanceBetween(from, to)

    ---@type Vector2
    local subtractedVec = to - from

    return subtractedVec:Length()

end

---@param repulsors table
---@param extraPaddingFromBounds number
---@return Vector2
function world.GetRandomPositionInWorld(repulsors, extraPaddingFromBounds)

    if extraPaddingFromBounds == nil then
        extraPaddingFromBounds = 0.0
    end

    local attempts = 0
    local padding = 0.1
    local pickedPos = Vector2(
        Random((-WORLD_BOUNDS_UNSCALED.x) + padding + extraPaddingFromBounds, (WORLD_BOUNDS_UNSCALED.x) - padding - extraPaddingFromBounds),
        Random((-WORLD_BOUNDS_UNSCALED.y) + padding + extraPaddingFromBounds, (WORLD_BOUNDS_UNSCALED.y) - padding - extraPaddingFromBounds)
    )
    local positionIsValid = true

    while attempts < 10 do
        
        positionIsValid = true

        if repulsors ~= nil then
            for _, repulsor in pairs(repulsors) do
                if world.DistanceBetween(repulsor.position2D, pickedPos) < 1.25 then
                    positionIsValid = false
                    break
                end
            end
        end

        if positionIsValid then
            break
        else
            pickedPos = Vector2(Random(-WORLD_BOUNDS_UNSCALED.x, WORLD_BOUNDS_UNSCALED.x), Random(-WORLD_BOUNDS_UNSCALED.y, WORLD_BOUNDS_UNSCALED.y))
            attempts = attempts + 1
        end

    end

    return pickedPos
end

function world.SaveScene(initial)
    local filename = DemoFilename
    if not initial then
        filename = DemoFilename .. "InGame"
    end

    Scene_:SaveXML(fileSystem:GetProgramDir() .. "Data/Scenes/" .. filename .. ".xml")
end

return world