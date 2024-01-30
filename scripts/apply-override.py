#!/usr/bin/env python3
# Hassle: By default, the WSL2 kernel is not built with the required Linux kernel flags. This script can patch
# Linux kernel config files, changing/adding options specified in the override file.
import argparse
import pprint

parser = argparse.ArgumentParser()
parser.add_argument("config", help="The original Linux kernel configuration file")
parser.add_argument("--override", help="The file containing the values to override")
args = parser.parse_args()

if not args.override:
    print("No override file specified. Exiting...")

pp = pprint.PrettyPrinter(indent=4)

with open(args.config, "rt") as config:
    config_lines = config.read().splitlines()

with open(args.override, "rt") as override:
    override_lines = override.read().splitlines()

def is_config_line(line):
    return line and not line.startswith("#")

override_values = {
    split[0]: split[1]
    for line in filter(is_config_line, override_lines)
    if (split := line.split("="))
}

used_overrides = set()

for line in config_lines:
    if not is_config_line(line):
        print(line)
        continue

    key = line.split("=")[0]
    print(key)
    if not key in override_values:
        print(line)
        continue

    used_overrides.add(key)
    print(f"{key}={override_values[key]}")

print("\n## Extra overrides")
for override_key, override_value in override_values.items():
    if override_key not in used_overrides:
        pass
        print(f"{override_key}={override_value}")

print(f"\n ## Overwritten values: {len(used_overrides)}. Extra overrides: {len(override_values) - len(used_overrides)}")
