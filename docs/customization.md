# Customization

## Options

- `element.defaultMode` - the name of the mode to display first (defaults to
  `'experience'`). Please note that this is not guaranteed as visibility events
  for other modes may fire after the default mode has loaded.
- `element.inAlpha` - the bar alpha when the element is hovered (defaults to 1)
- `element.outAlpha` - the bar alpha when the element is not hovered (defaults to 1)
- `element.tooltipAnchor` - the achor for the tooltip (defaults to
  `'ANCHOR_BOTTORIGHT'`)

Please note that the element has to be mouse-enabled for the tooltip related 
options to be taken into account. Use `element:EnableMouse(true)` in your layout
to enable mouse support.

## Callbacks

You can hook into the element's update routine by using the usual oUF hooks:

- `element:PreUpdate()` (optional)  
  Called before the element has been updated.
- `element:PostUpdate(value, max, level, rest)` (optional)  
  Called after the element has been updated.

Beside the usual oUF update hooks, there are some for the currently active mode:

- `mode:UpdateColor(element, value, max, level, rest)` (optional)  
  Called after the element has been updated.  
  Use this if you need dynamic color updates depending on the current bar values.  
  This overrides `mode.color`.
- `mode:PostUpdate(element, value, max, level, rest)` (optional)  
  Called after the element has been updated.

The above arguments are the ones provided by `mode:GetValues()` 
(see [Mode Interface](#mode-interface)) where returns after the third one are
packed into a table and passed as the last argument.

If you want to replace the complete `Update` routine, provide your own `Override`:

```lua
self.Progress.Override = function (self, event, ...)
	-- update the element and the current mode
end
```

If you want to add your custom modes or change the ones provided by the element,
you can use the following hooks. See [Mode Interface](#mode-interface) and the
mode related callbacks for further details.

- `element:Enable()` (optional)  
  Called after the stock modes have been added to the element and before the
  mode initialization routine. All available modes are placed in the array 
  `element.modes`
- `element:Disable()` (optional)  
  Called after the element has been disabled.

There are some more mode related callbacks:

- `mode:Load(element)` (optional)  
  Called when mode is loaded from the element's `Enable` method.  
  You can use this for mode specific initialization.
  See `modes/reputation.lua` for an example.
- `mode:Activate(element)` (optional)  
  Called when the mode becomes active (before the bar has been updated).  
  See `modes/experience.lua` for an example.
- `mode:Deactive(element)` (optional)  
  Called when the mode becomes inactive.  
  See `modes/experience.lua` for an example.
- `mode:CancelItemLoadCallback()` (optional)  
  Called from the element's `OnLeave` script handler.
  Use this to cancel a pending item data load.
  See `modes/azerite.lua` for an example.
- `mode:OnMouseUp(element, button)` (optional)  
  Called when the user performs any mouse click but left click on the element.  
  This is mainly useful to toggle related UI panels.
- `mode:UpdateTooltip(element)` (optional)  
  Called from the element's `OnEnter` script handler to display the modes tooltip.

## Mode Interface

A progress mode must provide only two methods:

- `mode:GetValues(element, unit)`  
  Must return the following normalized values:
  - `value` - the current mode value
  - `max` - the threshold for the next level/standing
  - `level` - the current level/standing
  - `barId` - used to diffentiate one bar from another within the same mode
    (i.e. factionId for reputation or itemId for artifacts)
  - `...` - any other values needed internally by the mode
- `mode:Visibility(event, ...)`  
  Must return a boolean to indicate if the mode should become active or inactive.
  This method is called after the user has clicked on the element to cycle to the
  next mode or when one of the mode's visibility events has been triggered.

Further, a mode has the following attributes:

- `mode.name`
- `mode.color`  
  a `ColorMixin` object for the static color to be used for the element's bar
  when the mode is active
- `mode.events`  
  a table where the keys are the events that should trigger the element's update
  routine and the values indicate if the corresponding event is unitless
- `mode.info` (optional)  
  a tag string to be shown as the info text on the element's bar when the mode
  is active
- `mode.status`  
  a table used as a cache by tag functions
- `mode.visibilityEvents` (optional)  
  a table of the events to trigger `mode:Visibility()`. Same format as `mode.events`
