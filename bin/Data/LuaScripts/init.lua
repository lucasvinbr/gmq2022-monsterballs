GameDebug = require "LuaScripts/Debug"
local uiManager = require "LuaScripts/ui/UI_Manager"
local uiDefs = require "LuaScripts/ui/UI_Definitions"
local mouseConfig = require "LuaScripts/Mouse"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"
require "LuaScripts/Player"
require "LuaScripts/Watcher"


COLMASK_WORLD = 1
COLMASK_WORLD_FLIPPED = 2
COLMASK_PLAYER = 4
COLMASK_PLAYER_FLIPPED = 8
COLMASK_OBJS = 16
COLMASK_OBJS_FLIPPED = 32

TAG_PLAYER = "player"
TAG_ENEMY = "enemy"
TAG_WIN_OBJ = "winnerobj"

GAMESTATE_ENDED = 1
GAMESTATE_STARTING = 2
GAMESTATE_PLAYING = 4
GAMESTATE_ENDING = 8

CurGameState = GAMESTATE_ENDED

DemoFilename = "mballs"



---@type Scene
Scene_ = nil -- Scene

---@type Node
GameCameraNode = nil -- Camera scene node

---@type Camera
GameCamera = nil

function Start()
  SetRandomSeed(os.time() % 1000)
  -- Set custom window Title & Icon
  SetWindowTitleAndIcon()

  -- Execute debug stuff startup
  GameDebug.DebugSetup()

-- Create the scene content
  CreateScene()

-- Hook up to relevant events
  SubscribeToEvents()

  gameAudio.SetupSound()

  SetupUI()

  mouseConfig.SetupMouseEvents()
  mouseConfig.SetMouseMode(MM_FREE)

end


function SetupUI()
  -- Set up global UI style into the root UI element
  local style = cache:GetResource("XMLFile", "UI/DefaultStyle.xml")
  ui.root.defaultStyle = style
  
  uiManager.AddUiDefinitions(uiDefs)
  uiManager.ShowUI("MainMenu")
end

function SetWindowTitleAndIcon()
    local icon = cache:GetResource("Image", "Urho2D/duality/gameIcon.png")
    graphics:SetWindowIcon(icon)
    graphics.windowTitle = "Monster Balls"
end

function CreateScene()
    ---@type Scene
    Scene_ = Scene()

    
    -- load base scene (already contains physics world, etc)
    local sceneXml = cache:GetResource("XMLFile", "Scenes/mballs/Scenes/game.xml") --[[@as XMLFile]]
    Scene_:LoadXML(sceneXml:GetRoot())

    -- Create camera
    GameCameraNode = Node()
    GameCameraNode:SetPosition(Vector3(5.0, 5.0, 5.0))

    GameCamera = GameCameraNode:CreateComponent("Camera")

    -- Setup the viewport for displaying the scene
    renderer:SetViewport(0, Viewport:new(Scene_, GameCamera))
    renderer.defaultZone.fogColor = Color(0.2, 0.2, 0.2) -- Set background color for the scene

end

function SetupGameMatch()

  world.Cleanup()

  world.CreateDynamicContent()

  -- Check when scene is rendered; we pause until the player presses "play"
  SubscribeToEvent("EndRendering", HandleSceneReady)

end


function SetupViewport()
  -- Set up a viewport to the Renderer subsystem so that the 3D scene can be seen
  local viewport = Viewport:new(Scene_, GameCameraNode:GetComponent("Camera"))
  renderer:SetViewport(0, viewport)
end

function SubscribeToEvents()

  -- Subscribe HandlePostRenderUpdate() function for processing the post-render update event, during which we request
  -- debug geometry
  SubscribeToEvent("PostRenderUpdate", HandlePostRenderUpdate)

end


function HandlePostRenderUpdate(eventType, eventData)
  -- If draw debug mode is enabled, draw physics debug geometry. Use depth test to make the result easier to interpret
  if GameDebug.drawDebug  then
    Scene_:GetComponent("PhysicsWorld2D"):DrawDebugGeometry(true)
  end
end

function HandleSceneReady()
  UnsubscribeFromEvent("EndRendering")
  if not world.DoneSettingUp then
    Scene_.updateEnabled = false -- Pause the scene if it's still being loaded
  end
end