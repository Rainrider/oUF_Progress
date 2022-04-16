local _, ns = ...
ns = ns.__Progress

---@type Mode
local artifact = {}

artifact.name = 'artifact'
artifact.color = _G.ARTIFACT_BAR_COLOR
artifact.events = {
	ARTIFACT_XP_UPDATE = true,
	PLAYER_ENTERING_WORLD = true,
}
artifact.info = '[progress:missing][ ($>progress:reps<$)]'
artifact.status = {}
artifact.visibilityEvents = {
	PLAYER_EQUIPMENT_CHANGED = true,
}

---@param spentPoints integer
---@param unspentPower integer
---@param tier integer
---@return integer
---@return integer
---@return integer
local function GetAvailablePoints(spentPoints, unspentPower, tier)
	local availablePoints = 0
	local threshold = C_ArtifactUI.GetCostForPointAtRank(spentPoints, tier)

	while unspentPower >= threshold and threshold > 0 do
		unspentPower = unspentPower - threshold

		spentPoints = spentPoints + 1
		availablePoints = availablePoints + 1

		threshold = C_ArtifactUI.GetCostForPointAtRank(spentPoints, tier)
	end
	return availablePoints, unspentPower, threshold
end

---@return integer @artifact power
---@return integer @max
---@return integer @artifact level
---@return integer @artifact item id
---@return string @artifact name
---@return integer @unspent power
---@return integer @available points
function artifact:GetValues()
	local itemId, _, name, _, unspentPower, spentPoints, _, _, _, _, _, _, tier = C_ArtifactUI.GetEquippedArtifactInfo()
	local availablePoints, power, threshold = GetAvailablePoints(spentPoints, unspentPower, tier)

	return power, threshold, spentPoints + availablePoints, itemId, name, unspentPower, availablePoints
end

function artifact:OnMouseUp()
	if not _G.ArtifactFrame or not _G.ArtifactFrame:IsShown() then
		SocketInventoryItem(_G.INVSLOT_MAINHAND)
	else
		HideUIPanel(_G.ArtifactFrame)
	end
end

function artifact:UpdateTooltip()
	local value, max, _, _, name, unspentPower, availablePoints = self:GetValues()

	GameTooltip:SetText(name, _G.HIGHLIGHT_FONT_COLOR:GetRGB())
	GameTooltip:AddLine(
		_G.ARTIFACT_POWER_TOOLTIP_TITLE:format(
			BreakUpLargeNumbers(unspentPower, true),
			BreakUpLargeNumbers(value, true),
			BreakUpLargeNumbers(max, true)
		),
		nil,
		nil,
		nil,
		true
	)
	GameTooltip:AddLine(_G.ARTIFACT_POWER_TOOLTIP_BODY:format(availablePoints), nil, nil, nil, true)
end

---@return boolean?
function artifact:Visibility(_, slot)
	if slot and slot ~= _G.INVSLOT_MAINHAND then
		return
	end

	return HasArtifactEquipped()
		and not C_ArtifactUI.IsEquippedArtifactMaxed()
		and not C_ArtifactUI.IsEquippedArtifactDisabled()
end

ns.modes[#ns.modes + 1] = artifact
