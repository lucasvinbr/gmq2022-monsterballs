---@class Watcher : LuaScriptObject
---@field eyesNode Node
---@field desiredRotation Quaternion

local MIN_INTERVAL_CHANGEVIEW = 8.0
local MAX_INTERVAL_CHANGEVIEW = 14.0

-- Character script object class
---@type Watcher
Watcher = ScriptObject()

Watcher.__index = Watcher

function Watcher:Start()
    self.canMove = true

    self.eyesNode = self.node:GetChild("watcher_eyesPoint")

    self.timeSinceLastViewChange = MAX_INTERVAL_CHANGEVIEW
    self.timeNextViewChange = Random(MIN_INTERVAL_CHANGEVIEW, MAX_INTERVAL_CHANGEVIEW)

    self.desiredRotation = self.eyesNode.rotation

    self:SubscribeToEvent(self.node, "NodeCollisionStart", "Watcher:HandleCollisionStart")
end

function Watcher:Update(timeStep)

    self.timeSinceLastViewChange = self.timeSinceLastViewChange + timeStep

    if self.canMove and self.timeSinceLastViewChange > self.timeNextViewChange then
        self.timeSinceLastViewChange = 0.0
        self.timeNextViewChange = Random(MIN_INTERVAL_CHANGEVIEW, MAX_INTERVAL_CHANGEVIEW)
        self.desiredRotation:FromAngleAxis(Random(0, 360), Vector3.UP)
    end

    if self.canMove then
        self.eyesNode.rotation = self.eyesNode.rotation:Slerp(self.desiredRotation, timeStep)

        GameCameraNode.worldPosition = self.eyesNode.worldPosition
        GameCameraNode.worldRotation = self.eyesNode.worldRotation
    end


end

function Watcher:HandleCollisionStart(eventType, eventData)

    if CurGameState ~= GAMESTATE_PLAYING then return end

    log:Write(LOG_DEBUG, "someone got the watcher")
    CurGameState = GAMESTATE_ENDING
end
