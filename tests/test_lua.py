import os
import subprocess


def test_lua_syntax():
    """
    Executes "Lua Check" on the lua directory. Fails if there is an error. Does not fail on warnings.

    :raises subprocess.CalledProcessError
    """
    path = os.path.join(os.path.dirname(__file__), "..", "lua")
    try:
        subprocess.check_output(["luacheck", path, "-qqq", "--no-color"])
    except subprocess.CalledProcessError as e:
        if b"/ 0 errors" not in e.output:
            subprocess.check_call(["luacheck", path])
