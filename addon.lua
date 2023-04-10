Scorpio "TremorWatch.Addon" "1.0.0"

import "TremorWatch.Components"
import "System.Reactive"

Log = TwLogger()
_AddonRealName = ...

_FramesPoolSize = 3
_FramesPoolFriendly = ItemsPool[TremorWatchFrame]()
_FramesPoolHostile = ItemsPool[TremorWatchFrame]()
_Addon.updatersQueue = {}

dump = dump or function(self, i)
	for i, k in pairs(self) do
		print(i,k)
	end
end

_Aliases = {
	"tremorWatch",
	"tw"
}

function SortPoolIcons(framesPool)
	local leadingItem = nil

	for _, item in pairs(framesPool.UsedItems) do
		local location = item.Hostile and _SVManager.locationHostile or _SVManager.location
		Style[item].location = location
	end

	for _, item in pairs(framesPool.UsedItems) do
		if leadingItem ~= nil then
			item:AttachTo(leadingItem)
		end
		
		leadingItem = item
	end
end

function SetupLogging(logger)
	Log:AddHandler(function(msg) print(msg) end)
	Log.UseTimeFormat = false

	Log:LogSettingChanges(_Config.TestMode, "TestMode");
end

function InitializePool(pool, name, isHostile)
	for i = 1, _FramesPoolSize do
		local frame = TremorWatchFrame(name .. i)
		frame.mover.OnStopMoving = frame.mover.OnStopMoving + OnFramePositionChanged
		frame.OnClose = frame.OnClose + function(frame) _SetTestMode(false) end
		frame.Hostile = isHostile
		pool:AddItem(frame)
	end

	pool.OnReleased = pool.OnReleased + OnItemsPoolItemReleased + SortPoolIcons
	pool.OnRetrieved = pool.OnRetrieved + OnItemsPoolItemRetrieved + SortPoolIcons
end

function OnLoad()
	_Addon:SetSavedVariable("TremorWatchSettings")
		:UseConfigPanel()
	
	_SVManager = SVManager("TremorWatchDB")

	Style.UpdateSkin("Default", {
		[TremorWatchFrame] =
		{
			Size = _Config.Size:Map(function(size) return Size(size or 0, size or 0) end),
			Alpha = _Config.Alpha,
			Movable = _Config.TestMode,
			cooldown = 
			{ 
				Alpha = _Config.ShowPulses:Map(function(showPulses) return showPulses and 1 or 0 end) 
			}
		}
	}, true)

	SetupLogging()
	InitializePool(_FramesPoolFriendly, "TremorWatchFriendlyFrame")
	InitializePool(_FramesPoolHostile, "TremorWatchHostileFrame", true)

	_Database = Database()
	
	for _, alias in pairs(_Aliases) do
		_Addon:RegisterSlashCommand(alias, function() _Addon:ShowConfigUI() end)
	end

	Scorpio.Continue(function()
		Scorpio.Delay(0.5) -- let all events to fire before we consider an addon initialized
		_Addon.Initialized = true
		
		Log.Debug("Addon was marked as initialized. Running queued updaters")

		if #_Addon.updatersQueue > 0 then
			for _, queuedUpdater in pairs(_Addon.updatersQueue) do
				UpdateAllFrames(queuedUpdater, true)
			end
	
			_Addon.updatersQueue = nil
		end

		if (_Config.TestMode:GetValue()) then
			_Config.TestMode = false
			_Config.TestMode = true
		end
		Log.Debug("Initialization completed")
	end)

end

function OnFramePositionChanged(self)
	self = self.MoveTarget
	local location = self:GetLocation({ Anchor("CENTER", 0, 0, "UIParent", "CENTER") })
	if self.Hostile then
		_SVManager.locationHostile  = location
	else
		_SVManager.location  = location
	end
end

__Arguments__(ItemsPool[TremorWatchFrame], TremorWatchFrame)
function OnItemsPoolItemReleased(itemsPool, item)
	Log.Debug("Item released: %s", item:GetName())
	item.TargetId = nil
	item.OwnerId = nil
	item:Hide()
end

__Arguments__(ItemsPool[TremorWatchFrame], TremorWatchFrame, { TargetId = String })
function OnItemsPoolItemRetrieved(itemsPool, item, args)
	Log.Debug("Item retrieved: %s (targetId = %s)", item:GetName(), args.TargetId)
	item.TargetId = args.TargetId
	item.OwnerId = args.OwnerId
	item:Show()
end

function IsOnArena()
	local instanceType = select(2, IsInInstance())
	return instanceType == "arena"
end

function SetTremor(ownerGuid, unitGuid, isHostile)
	local isOnArenaOnly = _Config.onArenaOnly:GetValue()
	if isOnArenaOnly and not IsOnArena() then
		Log.Debug("Tremor set ignored: outside arena")
		return nil
	end

	ownerGuid = ownerGuid or "NA"
	unitGuid = unitGuid or "NA"

	local pool = isHostile and _FramesPoolHostile or _FramesPoolFriendly

	for _, item in pairs(pool.UsedItems) do
		if item.TargetId == unitGuid or item.OwnerId == ownerGuid then
			Log.Debug("Tremor set ignored: already set")
			return nil
		end
	end
	
	Log.Debug("Setting tremor icon UnitGuid = %s", unitGuid)
	local frame = pool:Retrieve({ TargetId = unitGuid, OwnerId = ownerGuid})
	frame.Hostile = isHostile
end

function TryDestroyTremor(ownerGuid, unitGuid, isHostile)
	Log.Trace("Removing tremor icon, UnitGuid = %s", unitGuid)
	ownerGuid = ownerGuid or "NA"
	unitGuid = unitGuid or "NA"

	local pool = isHostile and _FramesPoolHostile or _FramesPoolFriendly

	for _, item in pairs(pool.UsedItems) do
		if item.TargetId == unitGuid or item.OwnerId == ownerGuid then
			pool:Release(item)
			return true
		end
	end

	return false
end

function UpdateAllFrames(updater, forcedUpdate)
	if not forcedUpdate and not _Addon.Initialized then
		table.insert(_Addon.updatersQueue, updater)
		return nil
	end

	for _, item in pairs(_FramesPoolFriendly.FreeItems) do
		updater(item)
	end

	for _, item in pairs(_FramesPoolFriendly.UsedItems) do
		updater(item)
	end

	for _, item in pairs(_FramesPoolHostile.FreeItems) do
		updater(item)
	end

	for _, item in pairs(_FramesPoolHostile.UsedItems) do
		updater(item)
	end
end

local function PlaySound(frame, soundFileName)
	if _Addon.Initialized and frame.Hostile then
		local soundFile = string.format("Interface\\AddOns\\%s\\Sounds\\%s", _AddonRealName, soundFileName)
		PlaySoundFile(soundFile)
	end
end

local function PlayTickSound(frame)
	if _Config.ShowPulses:GetValue() then
		PlaySound(frame, "short.wav")
	end
end

local function PlayShowSound(frame)
	PlaySound(frame, "mallet-alert.mp3")
end

local function PlayHideSound(frame)
	PlaySound(frame, "blink1.wav")
end

__SystemEvent__()
function ZONE_CHANGED_NEW_AREA()
	if not _Config.TestMode:GetValue() then
		_FramesPoolFriendly:ReleaseAll()
		_FramesPoolHostile:ReleaseAll()
	end
end

__SystemEvent__()
function COMBAT_LOG_EVENT_UNFILTERED()
	if _Config.TestMode:GetValue() then return end

	local _, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, _, spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = CombatLogGetCurrentEventInfo()
	
	local hostileCast = bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0
	Log.Trace("CLEU: %s, %s, %s, %s, Hostile = %s", eventType, destGUID, sourceGUID, spellId, hostileCast)
		
	if _Database:IsEarthTotemId(spellId, spellName) or spellId == SpellId.ID_TOTEMIC_RECALL then
		local removed = TryDestroyTremor(sourceGUID, destGUID, hostileCast)
		
		if removed then
			Log.Debug("Removed tremor, triggered event = %s", "Shaman casted other earth totem or totem recall")
		end
	end

	if eventType == "SWING_DAMAGE" or "SPELL_DAMAGE" then
		local removed = TryDestroyTremor(nil, destGUID, not hostileCast)
		
		if removed then
			Log.Debug("Removed tremor, triggered event = %s", "Totem was attacked")
		end
	end
	
	if eventType == "SPELL_SUMMON" then
		if spellId == SpellId.TREMOR_TOTEM then
			if (not hostileCast and _Config.tft:GetValue()) or (hostileCast and _Config.tht:GetValue()) then
				SetTremor(sourceGUID, destGUID, hostileCast)
			else
				Log.Trace("Ignored set for non tracking totem type = %s", hostileCast and "hostile" or "friendly")
			end
		end
	end
end

__Config__(_Config, "testMode", Boolean, true)
function _SetTestMode(value)
	if _Config.tft:GetValue() then
		SetTestModeForPool(_FramesPoolFriendly, value)
	end
	
	if _Config.tht:GetValue() then
		SetTestModeForPool(_FramesPoolHostile, value)
	end
end

function SetTestModeForPool(pool, value)
	local leadingFrame = pool.UsedItems:First();
	pool:ReleaseAll()

	if value then
		pool:RetrieveAll({TargetId = "test"})
		leadingFrame = pool.UsedItems:First();
	end
	
	if leadingFrame ~= nil then
		Style[leadingFrame].mover.EnableMouseClicks = value
		Style[leadingFrame].closeButton.Visible = value
	end
end

__Config__(_Config, "logLevel", Logger.LogLevel, Logger.LogLevel.Info)
function _SetLogLevel(level)
    Log.LogLevel = level
end

__Config__(_Config, "size", RangeValue[{ 30, 600, 1 }], 50) 
function _SetSize(value) end

__Config__(_Config, "alpha", RangeValue[{ 0.1, 1, 0.1 }], 0.8) 
function _SetAlpha(value) end

__Config__(_Config, "delay", RangeValue[{ 0, 2.8, 0.1 }], 0)
function _SetDelay(value)
	UpdateAllFrames(function(frame) frame.Delay = value end)
end

__Config__(_Config, "showPulses", true) 
function _SetShowPulses(value) end

__Config__(_Config, "playSounds", true)
function _SetPlaySounds(value)
	UpdateAllFrames(function (frame)
		if value then
			frame.OnTick = frame.OnTick + PlayTickSound
			frame.OnHide = frame.OnHide + PlayHideSound
			frame.OnShow = frame.OnShow + PlayShowSound
		else
			frame.OnTick = frame.OnTick - PlayTickSound
			frame.OnHide = frame.OnHide - PlayHideSound
			frame.OnShow = frame.OnShow - PlayShowSound
		end
	end)
end

__Config__(_Config, "tft", true)
function _SetTrackFriendlyTotems(value)
	SetTestModeForPool(_FramesPoolFriendly, value and _Config.TestMode:GetValue())
end

__Config__(_Config, "tht", true)
function _SetTrackEnemiesTotems(value)
	SetTestModeForPool(_FramesPoolHostile, value and _Config.TestMode:GetValue())
end

__Config__(_Config, "onArenaOnly", false)
 function _SetOnArenaOnly(value)
	if value and not IsOnArena() then
		_FramesPoolFriendly:ReleaseAll()
		_FramesPoolHostile:ReleaseAll()
	end
end