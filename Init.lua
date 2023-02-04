local tempStorageName = "TwTempInitializer"
_G[tempStorageName] = {}
local tempStorage = _G[tempStorageName]

function tempStorage:Init()
    -- allows to omit PLoop() call at the begining of the lua script
    self._namespace = namespace
    namespace = function(namespaceName)
        local env = self._namespace(namespaceName)()
        setfenv(2, env)
    end
end

function tempStorage:Dispose()
    namespace = self._namespace

    _G[tempStorageName] = nil
    wipe(tempStorage)
end

tempStorage:Init()