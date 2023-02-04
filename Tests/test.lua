namespace "TremorWatch.Tests"

import "System"

PLoop.System.Logger.Default:AddHandler(print)

UnitTest "Test.Example" (function()
    __Test__()
    function Test1()
    end

    __Test__()
    function Test2()
    end
end)

UnitTest "Test.Example2" (function()
    __Test__()
    function Test1()
    end
end)

-- [03/12/19 13:00:49][Info][UnitTest]Test.Example.test1 PASS
-- [03/12/19 13:00:49][Warn][UnitTest]Test.Example.test2 Failed - Expected true condition@xxxx.lua:14
-- [03/12/19 13:00:49][Warn][UnitTest]Test.Example2.test1 Failed - Expected nil value@xxxx.lua:21
-- UnitTest("Test"):Run()
-- print("finish")
