namespace "TremorWatch.Components"

enum "SpellId" {
    ID_TOTEMIC_RECALL = 36936,
    TREMOR_TOTEM = 8143,
    EARTHBIND_TOTEM = 2484,
    EARTH_ELEMENTAL_TOTEM = 2062,

    STONESKIN_TOTEM1 = 8071,
    STONESKIN_TOTEM2 = 8154,
    STONESKIN_TOTEM3 = 8155,
    STONESKIN_TOTEM4 = 10406,
    STONESKIN_TOTEM5 = 10407,
    STONESKIN_TOTEM6 = 10408,
    STONESKIN_TOTEM7 = 25508,
    STONESKIN_TOTEM8 = 25509,
    STONESKIN_TOTEM9 = 58751,
    STONESKIN_TOTEM10 = 58753,

    STRENGTH_OF_EARTH_TOTEM1 = 8075,
    STRENGTH_OF_EARTH_TOTEM2 = 8160,
    STRENGTH_OF_EARTH_TOTEM3 = 8161,
    STRENGTH_OF_EARTH_TOTEM4 = 10442,
    STRENGTH_OF_EARTH_TOTEM5 = 25361,
    STRENGTH_OF_EARTH_TOTEM6 = 25528,
    STRENGTH_OF_EARTH_TOTEM7 = 57622,
    STRENGTH_OF_EARTH_TOTEM8 = 58643,

    STONECLAW_TOTEM1 = 5730,
    STONECLAW_TOTEM2 = 6390,
    STONECLAW_TOTEM3 = 6391,
    STONECLAW_TOTEM4 = 6392,
    STONECLAW_TOTEM5 = 10427,
    STONECLAW_TOTEM6 = 10428,
    STONECLAW_TOTEM7 = 25525,
    STONECLAW_TOTEM8 = 58580,
    STONECLAW_TOTEM9 = 58581,
    STONECLAW_TOTEM10 = 58582,
}

class "Database" (function()

    function IsEarthTotemId(self, spellId, spellName)
        return self.earthTototemIds[spellId]
    end

    local function GetEarthTotemIds()
        local totemIds = {}

        totemIds[SpellId.TREMOR_TOTEM] = true
        totemIds[SpellId.EARTHBIND_TOTEM] = true
        totemIds[SpellId.EARTH_ELEMENTAL_TOTEM] = true

        totemIds[SpellId.STONESKIN_TOTEM1] = true
        totemIds[SpellId.STONESKIN_TOTEM2] = true
        totemIds[SpellId.STONESKIN_TOTEM3] = true
        totemIds[SpellId.STONESKIN_TOTEM4] = true
        totemIds[SpellId.STONESKIN_TOTEM5] = true
        totemIds[SpellId.STONESKIN_TOTEM6] = true
        totemIds[SpellId.STONESKIN_TOTEM7] = true
        totemIds[SpellId.STONESKIN_TOTEM8] = true
        totemIds[SpellId.STONESKIN_TOTEM9] = true
        totemIds[SpellId.STONESKIN_TOTEM10] = true

        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM1] = true
        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM2] = true
        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM3] = true
        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM4] = true
        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM5] = true
        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM6] = true
        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM7] = true
        totemIds[SpellId.STRENGTH_OF_EARTH_TOTEM8] = true

        totemIds[SpellId.STONECLAW_TOTEM1] = true
        totemIds[SpellId.STONECLAW_TOTEM2] = true
        totemIds[SpellId.STONECLAW_TOTEM3] = true
        totemIds[SpellId.STONECLAW_TOTEM4] = true
        totemIds[SpellId.STONECLAW_TOTEM5] = true
        totemIds[SpellId.STONECLAW_TOTEM6] = true
        totemIds[SpellId.STONECLAW_TOTEM7] = true
        totemIds[SpellId.STONECLAW_TOTEM8] = true
        totemIds[SpellId.STONECLAW_TOTEM9] = true
        totemIds[SpellId.STONECLAW_TOTEM10] = true

        return totemIds
    end

    function __ctor(self)
        self.earthTototemIds = GetEarthTotemIds()
    end
end)
