#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
import os
import subprocess
from typing import List


def _should_skip(file: str):
    """
    Skipping files that is incompabile with convert command, returns reason as
    a string
    """
    if not os.path.isfile(file):
        return "Given path is not a file"

    filedir, infile = os.path.split(file)
    filename, ext = os.path.splitext(infile)
    if ext != ".pdf":
        return "None PDF file"


def _make_filename_png(file: str):
    filedir, infile = os.path.split(file)
    filename, ext = os.path.splitext(infile)
    return os.path.join(filedir, filename + ".png")


def _run_loop(file_list: List[str], quite=False, dry_run=False):
    for index, file in enumerate(file_list, start=1):
        skip = _should_skip(file)
        if skip is not None:
            print(f"Skipping [{file}]: ", skip)
            continue

        outfile = _make_filename_png(file)

        if not quite:
            header = f"[{index}/{len(file_list)}] " if len(file_list) > 1 else ""

            print(
                f"{header}Converting file [{file}] to [{outfile}]...",
                end="",
                flush=True,
            )

        run_cmd = [
            "convert",
            *("-density", str(args.density)),
            "-trim",
            file, ## Must be in this order??
            *("-quality", "100"),
            # '-sharpen', '0x1.0',  #
            outfile,
        ]
        if dry_run:
            print("(" + " ".join(run_cmd) + ")...", end="")
        else:
            subprocess.run(run_cmd)

        if not quite:
            print("Done.")


if __name__ == "__main__":
    import argparse

    import argcomplete

    parser = argparse.ArgumentParser(
        prog="pdftopng.py",
        description="Convert PDF files to high quality PNG files",
    )

    parser.add_argument(
        "files", type=str, nargs="+"
    ).completer = argcomplete.FilesCompleter(allowednames="*.pdf")
    parser.add_argument(
        "-d",
        "--density",
        type=int,
        default=144,
        help="Pixel density (DPI/dots per inch)",
    )
    parser.add_argument(
        "-q",
        "--quite",
        action="store_true",
        help="Whether or not to print progress messages",
    )
    parser.add_argument(
        "--dry_run",
        action="store_true",
        help="Print command instead of executing the convert process",
    )

    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    _run_loop(args.files, quite=args.quite, dry_run=args.dry_run)
