local library = LibStub:NewLibrary("DuringLoad-1.0", 1);
if not library then return end

local currentAddonName = ...

local loadedAddons = {}
local addonsInjections = {}

-- todo: initialize addonName!
function library:Replace(name, value, addonName)
    addonName = addonName or currentAddonName
    
    if loadedAddons[addonName] then
        error("Addon was already loaded, this method should be called before addon initialized. Otherwise it makes no efferct")
    end

    local injections = addonsInjections[addonName]

    if injections == nil then
        injections = {}
        addonsInjections[addonName] = injections
    end

    injections[name] = { original = _G[name], inserted = value }
    _G[name] = value
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
f:RegisterEvent("ADDON_LOADED")

function f:ADDON_LOADED(addonName)
    loadedAddons[addonName] = true

    local injections = addonsInjections[addonName]

    if injections ~= nil then
        for name, injection in pairs(injections) do
            if _G[name] == injection.inserted then
                _G[name] = injection.original
            end
        end
    end
end