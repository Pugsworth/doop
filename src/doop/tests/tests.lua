local doop = require("src.doop.doop")
local Test = require("src.test")
local util = require("src.util")

Test.test("Sanity Checks", function(expect)
    expect(true, "Should not error"):toBeTrue()
    expect(false, "Should error"):toBeTrue()
end)

--[[
    What needs to be tested:
    - [ ] Class creation
        - Creates a class definition table
        - Definition table has a .prototype and .meta table
        - Can add methods to .prototype table and meta methods to .meta table

    - [ ] Class inheritance
        - Class inherits from a parent class.
        - Methods called on child class are called from parent class with the child class as the first argument.
        - The check for a method goes up the parent chain until it finds a method or nil.
        - child.method2(child, ...) -> parent.method2(child, ...)

    - [ ] Instance creation
        - Can create an instance of the class via either:
            - doop.create(class_name, ...)
            - class_def(...)
            - class_def:new(...)
        - Any two instances are not the same object.

    - [ ] Instance method calling
        - Calling a method on a class instance calls the method on the class prototype table.
        - instance:method() -> instance.prototype.method(instance)

    - [ ] Instance properties
        - Properties are pulled from the instance table and not the prototype or meta tables.
        - instance.property -> any value

    - [ ] Instance metamethods
        - Metamethods are pulled from the instance.meta table.
        - print(instance) -> instance.meta.__tostring, etc

    - [ ] Class [static] properties
        - Class instance cannot access the static properties
        - instance.static_property -> nil
        - class.static_property -> value

    - [ ] Class [static] methods
        - Class instance cannot access the static methods
        - instance.static_method() -> nil
        - class.static_method() -> value

    - [ ] doop guards and checks
        - doop.isClass(class) -> true/false
        - doop.instanceOf(instance, class) -> true/false
        - doop.doesImplement(instance, interface) -> true/false
        - doop.getType(instance) -> class_name or Lua type
        - doop.expects(instance, class) -> true/error

    - [ ] Instance guards and checks
        - instance:instanceOf(class) -> true/false
        - instance:implements(interface) -> true/false
        - instance:getType() -> class_name

    - [ ] Interface creation
        - Creates an interface definition table.

    - [ ] Interface implementation
        - Class implements an interface.
        - Class can check if it implements an interface.
--]]

local Queue

Test.test("Class creation", function(expect)
    Queue = doop.Class("Queue", function(self, prefill)
        self._queue = {}
        self._size = 0
        for _, v in ipairs(prefill or {}) do
            self:push(v)
        end
    end, nil)

    expect(Queue.name, "Class name"):toBe("Queue")

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

    function Queue.prototype.peek(self)
        return self._queue[0]
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


    local q = Queue()
    for i = 1, 10 do
        q:push(i)
    end

    expect(q:size(), "Queue size"):toBe(10)

    for i = 1, 10 do
        expect(q:pop(), string.format("Queue pop order(%s)", i)):toBe(i)
    end

    expect(q:size(), "Queue size after pop"):toBe(0)
end)


Test.test("interface creation", function(expect)
    local IContainer = doop.interface("IContainer")
    IContainer.property("size", "number")
    IContainer.method("empty", "boolean")

    Test.test("interface implements", function(expect2)
        local queue = doop.Class("Queue", function(self, prefill)
            self._queue = {}
            self._size = 0
            for _, v in ipairs(prefill or {}) do
                self:push(v)
            end
        end, nil)
        function queue.prototype.isEmpty(self)
            return self._size == 0
        end
        doop.implements(queue, "IContainer")

        local q = queue()
        if doop.doesImplement(q, "IContainer") then
            expect2(q):toHaveMethod("empty")
            expect2(q:empty()):toBeTrue()
        end

    end)
end);


--[[
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
--]]