namespace "TremorWatch.Core"

__Arguments__ { AnyType } (Any)
class "Recycle" (function(eletype)
    inherit "System.Recycle"

    property "Limit" { type = Number, default = -1 }

    property "ItemsCreated" { type = Number, default = 0 }

    property "ItemsFactory" { type = Callable / nil }

    __Arguments__(Callable / nil)
    function Recycle(self, factory)
        super(self, eletype)
        self.ItemsFactory = factory
    end

    __Arguments__(Number, Callable / nil)
    function Recycle(self, maxItemsCreated, factory)
        super(self, factory)
        self.Limit = maxItemsCreated
    end

    function New(self)
        if self.Limit ~= -1 and self.Limit > self.ItemsCreated then
            return nil
        end

        local item
        if self.ItemsFactory ~= nil then
            item = self.ItemsFactory(self.__arguments)
        else
            item = super.New(self)
        end

        self.ItemsCreated = self.ItemsCreated + 1

        return item
    end
end)