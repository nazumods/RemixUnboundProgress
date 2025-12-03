local ns = LibNAddOn(...)
local floor = math.floor

local Player = ns.wow.Player
local ui, Class = ns.ui, ns.lua.Class
local StatusBar, Texture, Label = ui.StatusBar, ui.Texture, ui.Label
local TopLeft, TopRight, BottomLeft, BottomRight = ui.edge.TopLeft, ui.edge.TopRight, ui.edge.BottomLeft, ui.edge.BottomRight
local rgba = ns.Colors.rgba

local Bar = Class(StatusBar, function(self)
  -- darken top edge of bar
  self.edge = Texture:new{
    parent = self,
    layer = ui.layer.Overlay,
    color = {1, 1, 1},
    blendMode = "BLEND",
    gradient = {"VERTICAL", rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.5)},
    position = {
      TopLeft = {},
      BottomRight = {self, TopRight, 0, -3},
    },
  }

  -- fade into ui above
  self.fade = Texture:new{
    parent = self,
    layer = ui.layer.Background,
    color = {1, 1, 1},
    blendMode = "BLEND",
    gradient = {"VERTICAL", rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0)},
    position = {
      TopLeft = {0, 3},
      BottomRight = {self, TopRight},
    },
  }

  self.powerLevel = Label:new{
    parent = self,
    position = {
      BottomLeft = {self, TopLeft, 4, 0}
    },
    fontObj = "QuestFontHighlightHuge",
    color = TRADESKILL_EXPERIENCE_COLOR,
  }

  self.gs = Texture:new{
    parent = self,
    layer = ui.layer.Overlay,
    color = {1, 1, 1},
    blendMode = "BLEND",
    gradient = {"VERTICAL", rgba(138, 255, 18, 1), rgba(138, 255, 18, 1)},
    position = {
      BottomLeft = {self, BottomLeft, 0, 0},
      Height = 1,
    },
  }
  self.ilvl = Label:new{
    parent = self,
    position = {
      BottomRight = {self, TopRight, -350, 0},
    },
    color = rgba(138, 255, 18, 1),
  }
end, {
  parent = UIParent,
  name = "LimitsUnboundProgressBar",
  position = {
    Height = 7,
    BottomLeft = {},
    BottomRight = {}
  },
  events = {
    "CURRENCY_DISPLAY_UPDATE",
    "PLAYER_AVG_ITEM_LEVEL_UPDATE",
  },
  backdrop = {color = {0, 0, 0, 0.6}},
  fill = {
    color = {1, 1, 1},
    blend = "ADD",
    gradient = {"HORIZONTAL", rgba(174, 255, 0, .6), rgba(170, 255, 0, .6)},
  },
})

function Bar:update()
  local w = self:Width()
  local power = C_CurrencyInfo.GetCurrencyInfo(3268).quantity
  local unbound = power > 115875 and floor((power - 115875) / 50000) or -1
  local progress = (power > 115875 and ((power - 115875) % 50000) / 50000) or (power/115875)
  local gs = Player:GetAverageItemLevel()

  self.fill:Width(w * progress)
  self.powerLevel:Text(unbound)
  self.gs:Width(gs < 740 and gs / 740 * w or 0)
  self.ilvl:Text(gs)
  self.ilvl:SetShown(gs < 740)
end

function Bar:initNotches()
  -- add the little notches every 10%
  local spacing = self:Width() / 10
  for i=1,9 do
    self['notch'..i] = Texture:new{
      parent = self,
      layer = ui.layer.Overlay,
      color = {1, 1, 1},
      blendMode = "BLEND",
      gradient = {"HORIZONTAL", rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.2)},
      position = {
        TopLeft = {spacing * i, 0},
        BottomRight = {self, BottomLeft, spacing * i + 3, 0},
      },
    }
  end
end

function Bar:CURRENCY_DISPLAY_UPDATE(type)
  if type == 3268 then self:update() end
end
function Bar:PLAYER_AVG_ITEM_LEVEL_UPDATE()
  self:update()
end

function ns:onLogin()
  if PlayerIsTimerunning() and C_TimerunningUI.GetActiveTimerunningSeasonID() == 2 and self.wow.Player:isMaxLevel() then
    self.bar = Bar:new{}
    self.bar:initNotches()
    self.bar:update()
  end
end

-- for _,node in ipairs(C_Traits.GetTreeNodes(1161)) do local p = C_Traits.GetNodeInfo(26410890,node).ranksPurchased if p > 0 then print(node, p) end end
-- C_Traits.GetNodeInfo(26410890,108700).activeRank

-- C_CurrencyInfo.GetCurrencyInfo(3268) power
-- C_CurrencyInfo.GetCurrencyInfo(3292) knowledge

-- 115875
