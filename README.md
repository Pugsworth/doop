# Doop Class Library!

# About
doop is a class library for Lua that facilitates object oriented design. It is designed to be as simple and lightweight as possible while still providing a lot of useful functionality.
Due to the nature of Lua, This library is not intended to implement all of the features of a full object oriented language. If you require strong typing or other features, I suggest using a different language.

# Goals
Develop a library for Lua to create classes and interfaces.
With how flexible Lua is, it is possible to create class-like objects. However, this requires boilerplate that can be tedious to write and is error-prone. Did you get that metatable right? Did you remember to set the __index field? This library aims to make it easier to create classes and interfaces.

Features
- Define classes and interfaces.
- Classes can inherit from another class.
    - When a class inherits from another class, doop uses metatable magic to make lookups for fields and methods go up the inheritance chain.
- Classes can implement interfaces.
    - When a class implements an interface, doop will provide a default implementation of the interface's methods that will throw an error. This is to help you catch errors when you forget to implement an interface method. However, this is a runtime check. 
    - Each interface in a class is more of a promise that is added to a list. 
    - When you want to check if a class implements an interface, doop will check the list of interfaces the class promises to implement.
- Provide a loose typing system
  - doop will not enforce types or implementation of interfaces, but will provide guards and checks to help you catch errors.

# License
GPLv3 (see LICENSE file)

# Contributing
  Contributions are welcome!

  Fork the repository, make your changes, and submit a pull request. If you have any questions, feel free to open an issue. While I can't promise I'll be able to respond quickly, I will try to respond as soon as I can.

# Usage
#### Basic Usage
```lua
local doop = require("doop")

local MyClass = doop.Class("MyClass", function(self, ...)
    self.myField = "Hello, World!"
end, nil)

local myObject = MyClass()

print(myObject.myField) -> "Hello, World!"
```

The library is still in development. More documentation will be added as the library API is finalized.

# API
This is generated using [LDoc](https://github.com/lunarmodules/LDoc)  
See: docs/

🚧 This section is under construction! 🚧  
The API is still in development. This section will be updated as the API is finalized.



# TODO
- [ ] Add documentation
- [ ] Complete the test suite
- [ ] Add more examples after the API is finalized
- [ ] Provide definitions for transient types (tables that aren't real types but are used in the documentation for clarity) either in code along with the LDoc comments or in a separate file.
- [ ] Add a section to the README that explains the design decisions behind the library.
- [ ] Figure out if and how to create a LuaRocks package.