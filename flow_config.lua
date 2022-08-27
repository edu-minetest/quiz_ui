local minetest, quiz, flow = minetest, quiz, flow

-- local formspec_escape = minetest.formspec_escape

local S = quiz_ui.get_translator

local settings = quiz.settings
-- local Quizzes = quiz.quizzes
-- local loadConfig = quiz.loadConfig
-- local saveConfig = quiz.saveConfig
-- GUI elements are accessible with flow.widgets. Using
-- `local gui = flow.widgets` is recommended to reduce typing.
local gui = flow.widgets
local getSession = quiz.getSession

local function set_num(form, name)
  local v = tonumber(form[name])
  if type(v) == "number" then
    settings[name] = v
  end
end

local function set_bool(form, name)
  local v = form[name]
  if type(v) == "boolean" then
    settings[name] = v
  end
end

local function on_config(player, ctx)
  set_num(ctx.form, "totalPlayTime")
  set_num(ctx.form, "restTime")
  set_num(ctx.form, "idleInterval")
  set_num(ctx.form, "checkInterval")
  set_bool(ctx.form, "forceAdminRest")
end

local function genField(label, name, type)
  if type == nil then type = "Field" end
  local params = {
    label = label,
    name= name,
    -- on_event = on_config_number(name),
    on_event = on_config,
  }

  if type == "Checkbox" then
    params.selected = settings[name]
  else
    params.default = "" .. settings[name]
    params.w = 3.75
  end

  return gui[type](params)
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
      genField(S("Total Play Time").."("..S("minute") ..")", "totalPlayTime"),
      genField(S("Rest Time").."("..S("minute") ..")", "restTime"),
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
                minetest.chat_send_player(player:get_player_name(), S("reset @1 successful", selected_player))
              end
          end,
      },
    },
    gui.HBox{
      genField(S("Idle Interval Time").."("..S("minute") ..")", "idleInterval"),
      genField(S("Check Interval Time").."("..S("second") ..")", "checkInterval"),
      genField(S("Force Admin Rest"), "forceAdminRest", "Checkbox"),
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
