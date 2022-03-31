local _, ns = ...
ns = ns.__Progress

---@type Mode
local azerite = {}

azerite.name = 'azerite'
azerite.color = _G.ARTIFACT_BAR_COLOR
azerite.events = {
	AZERITE_ITEM_EXPERIENCE_CHANGED = true,
	PLAYER_ENTERING_WORLD = true,
}
azerite.info = '[progress:missing][ ($>progress:reps<$)]'
azerite.status = {}
azerite.visibilityEvents = {
	PLAYER_EQUIPMENT_CHANGED = true,
}

function azerite:CancelItemLoadCallback()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

---@return integer @azerite power
---@return integer @max
---@return integer @azerite level
---@return integer @item id of Hearth of Azeroth
---@return ItemLocationMixin @Hearh of Azeroth item location
function azerite:GetValues()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	local value, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
	local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)

	return value, max, level, 158075, azeriteItemLocation
end

function azerite:OnMouseUp()
	if (not C_AzeriteEssence.CanOpenUI()) then return end

	if (not _G.AzeriteEssenceUI) then
		UIParentLoadAddOn('Blizzard_AzeriteEssenceUI')
	end

	if (not _G.AzeriteEssenceUI:IsShown()) then
		ShowUIPanel(_G.AzeriteEssenceUI)
	else
		HideUIPanel(_G.AzeriteEssenceUI)
	end
end

function azerite:UpdateTooltip()
	local value, max, level, _, azeriteItemLocation = self:GetValues()
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

---@return boolean?
function azerite:Visibility(_, slot)
	if (slot and slot ~= _G.INVSLOT_NECK) then return end

	local isMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel()

	if (isMaxLevel) then return false end

	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

	return azeriteItemLocation
		and azeriteItemLocation:IsEquipmentSlot()
		and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation)
end

ns.modes[#ns.modes + 1] = azerite