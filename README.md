# nu-ffmpeg

Utility commands for working with ffmpeg in nushell.

## Capabilities

- Return tables from `ffprobe`
- `ffprobe` multiple files at once
- Use `streams`, `streams video`, and `streams audio` to filter `ffprobe` output
- get the `dimensions` of a video stream as a record
- Apply and parse complex filters to a video (Work In Progress)

## Setup

The `ffmpeg` and `ffprobe` commands are required to be installed and available
in your path; they are not installed for you.

Currently nushell versions 0.87.0 - 0.88.1 are supported.

After that, clone this repository and add the following code to your scripts,
or to your `config.nu` file:

```nu
use <path-to-repository>/ffprobe
use <path-to-repository>/filters *
```
