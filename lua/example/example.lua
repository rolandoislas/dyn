---
--- Example - An example program for the dyn package manager
--- Author: Rolando Islas
--- Version: 1.0
--- License: GPLv2
---

-- Extra files are stored at /rom/programs/peripheralsplusone/<directory_name_defined_in_the_index>/
local ExampleLib = require("peripheralsplusone.example.example_lib")
local example_lib = ExampleLib:new()
print(example_lib.print_help())