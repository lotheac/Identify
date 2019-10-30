-- vim: sw=2 sts=2 et
local Identify = CreateFrame("Frame", "Identify", UIParent)
Identify:RegisterEvent("ADDON_LOADED")

local function AddDoubleLine(tooltip, left, right)
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

local function HandleAuraTooltip(tooltip, unit, slot, auratype)
  local src, _, _, id = select(7, UnitAura(unit, slot, auratype))
  if (src) then
    local _, class = UnitClass(src)
    src = "|c" .. RAID_CLASS_COLORS[class].colorStr .. UnitName(src)
  else
    src = " "
  end
  AddDoubleLine(tooltip, src, tostring(id))
end

local function HandleBuffTooltip(tooltip, unit, slot)
  HandleAuraTooltip(tooltip, unit, slot, "HELPFUL")
end

local function HandleDebuffTooltip(tooltip, unit, slot)
  HandleAuraTooltip(tooltip, unit, slot, "HARMFUL")
end

local function AddOnlyId(tooltip, id)
  AddDoubleLine(tooltip, " ", tostring(id))
end

local function HandleSpellTooltip(tooltip)
  local _, id = tooltip:GetSpell()
  AddOnlyId(tooltip, id)
end

local function HandleItemRef(link)
  local match = link:match("spell:(%d+)") or link:match("item:(%d+)")
  if match then
    AddOnlyId(ItemRefTooltip, match)
  end
end

local function HandleItemTooltip(tooltip)
  local _, link = tooltip:GetItem()
  local match = link:match("item:(%d+)")
  if match then
    AddOnlyId(tooltip, match)
  end
end

function Identify:InitAddon()
  hooksecurefunc(GameTooltip, "SetUnitAura", HandleAuraTooltip)
  hooksecurefunc(GameTooltip, "SetUnitBuff", HandleBuffTooltip)
  hooksecurefunc(GameTooltip, "SetUnitDebuff", HandleDebuffTooltip)

  GameTooltip:HookScript("OnTooltipSetSpell", HandleSpellTooltip)
  GameTooltip:HookScript("OnTooltipSetItem", HandleItemTooltip)
  hooksecurefunc("SetItemRef", HandleItemRef)
end

Identify:SetScript("OnEvent", Identify.InitAddon)
