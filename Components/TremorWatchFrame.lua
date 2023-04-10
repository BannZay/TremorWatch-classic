namespace "TremorWatch.Components"

class "TremorWatchFrame" (function()
    inherit "Frame"

    property "TargetId" {
        type = String,
        handler = function(self, value)
            self.version = self.version + 1
        end,
        default = nil,
    }

    property "Delay" { type = Number, default = 0 }

    property "ReleaseOnDemand" { type = Boolean, default = false }

    property "Hostile" {
        type = Boolean,
        default = false,
        handler = function(self, isHostile)
            local borderColor = Color.BLUE
            
            if isHostile then 
                borderColor = Color.RED 
            end

            Style[self].backdropBorderColor = borderColor
        end
    }

    event "OnTick"

    event "OnClose"

    __Arguments__(UI)
    function AttachTo(self, target)
        Style[self].location = { Anchor("LEFT", 0, 0, target:GetName(), "RIGHT") }
    end

    __Async__()
    function OnFrameShown(self)
        Next()
        local version = self.version
        while true do
            Delay(self.Delay)
            self.cooldown:SetCooldown(GetTime() - self.Delay, 3)
            Delay(3 - self.Delay)

            if self.version ~= version then
                return
            end

            self.OnTick(self)
        end
    end

    __Template__ {
        closeButton = UIPanelCloseButton,
        texture = Texture,
        cooldown = Cooldown,
        mover = Mover,
        border = Texture,
    }
    function __ctor(self)
        self.version = 0
        self.OnShow = self.OnShow + OnFrameShown
        self.closeButton.OnClick = function(btn) self.OnClose(btn) end
    end
end)

local BORDER_SIZE = 5
SHARE_STATUSBAR_SKIN            = {
       

}

Style.UpdateSkin("Default",
    {
        [TremorWatchFrame] = {
            backgroundTexture       = {
                drawLayer           = "BACKGROUND",
                setAllPoints        = true,
                color               = Color(0, 0, 0, 0.1),
            },
            backdrop                = {
                edgeFile            = [[Interface\Buttons\WHITE8x8]],
                edgeSize            = BORDER_SIZE,
            },
            backdropBorderColor = Color.BLUE,
            location    = { Anchor("CENTER") },
            size        = Size(130, 130),
            frameStrata = FrameStrata("MEDIUM"),
            visible     = false,
            texture     = {
                setAllPoints = true,
                drawLayer    = "BACKGROUND",
                file         = [[Interface\Icons\spell_nature_tremortotem]],
            },
            cooldown    = {
                reverse = false
            },
            mover       = {
                location = { Anchor("TOPLEFT"), Anchor("BOTTOMRIGHT") },
                enableMouseClicks = false,
            },
            closeButton = {
                location = { Anchor("TOPLEFT", -10, 10) },
                visible = false,
                framelevel = 5,
            },
        }
    })
