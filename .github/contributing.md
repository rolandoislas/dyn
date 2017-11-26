# How to Contribute

A working knowledge of Git and Lua/ComputerCraft/OpenComputers scripting is required for developing programs for this
 repository.

# Tests

Tests are contained in the `tests` folder. Python(3) is used for the test scripts which will be automatically run
 on pull requests.
 
- test_lua.py - runs Luacheck (a Lua linter) on the lua directory
- test_repo.py - checks the repo index file for valid entries and syntax errors. This will also check that all files
    defined in the index are present.
 
## Testing locally

- [Luacheck] must be installed to run the lua test
- Run [pytest] from the repos root path

The Python SimpleHTTPServer module is useful for testing the repo in-game locally.

# License

Scripts can be submitted with any license, but the license must allow distribution of the script by 
 PeripheralsPlusOne/Dyn and modifications. Recommended licenses are the GPLv2, MIT, and Apache.
 
**Please define a license in the script header and optionally in the help file.**

# Contributing

Contributing a change will require the following general steps to be executed:

- Fork the repo
- Commit the changes
- Submit a pull request

The pull request will not be reviewed if the automatic tests fail.

## Example Program

The index file `index.json` contains an example program entry. It is located in its own directory: `lua/example`

### Main Script and Help File

The two required files are the main script and its help file.

The script file name must match the name given in the index and it must reside in the the directory defined in the 
 index. For the example program the Lua file is located at `lua/example/example.lua` and its help text is located at
 `lua/example/example.txt`.

### Index Entry

The following instructions describe the format for `index.json`, which is the index used by Dyn. If contributing a
 script for OpenComputers, see `programs.cfg` and the [OpenComputers documentation] for 
 _The OpenPrograms Package Manager_ (OPPM).

```json
{
    "directory": "lua/example",
    "name": "example",
    "peripherals": ["*"],
    "extra": ["example_lib.lua"],
    "version": "1.0",
    "depends": [],
    "description": "An example program for the Dyn package manager"
}
```

#### Values

- directory
  - string
  - relative path from the repo root - **Use "lua/\<dir\>"**
  - does not need to be unique between programs
  - If the program is a general helper function it can go in a general peripheral named folder. Alternatively, and
      recommended if adding extra files, a unique folder name can be used.
- name
  - string
  - name of the program
  - This should be an alpha-numeric string with dashes and underscores allowed.
  - This will be the name of the
- peripherals
  - list of strings
  - peripheral names that this program supports
  - must have at least one peripheral supported
  - To support all peripheral types, set the value to an asterisk "\*". The peripheral names must match the names 
      provided by the peripherals in-game.
- extra
  - list of strings
  - may be an empty list
  - defines additional files that should be installed with the base program
  - Use this for includes or other resources that need to be present for the program to function
  - Files are mounted at /rom/programs/peripheralsplusone/\<program_name\>/\<file_name\>
- version
  - string
  - this is used to calculate if a program can be updated
  - Format: \<integer major\>.\[integer minor\].\[integer revision\]-\[alpha/beta/release\]-\[integer release_number\]
    - Example: 1.0.0-alpha-1, 1.0.0-alpha, 1.0.0, 1.0, 1
- depends
  - list of string
  - programs that need to be installed for this program to run
  - Since this is the main repo, **dependencies can only be for programs in this repo**.
- description
  - string
  - a short description of a program's purpose

[Luacheck]: https://github.com/mpeterv/luacheck
[pytest]: https://docs.pytest.org/en/latest/
[OpenComputers documentation]: http://ocdoc.cil.li/tutorial:program:oppm