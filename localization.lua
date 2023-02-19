local _, ns = ...
ns = ns.__Progress

local localizations = {}
local locale = _G.GetLocale()

-- usage:
--        set: ns.L('deDE')['New string'] = 'Neue Zeichenkette'
--        get: ns.L['New string']
local L = setmetatable({}, {
	__index = function(_, key)
		local localeTable = localizations[locale]
		return localeTable and localeTable[key] or tostring(key)
	end,
	__call = function(_, newLocale)
		localizations[newLocale] = localizations[newLocale] or {}
		return localizations[newLocale]
	end,
})

L('deDE')['Paragon'] = 'Huldigend'
L('esES')['Paragon'] = 'Baluarte'
L('esMX')['Paragon'] = 'Dechado'
L('frFR')['Paragon'] = 'Parangon'
L('itIT')['Paragon'] = 'Eccellenza'
L('ptBR')['Paragon'] = 'Paragão'
L('ruRU')['Paragon'] = 'Идеал'
L('koKR')['Paragon'] = '불멸의 동맹'
L('zhCN')['Paragon'] = '典范'
L('zhTW')['Paragon'] = '典範'

ns.L = L
