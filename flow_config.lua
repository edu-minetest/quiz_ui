local minetest, quiz, yaml, flow, DIR_DELIM = minetest, quiz, yaml, flow, DIR_DELIM

local formspec_escape = minetest.formspec_escape

local S = quiz_ui.get_translator
local qS = quiz.get_translator

local settings = quiz.settings
-- local Quizzes = quiz.quizzes
local loadConfig = quiz.loadConfig
local saveConfig = quiz.saveConfig
-- GUI elements are accessible with flow.widgets. Using
-- `local gui = flow.widgets` is recommended to reduce typing.
local gui = flow.widgets
local getSession = quiz.getSession

local function on_config_number(name)
  return function(player, ctx)
    local v = tonumber(ctx.form[name])
    if type(v) == "number" then
      settings[name] = v
    end
  end
end

local function genNumField(label, name)
  return
    -- gui.Label {label = label},
    gui.Field{
      label = label,
      name= name,
      w = 3.75,
      default = "" .. settings[name],
      on_event = on_config_number(name),
    }
end

local function getOnlinePlayerNames()
  local result = {}
  for _, player in ipairs(minetest.get_connected_players()) do
    table.insert(result, player:get_player_name())
  end
  return result
end

local function flowConfig(player, ctx)
  local session = getSession(player)
  local onlinePlayers = getOnlinePlayerNames()
  return gui.VBox{
    -- min_w = 12,
    -- min_h = 9,
    gui.HBox{
      genNumField(S("Total Play Time").."("..S("minute") ..")", "totalPlayTime"),
      genNumField(S("Rest Time").."("..S("minute") ..")", "restTime"),
      gui.Dropdown {
          -- The value of this dropdown will be accessible from ctx.form.my_dropdown
          name = "onlinePlayers",
          items = onlinePlayers,
          index_event = true,
      },
      gui.Button {
          label = "Reset",
          on_event = function(player, ctx)
              local selected_idx = ctx.form.onlinePlayers
              local selected_player = onlinePlayers[selected_idx]
              if selected_player then
                quiz.setLastLeavedTime(selected_player, 0)
                minetest.chat_send_player(player:get_player_name(), qS("reset @1 successful", selected_player))
              end
          end,
      },
    },
    gui.HBox{
      genNumField(S("Idle Interval Time").."("..S("minute") ..")", "idleInterval"),
      genNumField(S("Check Interval Time").."("..S("second") ..")", "checkInterval"),
    },
  }
end

local function newConfigUI()
  return flow.make_gui(function(player, ctx)
    return flowConfig(player, ctx)
  end)
end

local function openConfig(playerName, params)
  -- local session = getSession(playerName)
  -- if ctx then ctx.session = session else ctx = {session = session} end
  local self = newConfigUI()
  if params == nil then params = {} end
  params.self = self
  self:show(playerName, params)
end

return {
  open = openConfig,
  flow = flowConfig,
}
