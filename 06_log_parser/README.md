# Log Keyword Scanner

Small Bash utility for scanning a log file and counting keyword matches.

## What It Does

`log_parser.sh` reads a log file line by line, searches each line for one or more keywords, prints the matching line number with part of the line, and shows a final count for each keyword.

Matching is case-insensitive.

## Requirements

- Bash 4 or newer
- A readable log file

## Usage

```bash
./log_parser <log_file> <keyword1> [keyword2 ...]
```

## Example

```bash
./csv.sh sample.log ERROR WARNING INFO
```

Example output:

```text
line# 4 [2024-03-11 08:17:03] ERROR:
line# 6 [2024-03-11 08:19:22] WARNING:

Results:
ERROR -> 5
WARNING -> 2
INFO -> 4
```

## How It Works

- The first argument is treated as the log file path.
- All remaining arguments are stored as keys in an associative array.
- Each key starts with a count of `0`.
- Every line is compared against every keyword.
- When a keyword is found, its count is incremented.

## Notes

- Matching uses substring search, not exact-word matching.
- Matching is case-insensitive by converting both the line and the keyword to lowercase.
- Output order for results may vary because associative arrays are unordered.
- The script currently prints only the first three whitespace-separated fields of matched lines.

## Files

- `csv.sh`: main script
- `sample.log`: sample input log
