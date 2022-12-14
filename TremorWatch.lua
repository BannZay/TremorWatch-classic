Scorpio "TremorWatch.Addon" "1.0.0"

import "TremorWatch.Core"
import "System.Reactive"

Log = TwLogger()
Log:AddHandler(function(msg) print(msg) end)
Log.UseTimeFormat = false

_AddonRealName = ...

_FramesPoolSize = 1 -- hardcoded to 1 untill all bugs are fixed
_FramesPool = ItemsPool[TremorWatchFrame]()
_Addon.updatersQueue = {}

function OnLoad()
	_Addon:SetSavedVariable("TremorWatchSettings")
		:UseConfigPanel()
	
	-- Log.LogLevel = _Config.logLevel:GetValue()
		
	_SVManager = SVManager("TremorWatchDB")

	for i = 1, _FramesPoolSize do
		local parentLockable = _FramesPool.Items[i - 1]
		local parent = parentLockable and parentLockable.Item
		
		local frame = TremorWatchFrame("TremorWatchFrame" .. i)

		Style[frame].Size = _Config.Size:Map(function(size) return Size(size or 0, size or 0) end)
		Style[frame].cooldown.Alpha = _Config.ShowPulses:Map(function(showPulses) return showPulses and 1 or 0 end)
		Style[frame].Alpha = _Config.Alpha

		if parent ~= nil then
			frame:AttachTo(parent)
			Style[frame].closeButton.Visible = false
		else
			Style[frame].Movable = _Config.TestMode
			Style[frame].mover.EnableMouseClicks = _Config.TestMode
			Style[frame].closeButton.Visible = _Config.TestMode
			frame.OnClose = frame.OnClose + function() _Config.TestMode = false end

			frame.mover.OnStopMoving = frame.mover.OnStopMoving + OnFramePositionChanged
			Style[frame].location = _SVManager.location
		end

		_FramesPool:AddItem(frame)
	end

	_FramesPool.OnReleased = _FramesPool.OnReleased + OnItemsPoolItemReleased
	_FramesPool.OnRetrieved = _FramesPool.OnRetrieved + OnItemsPoolItemRetrieved

	_Database = Database()
	
	Scorpio.Continue(function()
		Scorpio.Delay(0.5) -- let all events to fire before we consider an addon initialized
		_Addon.Initialized = true
		
		Log.Debug("Addon was marked as initialized. Running queued updaters")

		if #_Addon.updatersQueue > 0 then
			for _, queuedUpdater in pairs(_Addon.updatersQueue) do
				for _, lockableObject in pairs(_FramesPool.Items) do
					queuedUpdater(lockableObject.Item, lockableObject.Locked)
				end
			end
	
			_Addon.updatersQueue = nil
		end

		Log.Debug("Initialization completed")
	end)

end

function OnFramePositionChanged(self)
	self = self.MoveTarget
	local location = self:GetLocation({ Anchor("CENTER", 0, 0, "UIParent", "CENTER") })
	_SVManager.location  = location
end

__Arguments__(ItemsPool[TremorWatchFrame], TremorWatchFrame)
function OnItemsPoolItemReleased(itemsPool, item)
	Log.Trace("Item released: %s", item:GetName())
	item.TargetId = nil
	item.OwnerId = nil
	item:Hide()
end

__Arguments__(ItemsPool[TremorWatchFrame], TremorWatchFrame, { TargetId = String })
function OnItemsPoolItemRetrieved(itemsPool, item, args)
	Log.Trace("Item retrieved: %s (targetId = %s)", item:GetName(), args.TargetId)
	item.TargetId = args.TargetId
	item.OwnerId = args.OwnerId
	item:Show()
end

function IsOnArena()
	local instanceType = select(2, IsInInstance())
	return instanceType == "arena"
end

function SetTremor(ownerGuid, unitGuid)
	local isOnArenaOnly = true -- _Config.onArenaOnly:GetValue()
	if isOnArenaOnly and not IsOnArena() then
		return nil
	end

	ownerGuid = ownerGuid or "NA"
	unitGuid = unitGuid or "NA"

	for _, lockedItem in pairs(_FramesPool.Items) do
		if lockedItem.Item.TargetId == unitGuid or lockedItem.Item.OwnerId == ownerGuid then
			return nil
		end
	end

	_FramesPool:Retrieve({ TargetId = unitGuid, OwnerId = ownerGuid})
end

function DestroyTremor(ownerGuid, unitGuid)
	ownerGuid = ownerGuid or "NA"
	unitGuid = unitGuid or "NA"

	for _, lockableItem in pairs(_FramesPool.Items) do
		if lockableItem.Item.TargetId == unitGuid or lockableItem.Item.OwnerId == ownerGuid then
			_FramesPool:Release(lockableItem.Item)
		end
	end
end

function UpdateAllFrames(updater)
	if not _Addon.Initialized then
		table.insert(_Addon.updatersQueue, updater)
		return nil
	end

	for _, lockableObject in pairs(_FramesPool.Items) do
		updater(lockableObject.Item, lockableObject.Locked)
	end
end

function ReleaseAllFrames()
	UpdateAllFrames(function(frame) _FramesPool:Release(frame) end)
end

local function PlaySound(soundFileName)
	if _Addon.Initialized then
		local soundFile = string.format("Interface\\AddOns\\%s\\Sounds\\%s", _AddonRealName, soundFileName)
		PlaySoundFile(soundFile)
	end
end

local function PlayTickSound()
	if _Config.ShowPulses:GetValue() then
		PlaySound("short.wav")
	end
end

local function PlayShowSound()
	PlaySound("mallet-alert.mp3")
end

local function PlayHideSound()
	PlaySound("blink1.wav")
end

__SystemEvent__()
function ZONE_CHANGED_NEW_AREA()
	if not _Config.TestMode:GetValue() then
		ReleaseAllFrames()
	end
end

__SystemEvent__()
function COMBAT_LOG_EVENT_UNFILTERED()
	local _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = CombatLogGetCurrentEventInfo()
		
	Log.Trace("%s, %s, %s, %s", eventType, destGUID, sourceGUID, spellId)
	if eventType == "SPELL_SUMMON" then
		-- filter out ally shammy casts
		if _Database:IsEarthTototemId(spellId, spellName) or spellId == SpellId.TOTEMIC_RECALL then
			DestroyTremor(sourceGUID, destGUID)
		end

		if spellId == SpellId.TREMOR_TOTEM then
			SetTremor(sourceGUID, destGUID)
		end
	elseif eventType == "PARTY_KILL" then
		DestroyTremor(nil, destGUID)
	end
end

__Config__(_Config, "testMode", Boolean)
function _SetTestMode(value)
	ReleaseAllFrames()
	
	if value then
		-- lock all of them for testing purposes
		UpdateAllFrames(function(frame) _FramesPool:Retrieve({TargetId = "test"}) end)
	end
end

__Config__(_Config, "logLevel", Logger.LogLevel, Logger.LogLevel.Info)
function _SetLogLevel(level)
    Log.LogLevel = level
end

__Config__(_Config, "size", RangeValue[{ 30, 600, 1 }], 100) 
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

-- disabled untill related bugs are fixed
-- __Config__(_Config, "onArenaOnly", false)
 -- function _SetOnArenaOnly(value)
	-- if value and not IsOnArena() then
		-- ReleaseAllFrames()
	-- end
-- end