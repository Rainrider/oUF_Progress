local _, ns = ...
local oUF = ns.oUF or _G.oUF
ns = ns.__Progress

---@class Progress : StatusBar
---@field __owner any
---@field mode Mode
---@field modes table<number, Mode>
---@field tooltipAnchor string @todo better type-hint
---@field inAlpha number
---@field outAlpha number

---@param value number
---@param min number
---@param max number
---@param level number
---@vararg any
---@return number @The current bar value
---@return number @The minimum bar value
---@return number @The maximum bar value
---@return number @The current level
---@return table @The rest of passed arguments
local function extract(value, min, max, level, ...)
	return value, min, max, level, {...}
end

local function printWarning()
	print('|cff0099ccoUF Progress:|r', 'no other visible modes available')
end

---@param frame any
---@param event string
---@param unit WowUnit
local function Update(frame, event, unit)
	unit = unit or frame.unit
	if (unit ~= 'player') then return end

	---@type Progress
	local element = frame.Progress
	local mode = element.mode

	if (not mode) then return end

	if (element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local value, min, max, level, rest = extract(mode:GetValues(event, unit))

	if (element.SetAnimatedValues) then
		element:SetAnimatedValues(value, 0, max, level)
	else
		element:SetMinMaxValues(min, max)
		element:SetValue(value)
	end

	if (mode.UpdateColor) then
		mode:UpdateColor(element, value, min, max, level, rest)
	end

	if (mode.PostUpdate) then
		mode:PostUpdate(element, value, min, max, level, rest)
	end

	if (element.PostUpdate) then
		element:PostUpdate(value, min, max, level, rest)
	end
end

---@param element Progress
---@param modeName string
---@return Mode
---@return number
local function ResolveMode(element, modeName)
	for index, mode in next, element.modes do
		if mode.name == modeName then
			return mode, index
		end
	end
end

---@param element Progress
---@param on boolean
local function ToggleEvents(element, on)
	local mode = element.mode
	if (not mode) then return end

	local frame = element.__owner
	local Toggle = on and frame.RegisterEvent or frame.UnregisterEvent

	for event, isUnitless in next, mode.events do
		Toggle(frame, event, Update, isUnitless)
	end
end

---@param element Progress
---@param mode? Mode
local function SetMode(element, mode)
	if (element.mode and element.mode.Deactivate) then
		element.mode:Deactivate(element)
	end

	ToggleEvents(element, false)

	element.mode = mode

	if (not mode) then
		return element:Hide()
	end

	element:Show()
	element:SetStatusBarColor(mode.color:GetRGB())

	if (mode.Activate) then
		mode:Activate(element)
	end

	ToggleEvents(element, true)

	element:ForceUpdate()
end

---@param element Progress
---@param mode Mode
---@param index? integer
---@return Mode nextMode
---@return integer nextIndex
local function GetNextMode(element, mode, index)
	local modeIndex = index or select(2, ResolveMode(element, mode.name))
	local nextIndex = modeIndex % #element.modes + 1

	return element.modes[nextIndex], nextIndex
end

---@param element Progress
---@param mode Mode
---@param on boolean
local function SetNextVisibleMode(element, mode, on)
	local isCurrentMode = element.mode == mode
	if (mode and not isCurrentMode) then
		if (on and mode:Visibility()) then
			return SetMode(element, mode)
		end
	end

	-- re-showing the current mode ar hiding another one
	if (mode and on and isCurrentMode or not (on or isCurrentMode)) then return end

	local currentMode = element.mode
	local remainingModes = #element.modes
	local nextMode, index

	while (remainingModes > 0) do
		nextMode, index = GetNextMode(element, mode, index)

		if (nextMode:Visibility()) then
			if (nextMode == currentMode) then
				printWarning()
			end

			return SetMode(element, nextMode)
		end

		remainingModes = remainingModes - 1
	end

	if (remainingModes == 0) then
		printWarning()
		SetMode(element, nil)
	end
end

---@param element Progress
local function OnEnter(element)
	element:SetAlpha(element.inAlpha)
	---@type GameTooltip
	GameTooltip:SetOwner(element, element.tooltipAnchor)
	element.mode:UpdateTooltip(element)
	GameTooltip:Show()
end

---@param element Progress
local function OnLeave(element)
	if (element.mode and element.mode.CancelItemLoadCallback) then
		element.mode:CancelItemLoadCallback()
	end

	element:SetAlpha(element.outAlpha)
	GameTooltip:Hide()
end

---@param element Progress
---@param button MouseButton
local function OnMouseUp(element, button)
	if (button == 'LeftButton') then
		SetNextVisibleMode(element, element.mode)
		element.mode:UpdateTooltip(element)
		GameTooltip:Show()
	else
		if (element.mode.OnMouseUp) then
			element.mode:OnMouseUp(element, button)
		end
	end
end

local function Path(frame, ...)
	---@type Progress
	local element = frame.Progress

	return (element.Override or Update)(frame, ...)
end

---@param element Progress
local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

---@param element Progress
local function initVisibilityHandlers(element)
	for _, mode in next, element.modes do

		for event, isUnitless in next, mode.visibilityEvents or {} do
			local handler = function(_, evt, ...)
				SetNextVisibleMode(element, mode, mode:Visibility(evt, ...))
			end

			element.__owner:RegisterEvent(event, handler, isUnitless)
		end
	end
end

local function callLoaders(element)
	for _, mode in next, element.modes do
		if (mode.Load) then
			mode:Load(element)
		end
	end
end

local function Enable(self, unit)
	---@type Progress
	local element = self.Progress
	if (not element or unit ~= 'player') then return end

	element.__owner = self
	element.modes = ns.modes
	element.defaultMode = element.defaultMode or 'experience'
	element.SetNextVisibleMode = SetNextVisibleMode
	element.ForceUpdate = ForceUpdate

	ns.CallbackRegistry:RegisterCallback('OnVisibilityChanged', SetNextVisibleMode, element)
	initVisibilityHandlers(element)
	callLoaders(element)

	if (element:IsMouseEnabled()) then
		element.tooltipAnchor = element.tooltipAnchor or 'ANCHOR_BOTTORIGHT'
		element.inAlpha = element.inAlpha or 1
		element.outAlpha = element.outAlpha or 1
		element:SetAlpha(element.outAlpha)

		if (not element:GetScript('OnEnter')) then
			element:SetScript('OnEnter', OnEnter)
		end

		if (not element:GetScript('OnLeave')) then
			element:SetScript('OnLeave', OnLeave)
		end

		if (not element:GetScript('OnMouseUp')) then
			element:SetScript('OnMouseUp', OnMouseUp)
		end
	end

	if (element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
		element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	end

	element:SetNextVisibleMode(ResolveMode(element, element.defaultMode), true)
end

local function Disable(self)
	local element = self.Progress
	if (not element) then return end

	ToggleEvents(element, false)
end

oUF:AddElement('Progress', Path, Enable, Disable)
