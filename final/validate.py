#!/usr/bin/env  python3
# *-* encoding=utf8 *-*

from trails import *

def parse_list (text : str):
    return text.lstrip(" ").rstrip(" ").lstrip("(").rstrip(")").split()

if __name__ == "__main__":
    with open("sas_plan", "r") as fp:
        lines = fp.readlines()
