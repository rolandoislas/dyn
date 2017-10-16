---
--- Example Lib - An example library for an example program written for the dyn package manager
--- Author: Rolando Islas
--- Version: 1.0
--- License: GPLv2
---

local ExampleLib = {}
ExampleLib.__index = ExampleLib

function ExampleLib:new()
    local example_lib = {}
    setmetatable(example_lib, ExampleLib)
    return example_lib
end

function ExampleLib:print_help()
    print("Run \"help example\" for more information.")
end

return ExampleLib

