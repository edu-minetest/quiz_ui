local minetest, quiz, yaml, flow, DIR_DELIM = minetest, quiz, yaml, flow, DIR_DELIM
local S = quiz_ui.get_translator
local gui = flow.widgets
local getSession = quiz.getSession
local isInvalidQuiz = quiz.isInvalidQuiz
local formspec_escape = minetest.formspec_escape

local typeItems = {
  "string",
  "number",
  "boolean",
  "calc",
  "select",
}

local function getTypeItems()
  local result = {}
  for _, value in pairs(typeItems) do
    table.insert(result, S(value))
  end
  return result
end
local sTypeItems = getTypeItems()

local function getTypeIndex(s)
  if s == nil or s == "" then return 1 end
  for i, value in pairs(typeItems) do
    if s == value then return i end
  end
  return 1
end
local function flowEdit(player, ctx)
  local vQuiz = ctx.quiz or {}
  if ctx.quiz == nil then ctx.quiz = vQuiz end
  local vTypeIdx = getTypeIndex(vQuiz.type)
  local result = {
    min_w = 12,
    min_h = 9,
    gui.HBox{ -- Title Bar
      gui.Label{label=S("Quiz Editor"), h=1, align_h = "centre", expand = true},
      gui.Spacer{},
      -- These buttons will be on the right-hand side of the screen
      gui.ButtonExit{name="btnCancel", label = S("Cancel"), on_event = function(player, ctx)
        if ctx.parent then ctx.parent.self:show(player, ctx.parent) end
      end},
      gui.Button{name="btnOk", label = S("Ok"), on_event = function(player, ctx)
        local v = ctx.quiz
        v.title = ctx.form.fdTitle
        v.answer = ctx.form.fdAnswer
        if v.answer then
          -- trim string
          v.answer = string.gsub(v.answer, '^%s*(.-)%s*$', '%1')
        end
        v.type = typeItems[ctx.form.fdType] or "string"
        if v.type == "select" then
          v.options = string.split(ctx.form.fdOptions, "\n")
        elseif v.type == "number" then
          v.answer = tonumber(v.answer)
        elseif v.type == "boolean" then
          v.answer = minetest.is_yes(v.answer)
        end
        if isInvalidQuiz(v) then
          local msg = S("title and answer params required")
          minetest.chat_send_player(player:get_player_name(), msg)
          return true
        end
        if type(ctx.on_ok) == "function" then
          ctx.on_ok(player, ctx)
        end
        if ctx.parent then ctx.parent.self:show(player, ctx.parent) end
        ctx.self:close(player)
      end},
    },
    gui.Textarea{
      name="fdTitle",
      label=S("Title"),
      w = 7,
      h = 2,
      default = formspec_escape(vQuiz.title),
    },
    gui.Label {label = S("Type")},
    gui.Dropdown {
      name="fdType",
      items=sTypeItems,
      index_event = true,
      selected_idx = vTypeIdx,
      on_event = function(player, ctx)
        if ctx.form.fdType then
          ctx.quiz.type = typeItems[ctx.form.fdType] or "string"
          return true
        end
      end
    },
    gui.Label {label = S("Answer")},
    gui.Field{
      name="fdAnswer",
      w = 7,
      h = 1,
      default = formspec_escape(vQuiz.answer),
      -- expand = true,
    },
  }
  if vQuiz.type == "select" then
    local vOpts = vQuiz.options or {}
    table.insert(result, gui.Label {label = S("Options")} )
    table.insert(result, gui.Textarea {
      name="fdOptions",
      w = 7,
      h = 2,
      default = formspec_escape(table.concat(vOpts, "\n")),
    })
  end
  return gui.VBox(result)
end

local function newEditUI()
  return flow.make_gui(function(player, ctx)
    return flowEdit(player, ctx)
  end)
end

local function openEdit(player, params)
  -- local session = getSession(player:get_player_name())
  -- if session.ui == nil then session.ui = {} end
  -- if ctx then
  --   ctx.session = session
  -- else
  --   ctx = {session = session}
  -- end

  local self = newEditUI()
  if params == nil then params = {} end
  params.self = self
  self:show(player, params)
  if params.parent then
    params.parent.self:close(player)
  end
end

return {
  open = openEdit,
  flow = flowEdit,
}
