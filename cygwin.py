#!/usr/bin/env python3

import re
import sys
from collections import defaultdict

import requests

CYGWIN_MIRROR = "http://mirrors.kernel.org/sourceware/cygwin/"

# Custom processing behavior for certain keys
PARSERS = {
    "requires": lambda x: x.split(),
    "install": lambda x: dict(zip(["path", "size", "sha256"], x.split())),
    "depends2": lambda x: x.split(", "),
}
PARSERS["source"] = PARSERS["install"]


def first(item):
    try:
        return item[0]
    except IndexError:
        return None


def parse_attributes(item):
    """
    Parses an attribute line for a cygwin package
    """
    try:
        key_value = item.strip().split(": ", 1)
        key = first(key_value)
        value = key_value[1] if len(key_value) == 2 else []
        if isinstance(value, str):
            value = value.strip('"')
    except ValueError:
        return ("", "")

    if key in PARSERS:
        value = PARSERS[key](value)

    return key, value


def resolve_dependencies(item, packages, dependencies=None):
    if dependencies is None:
        dependencies = set()
    if item in packages:
        dependencies.add(item)
    data = packages.get(item, {})
    for dep in data.get("requires", []) + data.get("depends2", []):
        if dep in dependencies:
            continue
        dependencies.add(dep)
        dependencies.update(
            resolve_dependencies(dep, packages, dependencies=dependencies)
        )
    return dependencies


def get_packages(cygwin_mirror=CYGWIN_MIRROR):
    packages = defaultdict(dict)
    # Get setup.ini contents
    setup_ini_uri = f"{CYGWIN_MIRROR}x86_64/setup.ini"
    sys.stderr.write(f"Getting package list from {setup_ini_uri}\n")
    # response = requests.get(setup_ini_uri)
    # package_listing = response.content.decode("utf-8")
    # lines = iter(package_listing.splitlines())
    response = requests.get(setup_ini_uri, stream=True)
    lines = response.iter_lines(decode_unicode=True, chunk_size=2048)

    # Generate package listing
    parsing_package = False
    for line in lines:
        if first(line) == "@":
            parsing_package = line.strip().split(" ", 1)[1]
            # sys.stderr.write(f"Parsing {parsing_package}\n")
            continue

        if parsing_package and (line == "" or line.startswith("[prev]")):
            parsing_package = False
            continue

        if line.startswith('ldesc: "'):
            while line[-1] != '"':
                line += next(lines)

        if parsing_package:
            attrib = parse_attributes(line)
            packages[parsing_package][attrib[0]] = attrib[1]

    return packages


def latest_python3(packages):
    python = {
        version: details
        for version, details in packages.items()
        if re.match(r"^python3[0-9]+$", version)
    }

    return "python%i" % max(map(lambda x: int(x.replace("python", "")), python))


def output_latest(version):
    print("Setting version to " + version)
    print("::set-output name=version::" + version)


if __name__ == "__main__":
    PACKAGES = get_packages()
    sys.stderr.write("Resolving dependencies\n")
    required_packages = set()
    ALL_REQUIREMENTS = ["cygwin-devel", "gcc-g++", "libssl-devel", "python36-devel"]
    BUILD_REQUIREMENTS = ["python36", "python36-pip"]

    if len(sys.argv) > 0 and sys.argv[0] == "BUILD":
        ALL_REQUIREMENTS += BUILD_REQUIREMENTS

    for package in ALL_REQUIREMENTS:
        reqs = resolve_dependencies(package, PACKAGES)
        sys.stderr.write(f"Found {package} requires {str(reqs)}\n")
        required_packages.update(reqs)

    # sys.stderr.write(f"Will download {required_packages}\n")
    # for dep in required_packages:
    #     sys.stderr.write(f"{dep} {PACKAGES.get(dep).get('install', {}).get('path', '')}\n")

    print(
        "\n".join(
            [
                f"{CYGWIN_MIRROR}{PACKAGES[dep]['install']['path']}"
                for dep in required_packages
            ]
        )
    )
    sys.exit(0)
