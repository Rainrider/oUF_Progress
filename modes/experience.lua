local _, ns = ...
ns = ns.__Progress

---@type Mode
local experience = {}

experience.name = 'experience'
experience.color = CreateColor(0.58, 0, 0.55, 0.5)
experience.restedColor = CreateColor(0, 0.39, 0.88, 0.5)
experience.events = {
	PLAYER_XP_UPDATE = true,
	UPDATE_EXHAUSTION = true,
	PLAYER_ENTERING_WORLD = true,
}
experience.visibilityEvents = {
	DISABLE_XP_GAIN = true,
	ENABLE_XP_GAIN = true,
	PLAYER_LEVEL_UP = true,
	UPDATE_EXPANSION_LEVEL = true,
}

---@param element Progress
function experience:Activate(element)
	---@type Texture
	local elementTexture = element:GetStatusBarTexture()
	local rested = element:CreateTexture(nil, 'OVERLAY')
	rested:SetTexture(elementTexture:GetTexture())
	rested:SetVertexColor(experience.restedColor:GetRGBA())
	rested:SetPoint('TOPLEFT', elementTexture, 'TOPRIGHT')
	rested:SetPoint('BOTTOMLEFT', elementTexture, 'BOTTOMRIGHT')

	element.Rested = rested
end

---@param element Progress
function experience:Deactivate(element)
	element.Rested:Hide()
	element.Rested = nil
end

---@param _ Progress
---@param unit string
---@return number value
---@return number min
---@return number max
---@return number level
---@return number rested
function experience:GetValues(_, unit)
	local value = UnitXP(unit)
	local max = UnitXPMax(unit)
	local level = UnitLevel(unit)
	local rested = GetXPExhaustion() or 0

	return value, 0, max, level, rested
end

---@param element Progress
---@param value number
---@param _ number
---@param max number
---@param rest table
function experience:PostUpdate(element, value, _, max, _, rest)
	local rested = unpack(rest)
	local missingXp = max - value
	if (rested > missingXp) then
		rested = missingXp
	end
	local width = element:GetWidth() * rested / max

	element.Rested:SetWidth(math.max(width, 0.1))
end

function experience:UpdateColor(element, _, _, _, _, rest)
	local rested = rest[1]

	if (rested > 0) then
		element:SetStatusBarColor(self.restedColor:GetRGB())
		element.Rested:SetVertexColor(self.restedColor:GetRGBA())
	else
		element:SetStatusBarColor(self.color:GetRGB())
		element.Rested:SetVertexColor(self.color:GetRGBA())
	end
end

---@param element Progress
function experience:UpdateTooltip(element)
	local value, _, max, level, rested = self:GetValues(element, element.__owner.unit)
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
	local exhaustionCooldown = GetTimeToWellRested()

	GameTooltip:SetText(('%s (%s)'):format(_G.COMBAT_XP_GAIN, _G.UNIT_LEVEL_TEMPLATE:format(level)))
	GameTooltip:AddLine(
		('%s / %s (%d%%)'):format(
			BreakUpLargeNumbers(value),
			BreakUpLargeNumbers(max),
			value / max * 100 + 0.5
		),
		1, 1, 1
	)

	if (rested > 0) then
		local restedText = (': %s (%d%%)'):format(BreakUpLargeNumbers(rested), rested / max * 100 + 0.5)

		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(
			_G.EXHAUST_TOOLTIP1:format(exhaustionStateName .. restedText, exhaustionStateMultiplier * 100)
		)
	end

	if (IsResting()) then
		if (exhaustionCooldown) then
			GameTooltip:AddLine(_G.EXHAUST_TOOLTIP4:format(exhaustionCooldown / 60))
		end
	elseif (exhaustionStateID == 4 or exhaustionStateID == 5) then
		GameTooltip:AddLine(_G.EXHAUST_TOOLTIP2)
	end
end

---@return boolean
function experience:Visibility()
	local maxLevel = GetRestrictedAccountData()

	if (maxLevel == 0) then
		maxLevel = GetMaxLevelForPlayerExpansion()
	end

	return not (maxLevel == UnitLevel('player') or IsXPUserDisabled())
end

ns.modes[#ns.modes + 1] = experience
