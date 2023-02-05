--[[
    Library for running simple tests.
    
    This library does the typical "test", "describe", "it" thing in addition to providing
    some useful functions for testing like "should.be", "should.equal", etc.


    Example usage:
    local Test = require("test")

    Test.new(function(test)
        test.describe("Test", function()
            test.it("should work", function()
                test.should.equal(1, 1)
            end)

            test.it("should be true", function()
                test.should.be(false, true)
            end)
        end)
    end)

    Output:
    describe Test
        it should work
            ✅ 1 == 1
            ❌ false != true
--]]

local CHAR_PASSED = "✅"
local CHAR_FAILED = "❌"
local CHAR_SKIPPED = "⏭"
local INDENTATION = "\t"

local function tabulate(count)
    return string.rep(INDENTATION, count)
end

local function errorMsg(msg)
    print(string.format("%s%s %s", tabulate(2), CHAR_FAILED, msg))
end

local expectation = {
    __newindex = function()
        error(debug.traceback("Cannot modify expectation object"))
    end,
    __call = function(self, value, msg)
        self.value = value
        self.message = msg
        return self
    end
}
expectation.__index = expectation

--- Creates the "expect" function that will be passed to the testing callback function.
---@return function @The "expect" function.
local function buildExpected()
    return function(value, msg)
        return setmetatable({
            success = -1,
            value = value == nil and "" or value,
            message = msg == nil and "" or msg,
            errMsg = ""
        }, expectation)
    end
end

function expectation.toBe(self, value)
    self.success = self.value == value
    self.errMsg = string.format("'%s' != '%s'", tostring(self.value), tostring(value))
    self:evaluate()
end

function expectation.toBeCloseTo(self, value, delta)
    self.success = math.abs(self.value - value) < delta
    self.errMsg = string.format("%s != %s", tostring(self.value), tostring(value))
    self:evaluate()
end

function expectation.toByOfType(self, type)
    self.success = type(self.value) == type
    self.errMsg = string.format("'%s' is not of type '%s'", tostring(self.value), type)
    self:evaluate()
end

function expectation.toBeFalse(self)
    self.success = self.value == false
    self.errMsg = string.format("'%s' is not false", tostring(self.value))
    self:evaluate()
end

function expectation.toBeTrue(self)
    self.success = self.value == true
    self.errMsg = string.format("'%s' is not true", tostring(self.value))
    self:evaluate()
end

function expectation.toHaveProperty(self, prop)
    self.success = self.value[prop] ~= nil
    self.errMsg = string.format("'%s' does not have property '%s'", tostring(self.value), prop)
    self:evaluate()
end

function expectation.toHaveMethod(self, method)
    self.success = self.value[method] ~= nil and type(self.value[method]) == "function"
    self.errMsg = string.format("'%s' does not have method '%s'", tostring(self.value), method)
    self:evaluate()
end

function expectation.evaluate(self)
    if self.success == true then
        print(string.format("%s%s %s", tabulate(1), CHAR_PASSED, self.message))
    elseif self.success == false then
        print(string.format("%s%s %s\n%s%s",
            tabulate(1),
            CHAR_FAILED,

            self.message,
            tabulate(2),
            self.errMsg
        ))
    end
end


local Test = {}

function Test.test(name, fn)
    print(string.format("test '%s'", name))
    local expectFn = buildExpected()
    -- local expectObj = expectFn()
    local success, err = pcall(function()
        fn(expectFn)
    end)

    -- Some error occurred
    if not success then
        print(string.format("pcall failed!\n%s%s %s", tabulate(1), CHAR_FAILED, err))
    end
end


local function assertEqual(a, b, msg)
    if a ~= b then
        errorMsg(msg or string.format("%s == %s", tostring(a), tostring(b)))
    end
end

local function assertCloseEqual(a, b, msg, epsilon)
    if math.abs(a - b) > epsilon then
        errorMsg(msg or string.format("%s ~= %s", tostring(a), tostring(b)))
    end
end

local function assertTrue(a, b, msg)
    if a ~= true then
        errorMsg(msg or string.format("%s == true", tostring(a)))
    end
end

local function assertFalse(a, b, msg)
    if a ~= false then
        errorMsg(msg or string.format("%s == false", tostring(a)))
    end
end

local function assertHasProperty(obj, path, bFollowMeta, msg)
    local value = obj
    for part in string.gmatch(path, "[^%.]+") do
        value = value[part]
        if type(value) == "table" then
            value = value[part]
        elseif bFollowMeta and type(value) == "userdata" then
            value = value[part]
        else
            errorMsg(msg or string.format("%s has property '%s'", tostring(obj), path))
            return
        end
    end
end



return Test