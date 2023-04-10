-- namespace "TremorWatch.Components"

-- -- representing ordered collection of typed elements
-- __Arguments__{ AnyType }( Any )
-- class "List" (function(_ENV, TType)
--     property "Collection" { type = Any, default = {}}

--     property "Count" { type = Number, default = 0}

--     __Indexer__()
--     property "Items" {
--         set = function(self, idx, value)
--             self.Collection[idx] = value
--         end,
--         get = function(self, idx)
--             return self.Collection[idx]
--         end,
--         type = Number,
--     }

--     __Arguments__(TType)
--     function Add(self, item)
--         self.Count = self.Count + 1
--         self.Collection[self.Count] = item
--     end

--     __Arguments__(TType, Number)
--     function Insert(self, item, position)
--         self.Count = self.Count + 1

--         for i = position, self.Count do
--             self.Collection[i+1] = self.Collection[i]
--         end

--         self.Collection[position] = item
--     end

--     __Arguments__(TType)
--     function Remove(self, item)
--         local index = IndexOf(self, item)

--         if index ~= nil then
--             return RemoveAt(self, index)
--         end
--     end

--     function Pull(self)
--         local index = self.Count
        
--         if index > 0 then
--             return RemoveAt(self, index)
--         end
--     end

--     __Arguments__(Number)
--     function RemoveAt(self, index)
--         local item = self.Collection[index]
--         print("removing", item:GetName())
--         self.Collection[index] = nil
--         self.Count = self.Count - 1
        
--         for i = index, self.Count do
--             self.Collection[i] = self.Collection[i+1]
--         end
        
--         return item
--     end

--     __Arguments__(TType)
--     function IndexOf(self, item)
--         for i=1, self.Count do
--             if self.Collection[i] == item then
--                 return i;
--             end
--         end
--     end

--     function shallow_copy(t)
--         local t2 = {}
--         for k,v in pairs(t) do
--           t2[k] = v
--         end
--         return t2
--       end
-- end)