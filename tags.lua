local _, ns = ...
local oUF = ns.oUF or _G.oUF

ns = ns.__Progress
local tags = {}
ns.tags = tags

tags['progress:reps'] = function ()
	---@type Progress
	local element = _FRAME.Progress
	local mode = element.mode
	local status = mode.status
	local value, max, level, barId = mode:GetValues(element, 'player')

	if (status.barId ~= barId) then
		status.barId = barId
		status.value = value
		status.max = max
		status.level = level
		status.delta = 0

		-- we don't have a known delta yet
		return ''
	end

	local delta = value - status.value

	if (level > status.level) then
		delta = delta + status.max
		status.max = max
		status.level = level
	elseif (level < status.level) then
		delta = delta - max
		status.max = max
		status.level = level
	end

	if (delta == 0) then delta = status.delta end
	if (delta == 0) then return '' end

	local remaining = delta > 0 and max - value or value

	status.value = value
	status.delta = delta

	return ('%d'):format(remaining / math.abs(delta) + 0.9)
end

tags['progress:delta'] = function ()
	-- populate status
	_TAGS['progress:reps']()

	---@type Progress
	local element = _FRAME.Progress
	local status = element.mode.status

	return status.delta ~= 0 and ('%+d'):format(status.delta) or ''
end

tags['progress:missing'] = function ()
	-- populate status
	_TAGS['progress:reps']()

	---@type Progress
	local element = _FRAME.Progress
	local status = element.mode.status

	return AbbreviateNumbers(status.delta < 0 and status.value or status.max - status.value)
end

for tag, func in next, tags do
	oUF.Tags.Methods[tag] = func
end
