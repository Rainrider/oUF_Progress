std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
}

files['definitions.lua'] = { ignore = { '212', '241' } }

read_globals = {
	'debugstack',
	'geterrorhandler',
	string = { fields = { 'join', 'split', 'trim' } },
	table = { fields = { 'removemulti', 'wipe' } },

	-- FrameXML
	'GameTooltip',
	'PVEFrame_ToggleFrame',

	-- Namespaces
	C_ArtifactUI = {
		fields = {
			'GetCostForPointAtRank',
			'GetEquippedArtifactInfo',
			'IsEquippedArtifactDisabled',
			'IsEquippedArtifactMaxed',
		},
	},
	C_AzeriteEssence = {
		fields = { 'CanOpenUI' },
	},
	C_AzeriteItem = {
		fields = {
			'FindActiveAzeriteItem',
			'GetAzeriteItemXPInfo',
			'GetPowerLevel',
			'IsAzeriteItemAtMaxLevel',
			'IsAzeriteItemEnabled',
		},
	},
    C_GossipInfo = { fields = { 'GetFriendshipReputation', 'GetFriendshipReputationRanks' } },
	C_MajorFactions = { fields = { 'GetMajorFactionData', 'HasMaximumRenown' } },
	C_PvP = {
		fields = {
			'GetNextHonorLevelForReward',
			'IsActiveBattlefield',
		},
	},
	C_Reputation = {
		fields = {
			'GetFactionDataByID',
			'GetFactionParagonInfo',
			'GetWatchedFactionData',
		},
	},
	C_Timer = { fields = { 'After' } },
	Item = { fields = { 'CreateFromItemLocation' } },

	-- Mixins
	'CallbackRegistryMixin',
	'CreateColor',

	-- Lua API
	'AbbreviateNumbers',
	'BreakUpLargeNumbers',
	'CreateFrame',
	'CreateFromMixins',
	'GetFactionInfoByID',
	'GetMaxLevelForPlayerExpansion',
	'GetRestrictedAccountData',
	'GetRestState',
	'GetText',
	'GetTimeToWellRested',
	'GetWatchedFactionInfo',
	'GetXPExhaustion',
	'HasArtifactEquipped',
	'hooksecurefunc',
	'HideUIPanel',
	'IsInActiveWorldPVP',
	'IsResting',
	'IsXPUserDisabled',
	'ShowUIPanel',
	'SocketInventoryItem',
	'ToggleCharacter',
	'UIParentLoadAddOn',
	'UnitHasVehiclePlayerFrameUI',
	'UnitLevel',
	'UnitHonor',
	'UnitHonorLevel',
	'UnitHonorMax',
	'UnitSex',
	'UnitXP',
	'UnitXPMax',
}

globals = {
	-- oUF custom env for tags
	_FRAME = { fields = { 'Progress' } },
	'_TAGS',
}
