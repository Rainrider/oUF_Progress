---@alias MouseButton '"LeftButton"' | '"RightButton"' | '"MiddleButton"' | '"ButtonN"'

---@alias TooltipAnchor
---| '"ANCHOR_TOP"'
---| '"ANCHOR_RIGHT"'
---| '"ANCHOR_BOTTOM"'
---| '"ANCHOR_LEFT"'
---| '"ANCHOR_TOPLEFT"'
---| '"ANCHOR_TOPRIGHT"'
---| '"ANCHOR_BOTTOMRIGHT"'
---| '"ANCHOR_BOTTOMLEFT"'
---| '"ANCHOR_CURSOR"'
---| '"ANCHOR_PRESERVE"'
---| '"ANCHOR_NONE"'

---@alias ModeName
---| '"artifact"'
---| '"azerite"'
---| '"experience"'
---| '"honor"'
---| '"reputation"'

---@class Progress : StatusBar
---@field __owner any
---@field mode Mode @The currently active mode
---@field defaultMode? ModeName
---@field infoText? FontString
---@field modes Mode[]
---@field tooltipAnchor TooltipAnchor
---@field inAlpha number
---@field outAlpha number

---@class Mode
---@field name ModeName
---@field color ColorMixin @Used to color the bar when the mode is activated
---@field events table<string, boolean> @The events used to update the bar values. Disabled when the mode is inactive
local Mode = {}

---The events used to activate the mode. Disabled when the mode is active.
---The keys are event names and the values indicate whether the event is unitless
---_(Optional)_
---@type table<string, boolean>
Mode.visibilityEvents = {}

---Called when activating the mode.
---_(Optional)_
---@param element Progress
function Mode:Activate(element) end

---Called when deactivating the mode.
---_(Optional)_
---@param element Progress
function Mode:Deactive(element) end

---Called to cancel a pending item load.
---_(Optional)_
function Mode:CancelItemLoadCallback() end

---Called to supply the bar values. More values may be returned if needed
---@see Mode#PostUpdate
---@param element Progress
---@param unit WowUnit
---@return integer value
---@return integer min
---@return integer max
---@return integer level
---@return integer|string barId
function Mode:GetValues(element, unit) end

---Returns a string to be showed on the progress bar
---_(Optional)_
---@return string
function Mode:Info() end

---Called when the mode is initially loaded.
---_(Optional)_
---@param element Progress
function Mode:Load(element) end

---Handler for the `OnMouseUp` script event.
---Left clicks are reserved to change the current mode and won't be passed to this handler.
---@param element Progress
---@param button MouseButton
function Mode:OnMouseUp(element, button) end

---Called after the bar values have been updated.
---_(Optional)_
---@see Mode#GetValues
---@param element Progress
---@param value integer @The current bar value
---@param min integer @The minimum bar value
---@param max integer @The maximum bar value
---@param level integer @The current level
---@param rest any[] @The rest of the values returned by Mode#GetValues in preserved order
function Mode:PostUpdate(element, value, min, max, level, rest) end

---Called to update the bar color after the bar values have been set.
---_(Optional)_
---@see Mode#GetValues
---@param element Progress
---@param value integer @The current bar value
---@param min integer @The minimum bar value
---@param max integer @The maximum bar value
---@param level integer @The current level
---@param rest any[] @The rest of the values returned by Mode#GetValues in preserved order
function Mode:UpdateColor(element, value, min, max, level, rest) end

---Called to update the mode tooltip if the element is mouse-enabled and hovered.
---@param element Progress
function Mode:UpdateTooltip(element) end

---Called to deside on whether the mode should become or stay visible.
---If `Mode#visibilityEvents` is not empty, this method will be called from
---the event handler and `true` will activate inactive modes while `false`
---will deactive active modes.
---@param event WowEvent
---@param ... any @The rest of the event arguments
---@return boolean
function Mode:Visibility(event, ...) end