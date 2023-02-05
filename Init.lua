local DuringLoad = LibStub("DuringLoad-1.0")
 -- allows to omit PLoop() call at the begining of the lua scripts

local _namespace = namespace
DuringLoad:Replace("namespace", function(namespaceName) local env = _namespace(namespaceName)() setfenv(2, env) end)