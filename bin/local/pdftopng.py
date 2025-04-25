#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
import os
from typing import List

import tqdm
from wand.image import Image


def _should_skip(file: str):
    """
    Skipping files that is incompatible with convert command, returns reason as
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


def _run_loop(file_list: List[str], density: int):
    max_len = max([len(x) for x in file_list])
    with tqdm.cli.tqdm(file_list) as pbar:
        for file in pbar:
            skip = _should_skip(file)
            if skip is not None:
                print(f"Skipping [{file}]: ", skip)
                continue

            outfile = _make_filename_png(file)
            pbar.set_description(f"[{file.ljust(max_len)}->{outfile.ljust(max_len)}]")
            with Image(filename=file) as img:
                img.resample(density, density)
                img.save(filename=outfile)


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

    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    _run_loop(args.files, args.density)
