local _, ns = ...
ns = ns.__Progress

local artifact = {}

artifact.name = 'artifact'
artifact.color = _G.ARTIFACT_BAR_COLOR
artifact.events = {
	ARTIFACT_XP_UPDATE = true,
	PLAYER_ENTERING_WORLD = true,
}
artifact.visibilityEvents = {
	UNIT_INVENTORY_CHANGED = false,
}

---@param spentPoints integer
---@param unspentPower integer
---@param tier integer
---@return integer
---@return integer
---@return integer
local function GetAvailablePoints(spentPoints, unspentPower, tier)
	local availablePoints = 0;
	local threshold = C_ArtifactUI.GetCostForPointAtRank(spentPoints, tier)

	while unspentPower >= threshold and threshold > 0 do
		unspentPower = unspentPower - threshold

		spentPoints = spentPoints + 1
		availablePoints = availablePoints + 1

		threshold = C_ArtifactUI.GetCostForPointAtRank(spentPoints, tier)
	end
	return availablePoints, unspentPower, threshold
end

---@return integer
---@return integer
---@return integer
---@return integer
---@return string
---@return integer
---@return integer
function artifact:GetValues()
	local _, _, name, _, unspentPower, spentPoints, _, _, _, _, _, _, tier = C_ArtifactUI.GetEquippedArtifactInfo()
	local availablePoints, power, threshold = GetAvailablePoints(spentPoints, unspentPower, tier)

	return power, 0, threshold, spentPoints + availablePoints, name, unspentPower, availablePoints
end

function artifact:OnMouseUp()
	if (not _G.ArtifactFrame or not _G.ArtifactFrame:IsShown()) then
		SocketInventoryItem(_G.INVSLOT_MAINHAND)
	else
		HideUIPanel(_G.ArtifactFrame)
	end
end

function artifact:UpdateTooltip()
	local value, _, max, _, name, unspentPower, availablePoints = self:GetValues()

	GameTooltip:SetText(name, _G.HIGHLIGHT_FONT_COLOR:GetRGB())
	GameTooltip:AddLine(
		_G.ARTIFACT_POWER_TOOLTIP_TITLE:format(
			BreakUpLargeNumbers(unspentPower, true),
			BreakUpLargeNumbers(value, true),
			BreakUpLargeNumbers(max, true)
		),
		nil, nil, nil,
		true
	)
	GameTooltip:AddLine(
		_G.ARTIFACT_POWER_TOOLTIP_BODY:format(availablePoints),
		nil, nil, nil,
		true
	)
end

function artifact:Visibility()
	return HasArtifactEquipped()
		and not C_ArtifactUI.IsEquippedArtifactMaxed()
		and not C_ArtifactUI.IsEquippedArtifactDisabled()
end

ns.modes[#ns.modes + 1] = artifact