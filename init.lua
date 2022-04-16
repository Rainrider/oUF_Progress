local _, ns = ...

ns.__Progress = {}
ns.__Progress.modes = {}

local CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
CallbackRegistry:OnLoad()
CallbackRegistry:GenerateCallbackEvents({ 'OnVisibilityChanged' })
ns.__Progress.CallbackRegistry = CallbackRegistry
