local minetest, quiz, yaml, flow, DIR_DELIM = minetest, quiz, yaml, flow, DIR_DELIM

local formspec_escape = minetest.formspec_escape
-- local defaultTextureDir = minetest.get_texturepath_share() .. DIR_DELIM .. "base" ..
        -- DIR_DELIM .. "pack" .. DIR_DELIM

local MOD_PATH = quiz_ui.MOD_PATH

local openQuizEdit = dofile(MOD_PATH .. "flow_quiz.lua").open


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
local calcType = quiz.calcType

local TYPES_STR = {
  string = S("string"),
  number = S("number"),
  boolean = S("boolean"),
  calc = S("calc"),
  select = S("select"),
}
quiz_ui.TYPES_STR = TYPES_STR

local function addQuiz(tbl, quiz, ix)
  table.insert(tbl, ix)
  table.insert(tbl, TYPES_STR[quiz.type or "string"])
  if quiz.type == "calc" then
    table.insert(tbl, quiz.answer)
    local expr = calcType.parse(quiz.answer, quiz.forceInt)
    table.insert(tbl, expr)
  else
    table.insert(tbl, quiz.title)
    table.insert(tbl, quiz.answer)
  end
end

local function searchQuizzes(s, session)
  if type(s) == "string" then
    s = string.gsub(s, '^%s*(.-)%s*$', '%1')
    if #s > 0 then
      local result = {}
      local lookup = {}
      local quizList = settings.quiz
      for ix, vQuiz in pairs(quizList) do
        if string.find(vQuiz.title, s)
          or string.find(vQuiz.answer, s)
          or string.find(vQuiz.type or "string", s)
          or string.find(TYPES_STR[quiz.type or "string"], s)
        then
          table.insert(lookup, ix)
          addQuiz(result, vQuiz, ix)
        end
      end
      session.search = {result = result, lookup = lookup}
      if #result then
        return true
      end
    end
  end
end

-- the return list used for the formspec table
local function genQuizList(session)
  local search = session.search
  if search and search.result then
    return search.result
  end
  local quizList = settings.quiz
  local result = nil -- session.quizList
  if result == nil then
    result = {}
    for ix, quiz in pairs(quizList) do
      addQuiz(result, quiz, ix)
    end
    -- session.quizList = result
  end
  return result
end

local function flowQuizList(player, ctx)
  local session = getSession(player)
  local result = gui.VBox {
    gui.TableColumns {
      {type = "text", opts = {}}, -- index
      {type = "text", opts = {}}, -- type
      {type = "text", opts = {}}, -- title
      {type = "text", opts = {}}, -- answer
    },
    gui.Table {
      w = 9.25,
      h = 7,
      name = "tblQuiz",
      cells = genQuizList(session),
      on_event = function(player, ctx)
        local evt = ctx.form.tblQuiz
        if evt.type == "DCL" then
          -- double-click
          local quizList = settings.quiz
          openQuizEdit(player, {
            quiz = quizList[evt.row],
            parent = ctx,
          })
        end
      end
    }
  }
  return result
end

local function do_search(player, ctx)
  local search_for = ctx.form.fdSearch
  local session = getSession(player)
  local last_search = session.last_search
  local repaint = false
  if search_for == last_search then return end
  if search_for and #search_for > 0 then
    searchQuizzes(search_for, session)
    repaint = true
  end
  session.last_search = search_for
  return repaint
end

local function flowQuizAdmin(player, ctx)
  local session = getSession(player)
  return gui.VBox{
    -- min_w = 12,
    -- min_h = 9,
    gui.HBox{ -- Toolbar
      gui.Field{
        name="fdSearch",
        w = 7,
        default = formspec_escape(session.last_search),
        -- expand = true,
        on_event = do_search,
      },
      gui.ImageButton{
        w = 0.75,
        name = "btnSearch",
        texture_name = "search.png",
        on_event = do_search,
      },
      gui.ImageButton{
        w = 0.75,
        name = "btnSearchClear",
        texture_name = "clear.png",
        on_event = function(player, ctx)
          local session = getSession(player)
          -- session.search_for = ""
          ctx.form.fdSearch = ""
          session.search = nil
          return true
        end
      },
      gui.Spacer{},
      gui.Button{
        name="btnAdd", label = S("New"),
        on_event = function(player, ctx)
          openQuizEdit(player, {
            parent = ctx,
            on_ok = function(player, ctx)
              if ctx.quiz then
                table.insert(settings.quiz, ctx.quiz)
              end
            end
        })
        end
      },
      gui.Button{
        name="btnEdit", label = S("Edit"),
        on_event = function(player, ctx)
          local evt = ctx.form.tblQuiz
          if evt and evt.row then
            local quizList = settings.quiz
            local quiz = quizList[evt.row]
            -- local session = ctx.session
            openQuizEdit(player, {
              quiz = quiz, parent = ctx,
              on_ok = function(player, ctx)
                -- session.quizList = nil
              end
            })
          end
        end
      },
      gui.Button{
        name="btnDel", label = S("Delete"),
        on_event = function(player, ctx)
          local evt = ctx.form.tblQuiz
          if evt and evt.row then
            local session = getSession(player)
            local quizList = settings.quiz
            local search = session.search
            if search then
              local idx =search.lookup[evt.row]
              table.remove(quizList, idx)
            else
              table.remove(quizList, evt.row)
            end
            -- session.quizList = nil
            return true
          end
        end
      },
    },
    flowQuizList(player, ctx),
  }
end

local function newQuizAdminUI()
  return flow.make_gui(function(player, ctx)
    return flowQuizAdmin(player, ctx)
  end)
end

local function openQuizAdmin(playerName, params)
  -- local session = getSession(playerName)
  -- if ctx then ctx.session = session else ctx = {session = session} end
  local self = newQuizAdminUI()
  if params == nil then params = {} end
  params.self = self
  self:show(playerName, params)
end

return {
  open = openQuizAdmin,
  flow = flowQuizAdmin,
}
