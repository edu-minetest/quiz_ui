local minetest, quiz, yaml, flow, DIR_DELIM = minetest, quiz, yaml, flow, DIR_DELIM

local MOD_PATH = quiz_ui.MOD_PATH

local openAwardEdit = dofile(MOD_PATH .. "flow_award.lua").open

local formspec_escape = minetest.formspec_escape
local S = quiz_ui.get_translator
local qS = quiz.get_translator

local settings = quiz.settings

-- GUI elements are accessible with flow.widgets. Using
-- `local gui = flow.widgets` is recommended to reduce typing.
local gui = flow.widgets
local getSession = quiz.getSession

-- get translated title
local function getSTitle(title, mod)
  if mod == nil then mod = "default" end
  local modS = minetest.get_translator(mod)
  if modS and title ~= "" then
    title = modS(title)
  end
  return title
end

local function addAward(tbl, award, ix)
  local mod = award.mod or "default"
  local title = award.title or ""
  if title ~= "" then title = getSTitle(title, mod) end
  if mod == "default" then mod = S(mod) end

  table.insert(tbl, award.id)
  table.insert(tbl, mod)
  table.insert(tbl, title)
  table.insert(tbl, award.count or 1)
end

-- the return list used for the formspec table
local function genAwardList(session)
  local result = {}
  for ix, award in pairs(settings.awards) do
    addAward(result, award, ix)
  end
  return result
end

local function flowAwardList(player, ctx)
  local session = getSession(player)
  local result = gui.VBox {
    gui.TableColumns {
      {type = "text", opts = {}}, -- id
      {type = "text", opts = {}}, -- mod
      {type = "text", opts = {}}, -- title
      {type = "text", opts = {}}, -- count
    },
    gui.Table {
      w = 9.25,
      h = 7,
      name = "tblAwards",
      cells = genAwardList(session),
      on_event = function(player, ctx)
        local evt = ctx.form.tblAwards
        if evt.type == "DCL" then
          -- double-click
          local awards = settings.awards
          openAwardEdit(player, {
            award = awards[evt.row],
            parent = ctx,
          })
        end
      end
    }
  }
  return result
end

local function flowAwards(player, ctx)
  return gui.VBox{
    -- min_w = 12,
    -- min_h = 9,
    gui.HBox{ -- Toolbar
      gui.Spacer{},
      gui.Button{
        name="btnAdd", label = S("New"),
        on_event = function(player, ctx)
          openAwardEdit(player, {
            parent = ctx,
            on_ok = function(player, ctx)
              if ctx.quiz then
                table.insert(settings.awards, ctx.award)
              end
            end
        })
        end
      },
      gui.Button{
        name="btnEdit", label = S("Edit"),
        on_event = function(player, ctx)
          local evt = ctx.form.tblAwards
          if evt and evt.row then
            local awards = settings.awards
            local award = awards[evt.row]
            -- local session = ctx.session
            openAwardEdit(player, {
              award = award, parent = ctx,
            })
          end
        end
      },
      gui.Button{
        name="btnDel", label = S("Delete"),
        on_event = function(player, ctx)
          local evt = ctx.form.tblAwards
          if evt and evt.row then
            table.remove(settings.awards, evt.row)
            return true
          end
        end
      },

    },
    flowAwardList(player, ctx),
  }
end

local function newAwardUI()
  return flow.make_gui(function(player, ctx)
    return flowAwards(player, ctx)
  end)
end

local function openAwards(playerName, params)
  -- local session = getSession(playerName)
  -- if ctx then ctx.session = session else ctx = {session = session} end
  local self = newAwardUI()
  if params == nil then params = {} end
  params.self = self
  self:show(playerName, params)
end

return {
  open = openAwards,
  flow = flowAwards,
}
