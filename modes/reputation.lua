local _, ns = ...
ns = ns.__Progress

local MAX_REPUTATION_REACTION = _G.MAX_REPUTATION_REACTION

---@type Mode
local reputation = {}

reputation.name = 'reputation'
reputation.color = CreateColor(1, 1, 1)
reputation.events = {
	UPDATE_FACTION = true,
}
reputation.info = '[progress:missing][ ($>progress:reps<$)]'
reputation.status = {}

---@param _ Progress
---@param unit WowUnit
---@return integer value
---@return integer max
---@return integer standingId
---@return integer factionId
---@return string standingText
---@return string name
---@return boolean hasPendingReward
function reputation:GetValues(_, unit)
	local name, standingId, min, max, value, factionId = GetWatchedFactionInfo()
	local friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionId)
	local hasPendingReward = false
	local standingText = nil

	if friendshipInfo.friendshipFactionID == factionId then
		if not friendshipInfo.nextThreshold then
			min, max, value = 0, 1, 1 -- force full bar when maxed out
		end
		standingId = 5 -- force friend color
		standingText = friendshipInfo.text
	else
		local paragonValue, threshold, _, rewardPending = C_Reputation.GetFactionParagonInfo(factionId)
		if paragonValue then
			value = paragonValue % threshold
			min = 0
			max = threshold
			standingId = MAX_REPUTATION_REACTION + math.ceil(paragonValue / threshold)
			standingText = _G.PARAGON
			hasPendingReward = rewardPending
		end
	end

	standingText = standingText or GetText('FACTION_STANDING_LABEL' .. standingId, UnitSex(unit))

	-- normalize values
	max = max - min
	value = value - min

	if value == max then
		-- min, value and max are all equal to zero for maxed-out factions
		value, max = 1, 1
	end

	return value, max, standingId, factionId, standingText, name, hasPendingReward
end

---@param element Progress
function reputation:Load(element)
	-- we do this instead of using FACTION_UPDATE as a visiblity event
	-- because else the reputation bar will be displayed every time the player
	-- gains reputation
	hooksecurefunc('SetWatchedFactionIndex', function(selectedIndex)
		local isCurrentMode = self == element.mode
		local function handler()
			element.__owner:UnregisterEvent('UPDATE_FACTION', handler)
			ns.CallbackRegistry:TriggerEvent('OnVisibilityChanged', self, self:Visibility())
		end

		if isCurrentMode and selectedIndex == 0 or not isCurrentMode and selectedIndex > 0 then
			element.__owner:RegisterEvent('UPDATE_FACTION', handler, true)
		end
	end)
end

function reputation:OnMouseUp()
	ToggleCharacter('ReputationFrame')
end

---@param element Progress
---@param _ integer
---@param _ integer
---@param standingId integer
function reputation:UpdateColor(element, _, _, standingId)
	local color = element.__owner.colors.reaction[math.min(standingId, MAX_REPUTATION_REACTION + 1)]

	if color then
		element:SetStatusBarColor(color[1], color[2], color[3])
	end
end

---@param element Progress
function reputation:UpdateTooltip(element)
	local value, max, standingId, factionId, standingText, name, hasPendingReward = self:GetValues(element, 'player')
	local rewardAtlas = hasPendingReward and ' |A:ParagonReputation_Bag:0:0:0:0|a' or ''
	local _, description = GetFactionInfoByID(factionId)
	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionId)
	local currentRank = rankInfo and rankInfo.currentLevel
	local maxRank = rankInfo and rankInfo.maxLevel
	local rankText
	if currentRank and maxRank and currentRank > 0 and maxRank > 0 then
		rankText = (' (%s / %s)'):format(currentRank, maxRank)
	end
	local color = element.__owner.colors.reaction[math.min(standingId, MAX_REPUTATION_REACTION + 1)]

	GameTooltip:SetText(('%s%s'):format(name, rewardAtlas), color[1], color[2], color[3])
	GameTooltip:AddLine(description, nil, nil, nil, true)
	if rankText then
		GameTooltip:AddLine(_G.RANK .. rankText, 1, 1, 1)
	end
	GameTooltip:AddLine(
		value ~= max and ('%s (%s / %s)'):format(standingText, BreakUpLargeNumbers(value), BreakUpLargeNumbers(max))
			or standingText,
		1,
		1,
		1
	)
end

---@return boolean
function reputation:Visibility()
	return not not (GetWatchedFactionInfo())
end

ns.modes[#ns.modes + 1] = reputation
