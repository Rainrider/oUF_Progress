local _, ns = ...
ns = ns.__Progress

---@type Mode
local honor = {}

honor.name = 'honor'
honor.color = CreateColor(1.0, 0.24, 0)
honor.events = {
	HONOR_XP_UPDATE = true,
}
honor.visibilityEvents = {
	HONOR_LEVEL_UPDATE = true,
	ZONE_CHANGED = true,
	ZONE_CHANGED_NEW_AREA = true,
}

---@param _ Progress
---@param unit WowUnit
---@return integer value
---@return integer min
---@return integer max
---@return integer level
function honor:GetValues(_, unit)
	local value = UnitHonor(unit)
	local max = UnitHonorMax(unit)
	local level = UnitHonorLevel(unit)

	return value, 0, max, level
end

function honor:OnMouseUp()
	PVEFrame_ToggleFrame('PVPUIFrame')
end

---@param element Progress
function honor:UpdateTooltip(element)
	local value, _, max, level = self:GetValues(element, element.__owner.unit)

	GameTooltip:SetText(
		('%s (%s)'):format(_G.HONOR, _G.UNIT_LEVEL_TEMPLATE:format(level)),
		_G.HIGHLIGHT_FONT_COLOR:GetRGB()
	)
	GameTooltip:AddLine(_G.LIFETIME_HONOR_DESC)
	GameTooltip:AddLine(
		string.format(
			'%s / %s (%d%%)',
			BreakUpLargeNumbers(value),
			BreakUpLargeNumbers(max),
			value / max * 100 + 0.5
		),
		1, 1, 1
	)
end

---@param event? WowEvent
---@return boolean
function honor:Visibility(event)
	local isInActivePvP = not event or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP()
	local isMaxHonorLevel = not C_PvP.GetNextHonorLevelForReward(UnitHonorLevel('player'))

	return not isMaxHonorLevel and isInActivePvP
end

ns.modes[#ns.modes + 1] = honor
