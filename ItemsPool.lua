PLoop(function(_ENV)

    namespace "TremorWatch.Core"

    __Arguments__ { AnyType } (Any)
    class "ItemsPool" (function(_ENV, eletype)
        property "Items" { type = List[LockableItem[eletype]], default = List[LockableItem[eletype]]() }

        property "LockedItems" {
            get = function(self)
                local items = {}
                for i, lockableItem in ipairs(self.Items) do
                    if lockableItem.Locked then
                        table.Insert(items, lockableItem.Item)
                    end
                end
                return items
            end
        }

        event "OnRetrieved"

        event "OnReleased"

        event "OnShow"

        __Arguments__(eletype)
        function AddItem(self, item)
            local lockableItem = LockableItem[eletype](item)
            self.Items:Insert(lockableItem)
        end

        function Retrieve(self, ...)
            for i, v in pairs(self.Items) do
                if not v.locked then
                    v.locked = true
                    OnRetrieved(self, v.Item, ...)
                    return item
                end
            end
        end

        __Arguments__(eletype)
        function Release(self, item, ...)
            for i, v in pairs(self.Items) do
                if v.Item == item and v.locked then
                    OnReleased(self, item, ...)
                    v.locked = false
                    return true
                end
            end

            return false
        end
    end)
    
end)
