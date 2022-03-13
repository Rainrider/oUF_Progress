local _, ns = ...
ns = ns.__Progress

local azerite = {}

azerite.name = 'azerite'
azerite.color = _G.ARTIFACT_BAR_COLOR
azerite.events = {
	AZERITE_ITEM_EXPERIENCE_CHANGED = true,
	PLAYER_ENTERING_WORLD = true,
}
azerite.visibilityEvents = {
	UNIT_INVENTORY_CHANGED = true,
}

function azerite:CancelItemLoadCallback()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

function azerite:GetValues()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	local value, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
	local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)

	return value, 0, max, level, azeriteItemLocation
end

function azerite:UpdateTooltip()
	local value, _, max, level, azeriteItemLocation = self:GetValues()
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)

	self.itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function ()
		local name = azeriteItem:GetItemName()

		GameTooltip:SetText(
			_G.AZERITE_POWER_TOOLTIP_TITLE:format(level, max - value),
			_G.HIGHLIGHT_FONT_COLOR:GetRGB()
		)
		GameTooltip:AddLine(_G.AZERITE_POWER_TOOLTIP_BODY:format(name))
	end)
end

function azerite:Visibility()
	local isMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel()

	if (isMaxLevel) then return false end

	local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()

	return azeriteItem
		and azeriteItem:IsEquipmentSlot()
		and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem)
end

ns.modes[#ns.modes + 1] = azerite