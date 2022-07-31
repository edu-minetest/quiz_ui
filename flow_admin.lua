local minetest, quiz, yaml, flow, DIR_DELIM, fgettext = minetest, quiz, yaml, flow, DIR_DELIM, fgettext

local MOD_PATH = quiz_ui.MOD_PATH

local flowQuizAdmin = dofile(MOD_PATH .. "flow_quizzes.lua").flow


local S = quiz_ui.get_translator
local settings = quiz.settings
local gui = flow.widgets

local getSession = quiz.getSession
local adminForm

local function flowTodo(player, ctx)
  return gui.VBox {
    -- min_w = 12,
    -- min_h = 9,
    gui.Label{label=S("Quiz Manager").."Awards Page(TODO)", align_h = "centre", expand = true},
  }
end

local tabs = {
  {
    label = S("Quizzes"),
    flow = flowQuizAdmin,
  }, {
    label = S("Awards"),
    flow = flowTodo,
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
  local current_tab = ctx.session.ui.current_tab or 1
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
          local ui = ctx.session.ui
          ui.current_tab = ctx.form.tab
          -- refresh page
          adminForm:show(player, ctx)
      end
    },
    tabs[current_tab].flow(player, ctx),
  }
end

local function newAdminUI()
  return flow.make_gui(function(player, ctx)
    return flowAdmin(player, ctx)
  end)
end

local function openAdmin(playerName, ctx)
  local session = getSession(playerName)
  if session.ui == nil then session.ui = {} end
  if ctx then ctx.session = session else ctx = {session = session} end

  adminForm = newAdminUI()
  adminForm:show(playerName, ctx)
end

return {
  open = openAdmin,
  flow = flowAdmin,
}
