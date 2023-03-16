local DuringLoad = LibStub("DuringLoad-1.0")
 -- allows to omit PLoop() call at the begining of the lua scripts

local _namespace = namespace
DuringLoad:Replace("namespace", function(namespaceName) setfenv(2, _namespace(namespaceName)()) end)