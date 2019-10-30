-- vim: sw=2 sts=2 et
local Identify = CreateFrame("Frame", "Identify", UIParent)
Identify:RegisterEvent("ADDON_LOADED")

function Identify:ModifyTooltip(tooltip, left, right)
  -- this is inefficient, but not sure of a better way to avoid duplicate lines
  -- than scanning the entire thing...
  local found = false
  for i = tooltip:NumLines(),2,-1 do
    local frame = _G[tooltip:GetName() .. "TextRight" .. i]
    if frame then
      local text = frame:GetText()
      if text == right then
        found = true
        break
      end
    end
  end
  if not found then
    tooltip:AddDoubleLine(left, right, 1, 1, 1, 1, 1, 1)
    tooltip:Show()
  end
end

function Identify:AddOnlyId(tooltip, id)
  self:ModifyTooltip(tooltip, " ", tostring(id))
end

function Identify.HandleAuraTooltip(tooltip, unit, slot, auratype)
  local src, _, _, id = select(7, UnitAura(unit, slot, auratype))
  if (src) then
    local _, class = UnitClass(src)
    src = "|c" .. RAID_CLASS_COLORS[class].colorStr .. UnitName(src)
  else
    src = " "
  end
  Identify:ModifyTooltip(tooltip, src, tostring(id))
end

function Identify.HandleBuffTooltip(tooltip, unit, slot)
  Identify.HandleAuraTooltip(tooltip, unit, slot, "HELPFUL")
end

function Identify.HandleDebuffTooltip(tooltip, unit, slot)
  Identify.HandleAuraTooltip(tooltip, unit, slot, "HARMFUL")
end

function Identify.HandleSpellTooltip(tooltip)
  local _, id = tooltip:GetSpell()
  Identify:AddOnlyId(tooltip, id)
end

function Identify.HandleItemRef(link)
  local match = link:match("spell:(%d+)") or link:match("item:(%d+)")
  if match then
    Identify:AddOnlyId(ItemRefTooltip, match)
  end
end

function Identify.HandleItemTooltip(tooltip)
  local _, link = tooltip:GetItem()
  local match = link:match("item:(%d+)")
  if match then
    Identify:AddOnlyId(tooltip, match)
  end
end

function Identify:InitAddon()
  hooksecurefunc(GameTooltip, "SetUnitAura", self.HandleAuraTooltip)
  hooksecurefunc(GameTooltip, "SetUnitBuff", self.HandleBuffTooltip)
  hooksecurefunc(GameTooltip, "SetUnitDebuff", self.HandleDebuffTooltip)

  GameTooltip:HookScript("OnTooltipSetSpell", self.HandleSpellTooltip)
  GameTooltip:HookScript("OnTooltipSetItem", self.HandleItemTooltip)
  hooksecurefunc("SetItemRef", self.HandleItemRef)
end

Identify:SetScript("OnEvent", Identify.InitAddon)
