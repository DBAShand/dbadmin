#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path


CONTENT_PATTERN = re.compile(r"vuhl", re.IGNORECASE)
FILENAME_PATTERN = re.compile(r"vuhl", re.IGNORECASE)


def read_text_with_fallbacks(file_path: Path) -> tuple[str, str]:
    encodings = ["utf-8", "utf-8-sig", "cp1252", "latin-1"]

    for encoding in encodings:
        try:
            return file_path.read_text(encoding=encoding), encoding
        except UnicodeDecodeError:
            continue

    raise RuntimeError(f"Could not decode file: {file_path}")


def make_backup(file_path: Path) -> Path:
    backup_path = file_path.with_suffix(file_path.suffix + ".bak")
    counter = 1

    while backup_path.exists():
        backup_path = file_path.with_suffix(file_path.suffix + f".bak{counter}")
        counter += 1

    shutil.copy2(file_path, backup_path)
    return backup_path


def replace_content_in_file(file_path: Path, replacement: str, backup: bool) -> tuple[bool, int, Path | None]:
    original_text, encoding = read_text_with_fallbacks(file_path)
    new_text, replacements = CONTENT_PATTERN.subn(replacement, original_text)

    backup_path = None
    if replacements > 0:
        if backup:
            backup_path = make_backup(file_path)
        file_path.write_text(new_text, encoding=encoding)

    return replacements > 0, replacements, backup_path


def rename_file_if_needed(file_path: Path, replacement: str) -> tuple[Path, bool]:
    if not FILENAME_PATTERN.search(file_path.name):
        return file_path, False

    new_name = FILENAME_PATTERN.sub(replacement, file_path.name)
    new_path = file_path.with_name(new_name)

    if new_path == file_path:
        return file_path, False

    if new_path.exists():
        raise FileExistsError(f"Cannot rename '{file_path}' to '{new_path}': target already exists.")

    file_path.rename(new_path)
    return new_path, True


def verify_file_contents(file_path: Path) -> list[tuple[int, str]]:
    text, _ = read_text_with_fallbacks(file_path)
    matches: list[tuple[int, str]] = []

    for line_number, line in enumerate(text.splitlines(), start=1):
        if CONTENT_PATTERN.search(line):
            matches.append((line_number, line.rstrip()))

    return matches


def collect_sql_files(root: Path) -> list[Path]:
    return sorted([p for p in root.rglob("*.sql") if p.is_file()])


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Replace all occurrences of 'vuhl' with 'scs' in SQL files, with optional file renaming."
    )
    parser.add_argument(
        "folder",
        help="Root folder containing .sql files"
    )
    parser.add_argument(
        "--replacement",
        default="scs",
        help="Replacement text to use instead of 'vuhl' (default: scs)"
    )
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Do not create backup files before modifying file contents"
    )
    parser.add_argument(
        "--rename-files",
        action="store_true",
        help="Also rename file names containing 'vuhl'"
    )
    args = parser.parse_args()

    root = Path(args.folder).expanduser().resolve()
    if not root.exists():
        print(f"ERROR: Folder does not exist: {root}", file=sys.stderr)
        return 1
    if not root.is_dir():
        print(f"ERROR: Path is not a directory: {root}", file=sys.stderr)
        return 1

    sql_files = collect_sql_files(root)
    if not sql_files:
        print(f"ERROR: No .sql files found under: {root}", file=sys.stderr)
        return 1

    print(f"Scanning folder: {root}")
    print(f"Found {len(sql_files)} .sql files")
    print(f"Replacing all case-insensitive occurrences of 'vuhl' with '{args.replacement}'")
    print(f"Backups enabled: {not args.no_backup}")
    print(f"Rename files enabled: {args.rename_files}")
    print()

    changed_files = 0
    total_replacements = 0
    renamed_files = 0
    backup_count = 0
    current_files: list[Path] = []

    for file_path in sql_files:
        try:
            changed, replacements, backup_path = replace_content_in_file(
                file_path=file_path,
                replacement=args.replacement,
                backup=not args.no_backup,
            )

            if changed:
                changed_files += 1
                total_replacements += replacements
                if backup_path is not None:
                    backup_count += 1
                print(f"UPDATED CONTENT: {file_path} ({replacements} replacements)")

            new_path = file_path
            if args.rename_files:
                new_path, was_renamed = rename_file_if_needed(file_path, args.replacement)
                if was_renamed:
                    renamed_files += 1
                    print(f"RENAMED FILE   : {file_path} -> {new_path}")

            current_files.append(new_path)

        except Exception as exc:
            print(f"ERROR processing {file_path}: {exc}", file=sys.stderr)
            return 1

    print()
    print("Verification pass...")
    print()

    remaining_content_hits: list[tuple[Path, int, str]] = []
    remaining_filename_hits: list[Path] = []

    final_sql_files = collect_sql_files(root)

    for file_path in final_sql_files:
        matches = verify_file_contents(file_path)
        for line_number, line in matches:
            remaining_content_hits.append((file_path, line_number, line))

        if args.rename_files and FILENAME_PATTERN.search(file_path.name):
            remaining_filename_hits.append(file_path)

    print("Summary")
    print("-------")
    print(f"Files scanned           : {len(sql_files)}")
    print(f"Files with content edits: {changed_files}")
    print(f"Total content replaces  : {total_replacements}")
    print(f"Backup files created    : {backup_count}")
    print(f"Files renamed           : {renamed_files}")

    if remaining_content_hits or remaining_filename_hits:
        print()
        print("VERIFICATION FAILED")

        if remaining_content_hits:
            print()
            print("Remaining 'vuhl' found in file contents:")
            for file_path, line_number, line in remaining_content_hits:
                print(f"{file_path}:{line_number}: {line}")

        if remaining_filename_hits:
            print()
            print("Remaining 'vuhl' found in file names:")
            for file_path in remaining_filename_hits:
                print(file_path)

        return 1

    print()
    print("Success: no remaining 'vuhl' found in SQL file contents"
          + (" or file names." if args.rename_files else "."))
    return 0


if __name__ == "__main__":
    sys.exit(main())