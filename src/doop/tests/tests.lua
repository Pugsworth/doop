local classes = require("src.classes.classes")
local Test = require("src.test")
local util = require("src.util")

--[[
    What needs to be tested:
    - [ ] Class creation
        - classes.Class("name", ...) -> {<class-def>}
    - [ ] Class inheritance
        - child.method2(child, ...) -> parent.method2(child, ...)
    - [ ] Instance creation
        - class_def() -> class_def:new() -> {<new-table>}
    - [ ] Instance method calling
        - instance:method() -> instance.prototype.method()
    - [ ] Instance properties
        - instance.property -> value
    - [ ] Instance metamethods
        - print(instance) -> instance.meta.__tostring, etc
    - [ ] Class [static] properties
        - instance.static_property -> nil
        - class.static_property -> value
    - [ ] Class [static] methods
        - instance.static_method() -> nil
        - class.static_method() -> value
--]]

local Queue

Test.test("Class creation", function(expect)
    Queue = classes.Class("Queue", function(self, prefill)
        self._queue = {}
        self._size = 0
        for _, v in ipairs(prefill or {}) do
            self:push(v)
        end
    end, nil)

    expect(Queue.name).toEqual("Queue")

    function Queue.prototype.push(self, value)
        self._queue[self._size] = value
        self._size = self._size + 1
    end

    function Queue.prototype.pop(self)
        if self._size == 0 then
            return nil
        end

        local value = self._queue[0]
        for i = 1, self._size - 1 do
            self._queue[i - 1] = self._queue[i]
        end
        self._size = self._size - 1

        return value
    end

    function Queue.prototype.next(self)
        return Queue.prototype:pop()
    end

    function Queue.prototype.size(self)
        return self._size
    end

    function Queue.prototype.empty(self)
        return self._size == 0
    end

    function Queue.prototype.clear(self)
        self._queue = {}
        self._size = 0
    end

    function Queue.meta.__tostring(self)
        return string.format("Queue(%d)", self._size)
    end

    function Queue.meta.__len(self)
        return self._size
    end
end)



do 
    local Vec2 = classes.Class("Vec2", function(self, x, y)
        self.x = util.default(x, 0)
        self.y = util.default(y, 0)
    end, nil)

    function Vec2.prototype.add(self, x, y)
        if not y then
            y = x
        end

        local _x = self.x + x
        local _y = self.y + y


        return Vec2(_x, _y)
    end

    function Vec2.prototype.multiply(self, x, y)
        local y = util.default(y, x)

        local _x = self.x * x
        local _y = self.y * y

        return Vec2(_x, _y)
    end

    function Vec2.meta.__tostring(self)
        return string.format("Vec2(%.2g, %.2g)", self.x, self.y)
    end


    local v = Vec2(0, 0)
    assert(v.x == 0, "x != 0")
    assert(v.y == 0, "y != 0")

    v = v:add(1, 2)
    assert(v.x == 1, "x != 1")
    assert(v.y == 2, "y != 2")

    v = v:multiply(10, 10)
    assert(v.x == 10, "x != 10")
    assert(v.y == 20, "y != 20")

    print(v)



    local Vec2Derived = classes.Class("Vec2Derived", function(self, x, y)
        self.x = util.default(x, 0)
        self.y = util.default(y, 0)
    end, "Vec2")

    function Vec2Derived.prototype.add(self, x, y)
        return self.super.add(self, x, y)
    end

    function Vec2Derived.prototype.multiply(self, x, y)
        return self.super.multiply(self, x, y)
    end

    function Vec2Derived.meta.__tostring(self)
        return self.super.__tostring(self)
    end

    local vd = Vec2Derived(0, 0)
    assert(vd.x == 0, "x != 0")
    assert(vd.y == 0, "y != 0")
    vd = vd:add(1, 2)
    assert(vd.x == 1, "x != 1")
    assert(vd.y == 2, "y != 2")
    vd = vd:multiply(10, 10)
    assert(vd.x == 10, "x != 10")
    assert(vd.y == 20, "y != 20")
    print(vd)
end