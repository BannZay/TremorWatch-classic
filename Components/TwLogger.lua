namespace "TremorWatch.Components"

class "TwLogger" (function()
    inherit "Logger"

    function __ctor(self)
        for name, value in Enum.GetEnumValues(Logger.LogLevel) do
            self[name] = function(...) self:Log(value, ...) end

        end

        self:SetPrefix(Logger.LogLevel.Trace, Color.GRAY .. "[Trace]" .. Color.CLOSE .. " ")
        self:SetPrefix(Logger.LogLevel.Debug, Color.WHITE .. "[Debug]" .. Color.CLOSE .. " ")
        self:SetPrefix(Logger.LogLevel.Info, Color.GREEN .. "[Info]" .. Color.CLOSE .. " ")
        self:SetPrefix(Logger.LogLevel.Warn, Color.ORANGE .. "[Warn]" .. Color.CLOSE .. " ")
        self:SetPrefix(Logger.LogLevel.Error, Color.RED .. "[Error]" .. Color.CLOSE .. " ")
        self:SetPrefix(Logger.LogLevel.Fatal, Color.DIMRED .. "[Fatal]" .. Color.CLOSE .. " ")
    end

    __Arguments__(Subject, String)
    function LogSettingChanges(self, observable, name)
        observable:Subscribe(function(value) self.Debug("%s: %s", name, value) end)
    end
end)
