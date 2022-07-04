local uiManager = require "LuaScripts/ui/UI_Manager"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"

---@class Player : LuaScriptObject
---@field body RigidBody
---@field timeBar ProgressBar

local hitSounds = {
    "Sounds/mballs/hit1.ogg",
    "Sounds/mballs/hit2.ogg",
    "Sounds/mballs/hit3.ogg",
    "Sounds/mballs/hit4.ogg",
    "Sounds/mballs/hit5.ogg",
}

local hitHeavySounds = {
    "Sounds/mballs/hit_heavy.ogg",
}

local MOVE_SPEED = 500.0

local INTERVAL_HOWL = 4.0

-- Character script object class
---@type Player
Player = ScriptObject()

Player.__index = Player

function Player:Start()
    self.canCountTime = false
    self.canMove = true

    self.timeSinceLastHowl = INTERVAL_HOWL

    self.timeBar = nil

    self.body = self.node:GetComponent("RigidBody", false)
    self.body:SetMass(0.5)
    self.body:Activate()

    self:SubscribeToEvent(self.node, "NodeCollisionStart", "Player:HandleCollisionStart")

    log:Write(LOG_DEBUG, self.node.worldPosition:ToString())
end

function Player:Update(timeStep)

    self.timeSinceLastHowl = self.timeSinceLastHowl + timeStep

    if self.timeBar then
        self.timeBar:SetValue(1.0 - (self.timeSinceLastHowl / INTERVAL_HOWL))
    end

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

    if self.canMove and self.timeSinceLastHowl > INTERVAL_HOWL and input:GetKeyDown(KEY_SPACE) then
        -- do the howl
        self.timeSinceLastHowl = 0.0
        gameAudio.PlayOneShotSoundWithFreqVariation("Sounds/mballs/hit_heavy.ogg", 1.5, 2000, true, self.node)
        gameAudio.PlayOneShotSoundWithFreqVariation("Sounds/mballs/basicTurbo.ogg", 1.5, 2000, true, self.node)
        world.SpawnOneShotParticleEffect(self.node.worldPosition,"Particle/mballs/howl.xml")
    end

    -- Move
    if not moveDir:Equals(Vector3.ZERO) and self.canMove then
        self.body:ApplyTorque(moveDir * timeStep)
    end
    
end

function Player:HandleCollisionStart(eventType, eventData)

    if CurGameState ~= GAMESTATE_PLAYING then return end

    local velocity = self.body.linearVelocity:Length()

    gameAudio.PlayOneShotSoundWithFrequency(hitSounds[RandomInt(#hitSounds) + 1],
     1.0,
      20050 + Lerp(0, 20000, velocity / 20.0),
       true,
        self.node)
end
