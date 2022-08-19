local minetest, flow = minetest, flow
local S = quiz_ui.get_translator
local gui = flow.widgets
local formspec_escape = minetest.formspec_escape


local function flowAward(player, ctx)
  local vAward = ctx.award or {}
  if ctx.award == nil then ctx.award = vAward end
  -- local title = getSTitle(vAward.title or "", vAward.mod)

  local result = {
    min_w = 12,
    min_h = 9,
    gui.HBox{ -- Title Bar
      gui.Label{label=S("Award Editor"), h=1, align_h = "centre", expand = true},
      gui.Spacer{},
      -- These buttons will be on the right-hand side of the screen
      gui.Button{name="btnCancel", label = S("Cancel"), on_event = function(player, ctx)
        if ctx.parent then ctx.parent.self:show(player, ctx.parent) end
        ctx.self:close(player)
      end},
      gui.Button{name="btnOk", label = S("Ok"), on_event = function(player, ctx)
        local v = ctx.award
        local fm = ctx.form
        v.mod = fm.fdMod
        if v.mod == "default" then v.mod = nil end
        v.title = fm.fdTitle
        v.id = fm.fdId
        v.count = tonumber(fm.fdCount)
        if v.count == 1 then v.count = nil end
        if type(ctx.on_ok) == "function" then
          ctx.on_ok(player, ctx)
        end
        if ctx.parent then ctx.parent.self:show(player, ctx.parent) end
        ctx.self:close(player)
      end},
    },
    gui.HBox {
      gui.Field{
        name="fdId",
        label=S("Id"),
        default = formspec_escape(vAward.id),
      },
      gui.Field{
        name="fdTitle",
        label=S("Award Title"),
        default = formspec_escape(vAward.title),
      },
    },
    gui.HBox {
      gui.Field{
        name="fdCount",
        label=S("Count"),
        default = "" .. (vAward.count or 1),
      },
      gui.Field{
        name="fdMod",
        label=S("Mod Name"),
        default = formspec_escape(vAward.mod),
      },
    },
  }
  return gui.VBox(result)
end

local function newAwardUI()
  return flow.make_gui(function(player, ctx)
    return flowAward(player, ctx)
  end)
end

local function openAward(player, params)
  -- local session = getSession(player:get_player_name())
  -- if session.ui == nil then session.ui = {} end
  -- if ctx then
  --   ctx.session = session
  -- else
  --   ctx = {session = session}
  -- end

  local self = newAwardUI()
  if params == nil then params = {} end
  params.self = self
  self:show(player, params)
  if params.parent then
    params.parent.self:close(player)
  end
end

return {
  open = openAward,
  flow = flowAward,
}
