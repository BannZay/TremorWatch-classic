namespace "TremorWatch.Components"

__Arguments__ { AnyType } (Any)
class "ItemsPool" (function(_, eletype)
    property "FreeItems" { type = List[eletype], factory = function() return List[eletype]() end }
    property "UsedItems" { type = List[eletype], default = function() return List[eletype]() end }

    event "OnRetrieved"

    event "OnReleased"

    event "OnShow"

    __Arguments__(eletype)
    function AddItem(self, item)
        self.FreeItems:Insert(item)
    end

    function Retrieve(self, ...)
        local item = self.FreeItems:RemoveByIndex()

        if item == nil then
            return nil
        end
        
        self.UsedItems:Insert(item)
        self.OnRetrieved(self, item, ...);

        return item
    end

    __Arguments__(eletype)
    function Release(self, item, ...)
        local index = self.UsedItems:IndexOf(item)

        if not index then
            return false
        end

        local item = self.UsedItems:RemoveByIndex(index);
        
        self.FreeItems:Insert(item)
        self.OnReleased(self, item, ...)

        return true
    end

    function ReleaseAll(self, ...)
        local item = self.UsedItems[1]

        while(item ~= nil) do
            Release(self, item, ...)
            item = self.UsedItems[1]
        end
    end

    function RetrieveAll(self, ...)
        while Retrieve(self, ...) ~= nil do end
    end
end)
