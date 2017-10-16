import json
import os

import sys

import re


def error(msg):
    """
    Write to stderr and return an exception
    :param msg: message to write
    :return: Exception
    """
    sys.stderr.write(msg + "\n")
    return Exception(msg)


def check_file_size(root, path_relative, program_name):
    """
    Checks a file exists and its size is not above one megabyte or the size is less than ten bytes
    :param root: the absolute path up to the directory containing the relative path
    :param path_relative: the relative path withing the root path
    :param program_name: name of the program that this path belongs to
    :return: None
    :raises Exception if the file size is not within the bounds or the file does not exist
    """
    path = os.path.join(root, path_relative)
    if not os.path.isfile(path):
        raise error("Program \"%s\" defines a file that is missing at <repo root>/%s" %
                    (program_name, path_relative))
    max_bytes = 1024 * 1024  # 1 megabyte - this seems generous for a ComputerCraft Lua script
    file_size = os.path.getsize(path)
    if file_size > max_bytes:
        raise error(("Program \"%s\" contains a file bigger than the max bytes allowed.\n\t" +
                     "Offending file: <repo root>/%s\n\tSize: %i\n\tMax: %i") %
                    (program_name, path_relative, file_size, max_bytes))
    elif file_size <= 10:  # Try to avoid empty files
        raise error("Program \"%s\" contains a very small file: <repo root>/%s\n\tSize: %i" %
                    (program_name, path_relative, file_size))


def check_version(version, program_name):
    """
    Checks the version passed is valid
      Version format 1.0.0-alpha-1
    :param program_name: name of program to use in error message
    :param version: version string to check
    :return: boolean
    :raises Exception if version is not the correct format
    """
    groups = re.match("^(\d+)?(?:\.(\d+))?(?:\.(\d+))?(?:-(alpha|beta|release))?(?:-(\d+))?$", version)
    err = "Program \"%s\" has an ill-formatted version string: %s\n\tReference: 1.0.0-alpha-1" % (program_name, version)
    if not groups:
        raise error(err)
    last_group = None
    for group in groups.groups():
        if not group:
            break
        last_group = group
    if not version.endswith(last_group):
        raise error(err)


def test_repo():
    """
    Tests the repo index for valid format and correct entries. This also checks to ensure all the defined programs and
    files are present.
    See https://github.com/rolandoislas/PeripheralsPlusOne/tree/master/src/main/resources/lua/mount/dyn.lua
        Dyn#verify_index_file() for the reference implementation
    :raises Exception
    """
    root = os.path.join(os.path.dirname(__file__), "..")
    try:
        with open(os.path.join(root, "index.json"), "r") as index_file:
            index_json = json.loads(index_file.read())
    except Exception as e:
        raise error("Failed to read index file: %s" % e)
    entries = [
        ["name", str],
        ["directory", str],
        ["peripherals", list],
        ["extra", list],
        ["version", str],
        ["depends", list],
        ["description", str]
    ]
    names = []
    for program in index_json:
        # Check entries
        # Unlike the Lua verification, this errors on missing optional entries
        for entry in entries:
            # Verify the program name
            program_name = (program["name"] if "name" in program else str(index_json.index(program)))
            if not re.fullmatch("[A-Za-z0-9_-]+", program_name) or program_name.startswith(("_", "-")):
                raise error("Program \"%s\" contains a invalid name" % program_name)
            # Ensure the entries exists
            if entry[0] not in program:
                raise error("Program \"%s\" is missing its \"%s\" entry" % (program_name, entry))
            # Ensure the entry is the correct type
            if not isinstance(program[entry[0]], entry[1]):
                raise error("Program \"%s\" has an entry with an invalid type: Entry \"%s\" is %s, expected %s" %
                            (program_name, entry[0], type(program[entry[0]]), entry[1]))
        # Ensure there are no additional entries
        for entry in program:
            if [entry, type(program[entry])] not in entries:
                raise error("Program \"%s\" has an unrecognized entry \"%s\"" % (program["name"], entry))
        # Verify the version is the correct format
        check_version(program["version"], program["name"])
        # Verify at least one peripheral type is defined
        err = "Program \"%s\" does not define any supported peripherals" % program["name"]
        if len(program["peripherals"]) < 1:
            raise error(err)
        for peripheral in program["peripherals"]:
            if " " in peripheral:
                raise error("Program \"%s\" defines a supported peripheral that contains a space in its name: %s" %
                            (program["name"], peripheral))
            if not peripheral:
                raise error(err)
        # Append name
        names.append(program["name"])

    # Check duplicates
    for name in names:
        count = 0
        for name_compare in names:
            if name == name_compare:
                count += 1
                if count > 1:
                    raise error("Duplicate program name found: " + name)

    for program in index_json:
        # Verify dependencies are contained in this repo
        for dependency in program["depends"]:
            if dependency not in names:
                raise error("Program \"%s\" depends on \"%s\", but it is not available in this repo" %
                            (program["name"], dependency))
        # Check files exist and their size is not too large or small
        for ext in ("txt", "lua"):
            check_file_size(root, os.path.join(program["directory"], program["name"] + "." + ext), program["name"])
        for ext in program["extra"]:
            check_file_size(root, os.path.join(program["directory"], "extra", ext), program["name"])


if __name__ == '__main__':
    test_repo()
