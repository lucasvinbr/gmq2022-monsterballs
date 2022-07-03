local uiManager = require "LuaScripts/ui/UI_Manager"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"

---@class Player : LuaScriptObject
---@field body RigidBody

local MOVE_SPEED = 500.0

-- Character script object class
---@type Player
Player = ScriptObject()

Player.__index = Player

function Player:Start()
    self.canCountTime = false
    self.canMove = true

    ---@type ProgressBar
    self.timeBar = nil

    self.body = self.node:GetComponent("RigidBody", false)
    self.body:SetMass(0.5)
    self.body:Activate()

    self:SubscribeToEvent(self.node, "NodeCollisionStart", "Player:HandleCollisionStart")

end

function Player:Update(timeStep)

    -- Set direction
    ---@type Vector3
    local moveDir = Vector3.ZERO -- Reset
    local speedX = MOVE_SPEED
    local speedY = speedX

    if input:GetKeyDown(KEY_LEFT) or input:GetKeyDown(KEY_A) then
        moveDir = moveDir + Vector3.LEFT * speedX
    end
    if input:GetKeyDown(KEY_RIGHT) or input:GetKeyDown(KEY_D) then
        moveDir = moveDir + Vector3.RIGHT * speedX
    end

    if input:GetKeyDown(KEY_UP) or input:GetKeyDown(KEY_W) then
        moveDir = moveDir + Vector3.FORWARD * speedY
    end
    if input:GetKeyDown(KEY_DOWN) or input:GetKeyDown(KEY_S) then
        moveDir = moveDir + Vector3.BACK * speedY
    end

    -- Move
    if not moveDir:Equals(Vector3.ZERO) and self.canMove then
        log:Write(LOG_DEBUG, "use the force porra")
        self.body:ApplyTorque(moveDir * timeStep)
    end
    
end

function Player:HandleCollisionStart(eventType, eventData)

    if CurGameState ~= GAMESTATE_PLAYING then return end

    ---@type Node
    local otherNode = eventData["OtherNode"]:GetPtr("Node")

    log:Write(LOG_DEBUG, otherNode:GetName())
    gameAudio.PlayOneShotSound("Sounds/mballs/morte.ogg", 1.0, 200, true, self.node)
end