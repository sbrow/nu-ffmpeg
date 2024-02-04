
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

Currently only nushell version 0.89.0
 is supported.

After that, clone this repository and add the following code to your scripts,
or to your `config.nu` file:

```nu
use <path-to-repository>/ffprobe
use <path-to-repository>/filters *
```

## FFProbe

### Commands

| name                  | usage                                                            |
| --------------------- | ---------------------------------------------------------------- |
| ffprobe               | Run ffprobe on a list of files and return the output as a table. |
| ffprobe dimensions    | Get the dimensions of a video stream                             |
| ffprobe streams       | Retrieve all the streams from a list of ffprobe outputs          |
| ffprobe streams audio | Retrieve all the audio streams from a list of ffprobe outputs    |
| ffprobe streams video | Retrieve all the video streams from a list of ffprobe outputs    |


## FFMpeg

## Supported Filters

| name    | usage                                                                                              |
| ------- | -------------------------------------------------------------------------------------------------- |
| crop    | Crop the input video to given dimensions.                                                          |
| fps     | Convert the video to specified constant frame rate by duplicating or dropping frames as necessary. |
| loop    | loop video frames                                                                                  |
| overlay | Overlay one video on top of another.                                                               |
| split   |                                                                                                    |
| vflip   | Flip the input video vertically.                                                                   |

