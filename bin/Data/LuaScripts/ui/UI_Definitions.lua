
---@class UiDefinition
---@field uiFilePath string
---@field attachedInstance UIElement
local MainMenu = { 
    uiFilePath = "UI/mballs/screen_title.xml",
    handlerFile = require("LuaScripts/ui/screens/UI_MainMenu")
 }

---@type UiDefinition[]
local definitions = {
    MainMenu = MainMenu,
    PopupGeneric = { uiFilePath = "UI/mballs/overlay_popup.xml" },
    PopupInput = {
        uiFilePath = "UI/mballs/generic_input_overlay.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Popup_Input")
    },
    Endgame = { 
        uiFilePath = "UI/mballs/screen_endgame.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Endgame")
    },
    Credits = { 
        uiFilePath = "UI/mballs/screen_credits.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Credits")
    },
    HowTo = { 
        uiFilePath = "UI/mballs/screen_howto.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Credits")
    },
    Loading = { 
        uiFilePath = "UI/mballs/screen_loading.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Loading")
    },
    Game = { 
        uiFilePath = "UI/mballs/screen_game.xml",
        handlerFile = require("LuaScripts/ui/screens/UI_Game")
    },
}


-- extra emmylua ui-related definitions...

---@class PopupDisplayData
---@field title string
---@field prompt string
---@field buttonInfos PopupButtonInfo[]

---@class InputPopupDisplayData : PopupDisplayData
---@field inputFieldInitialValue string

---@class PopupButtonInfo
---@field buttonText string
---@field buttonAction function
---@field closePopupOnClick boolean

---@class EndGameScreenData
---@field hasWon boolean

return definitions