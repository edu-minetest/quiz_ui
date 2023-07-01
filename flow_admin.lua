local minetest, quiz, flow = minetest, quiz, flow

local MOD_PATH = quiz_ui.MOD_PATH

local flowQuizzes = dofile(MOD_PATH .. "flow_quizzes.lua").flow
local flowAwards = dofile(MOD_PATH .. "flow_awards.lua").flow
local flowConfig = dofile(MOD_PATH .. "flow_config.lua").flow

local loadConfig = quiz.loadConfig
local saveConfig = quiz.saveConfig

local S = quiz_ui.get_translator
local qS = quiz.get_translator
-- local settings = quiz.settings
local gui = flow.widgets

local getSession = quiz.getSession
-- local adminForm

local function flowTodo(player, ctx)
  return gui.VBox {
    -- min_w = 12,
    -- min_h = 9,
    gui.Label{label="(TODO)", align_h = "centre", expand = true},
  }
end

local tabs = {
  {
    label = S("Quizzes"),
    flow = flowQuizzes,
  }, {
    label = S("Awards"),
    flow = flowAwards,
  }, {
    label = S("Advance Config"),
    flow = flowConfig,
  }
}

local function getTabNames()
  local result = {}
  for _, tab in ipairs(tabs) do
    table.insert(result, tab.label)
  end
  return result
end

local function flowAdmin(player, ctx)
  local current_tab = getSession(player).ui.current_tab or 1
  if current_tab > #tabs then current_tab = 1 end

  return gui.VBox {
    min_w = 12,
    min_h = 9,
    gui.Tabheader {
      h = 1,
      name = "tab",
      captions = getTabNames(),
      transparent = true,
      draw_border = false,
      current_tab = current_tab,
      on_event = function(player, ctx)
        local tabIndex = ctx.form.tab
        getSession(player).ui.current_tab = tabIndex
        if tabIndex then
          -- refresh page
          return true
          -- ctx.self:show(player, ctx)
        end
      end
    },
    gui.HBox{ -- Title Bar
      gui.Label{label=tabs[current_tab].label, h=1, align_h = "centre", expand = true},
      gui.Spacer{},
      -- These buttons will be on the right-hand side of the screen
      gui.ButtonExit{name="btnCancel", label = S("Cancel"), on_event = function(player, ctx)
        local msg = qS("Quiz config file loaded.")
        if not loadConfig() then
          msg = qS("Quiz config file loading failed.")
        end
        minetest.chat_send_player(player:get_player_name(), msg)
      end},
      gui.ButtonExit{name="btnOk", label = S("Ok"), on_event = function(player, ctx)
        local msg = qS("Quiz config file saved.")
        local playerName = player:get_player_name()
        minetest.after(2, function()
          local ok, result = saveConfig()
          if ok then
            local lastTotalPlayTime = getSession(playerName).totalPlayTime
            if lastTotalPlayTime ~= quiz.settings.totalPlayTime then
              quiz.resetGameTime(playerName)
            end
            if (result ~= nil and result ~= '') then
              msg = msg .. '(' .. S('in ' .. result) .. ')'
            end
          else
            msg = qS("Quiz config file saving failed.")
          end
          minetest.chat_send_player(playerName, msg)
        end)
      end},
    },
    tabs[current_tab].flow(player, ctx),
  }
end

local function newAdminUI()
  return flow.make_gui(function(player, ctx)
    return flowAdmin(player, ctx)
  end)
end

-- params: pass to ctx
--    parent optional the parent context of the flow UI if exists
--    self: the self flow ui.
local function openAdmin(playerName, params)
  local session = getSession(playerName)
  if session.ui == nil then session.ui = {} end
  -- if ctx then ctx.session = session else ctx = {session = session} end
  local self = newAdminUI()
  if params == nil then params = {} end
  params.self = self
  -- local ctx = {self = self, parent = params.parent}
  local player = minetest.get_player_by_name(playerName)
  self:show(player, params)
end

return {
  open = openAdmin,
  flow = flowAdmin,
}
