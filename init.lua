local minetest, quiz, yaml, DIR_DELIM = minetest, quiz, yaml, DIR_DELIM
local formspec_escape = minetest.formspec_escape

local MOD_NAME = minetest.get_current_modname()

if rawget(_G, MOD_NAME) then return end

quiz_ui = {}
local S = minetest.get_translator(MOD_NAME)
quiz_ui.get_translator = S

local MOD_PATH = minetest.get_modpath(MOD_NAME) .. "/"
quiz_ui.MOD_PATH = MOD_PATH

local openQuizAdmin = dofile(MOD_PATH .. "flow_admin.lua").open
quiz_ui.openQuizAdmin = openQuizAdmin


local function uiChatCommand(playerName, param)
  openQuizAdmin(playerName)
  return true
end
quiz.defaultChatCmd = uiChatCommand

-- minetest.register_chatcommand("quiz_ui", {
--   description = S("Show the Quiz Manager UI"),
--   privs = {
--     quiz = true,
--   },
--   func = uiChatCommand,
-- })
