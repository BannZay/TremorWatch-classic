namespace "TremorWatch.Components"

__Arguments__ { AnyType } (Any)
class "LockableItem" (function(_, eletype)
    property "Item" { type = eletype }
    property "Locked" { type = Boolean }


    __Arguments__(eletype, Boolean / nil)
    function __ctor(self, item, locked)
        self.Item = item
        self.Locked = locked or false
    end
end)