PLoop(function(_ENV)

    namespace "TremorWatch.Core"

    __Arguments__ { AnyType } (Any)
    class "Recycle" (function(_ENV, eletype)
        inherit "System.Recycle"

        property "Limit" {type = Number, default = -1}

        property "ItemsCreated" {type = Number, default = 0}

        property "ItemsFactory" {type = Callable/nil}

        __Arguments__(Callable/nil)
        function Recycle(self, factory)
            self.ItemsFactory = factory
            super(self, eletype)
        end

        __Arguments__(Number, Callable/nil)
        function Recycle(self, maxItemsCreated, factory) this(self, factory)
            self.Limit = maxItemsCreated
        end
        
        function New(self)
            if self.Limit ~= -1 and self.Limit > self.ItemsCreated then
                return nil
            end

            if self.ItemsFactory ~= nil then
                self.ItemsFactory(self.__arguments)
            else
                local item = super.New(self)
            end
            
            self.ItemsCreated = self.ItemsCreated + 1

            return item
        end

    end)
    
end)