# nu-ffmpeg

Utility commands for working with ffmpeg in nushell.

## Capabilities ([see examples](#examples))

- Return tables from `ffprobe`
- `ffprobe` multiple files at once
- Use `streams`, `streams video`, and `streams audio` to filter `ffprobe` output
- get the `dimensions` of a video stream as a record

- Apply complex filters to a video using standard shell pipes `|` rather than filtergraph syntax.
- Conditionally apply filters to a video based on the inputs
- Tab-completion for filter options. i.e. `fps --round<tab>` will yield `zero inf down up near`

## Setup

The `ffmpeg` and `ffprobe` commands are required to be installed and available
in your path; they are not installed for you.

Currently only nushell version 0.108.0 is supported.

After that, clone this repository and add the following code to your scripts,
or to your `config.nu` file:

```nu
use <path-to-repository>/ffprobe
use <path-to-repository>/filters *
```

## FFProbe

### Commands

| name                  | description                                                      |
| --------------------- | ---------------------------------------------------------------- |
| ffprobe banner        | Print a banner for Nushell with information about the project    |
| ffprobe               | Run ffprobe on a list of files and return the output as a table. |
| ffprobe dimensions    | Get the dimensions of a video stream                             |
| ffprobe streams       | Retrieve all the streams from a list of ffprobe outputs          |
| ffprobe streams audio | Retrieve all the audio streams from a list of ffprobe outputs    |
| ffprobe streams video | Retrieve all the video streams from a list of ffprobe outputs    |


### Examples


```nu
# Return a table from ffprobe
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4
╭───┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────┬───╮
│ # │                                                   streams                                                   │ f │
│   │                                                                                                             │ o │
│   │                                                                                                             │ r │
│   │                                                                                                             │ m │
│   │                                                                                                             │ a │
│   │                                                                                                             │ t │
├───┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────┼───┤
│ 0 │ ╭───┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬───────────────┬─────╮ │ { │
│   │ │ # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_str │ ... │ │ r │
│   │ │   │            │                                           │         │            │ ing           │     │ │ e │
│   │ ├───┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼───────────────┼─────┤ │ c │
│   │ │ 0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1          │ ... │ │ o │
│   │ │ 1 │ aac        │ AAC (Advanced Audio Coding)               │ LC      │ audio      │ mp4a          │ ... │ │ r │
│   │ ╰───┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴───────────────┴─────╯ │ d │
│   │                                                                                                             │   │
│   │                                                                                                             │ 1 │
│   │                                                                                                             │ 2 │
│   │                                                                                                             │   │
│   │                                                                                                             │ f │
│   │                                                                                                             │ i │
│   │                                                                                                             │ e │
│   │                                                                                                             │ l │
│   │                                                                                                             │ d │
│   │                                                                                                             │ s │
│   │                                                                                                             │ } │
╰───┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────┴───╯
```

```nu
# Use ffprobe on mutliple files at once
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 https://sample-videos.com/video321/mkv/720/big_buck_bunny_720p_1mb.mkv
╭───┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────┬───╮
│ # │                                                   streams                                                   │ f │
│   │                                                                                                             │ o │
│   │                                                                                                             │ r │
│   │                                                                                                             │ m │
│   │                                                                                                             │ a │
│   │                                                                                                             │ t │
├───┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────┼───┤
│ 0 │ ╭───┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬───────────────┬─────╮ │ { │
│   │ │ # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_str │ ... │ │ r │
│   │ │   │            │                                           │         │            │ ing           │     │ │ e │
│   │ ├───┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼───────────────┼─────┤ │ c │
│   │ │ 0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1          │ ... │ │ o │
│   │ │ 1 │ aac        │ AAC (Advanced Audio Coding)               │ LC      │ audio      │ mp4a          │ ... │ │ r │
│   │ ╰───┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴───────────────┴─────╯ │ d │
│   │                                                                                                             │   │
│   │                                                                                                             │ 1 │
│   │                                                                                                             │ 2 │
│   │                                                                                                             │   │
│   │                                                                                                             │ f │
│   │                                                                                                             │ i │
│   │                                                                                                             │ e │
│   │                                                                                                             │ l │
│   │                                                                                                             │ d │
│   │                                                                                                             │ s │
│   │                                                                                                             │ } │
│ 1 │ ╭───┬────────────┬─────────────────────────────┬────────────────┬────────────┬──────────────────┬───┬─────╮ │ { │
│   │ │ # │ codec_name │       codec_long_name       │    profile     │ codec_type │ codec_tag_string │ c │ ... │ │ r │
│   │ │   │            │                             │                │            │                  │ o │     │ │ e │
│   │ │   │            │                             │                │            │                  │ d │     │ │ c │
│   │ │   │            │                             │                │            │                  │ e │     │ │ o │
│   │ │   │            │                             │                │            │                  │ c │     │ │ r │
│   │ │   │            │                             │                │            │                  │ _ │     │ │ d │
│   │ │   │            │                             │                │            │                  │ t │     │ │   │
│   │ │   │            │                             │                │            │                  │ a │     │ │ 1 │
│   │ │   │            │                             │                │            │                  │ g │     │ │ 1 │
│   │ ├───┼────────────┼─────────────────────────────┼────────────────┼────────────┼──────────────────┼───┼─────┤ │   │
│   │ │ 0 │ mpeg4      │ MPEG-4 part 2               │ Simple Profile │ video      │ [0][0][0][0]     │ 0 │ ... │ │ f │
│   │ │   │            │                             │                │            │                  │ x │     │ │ i │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │ e │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │ l │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │ d │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │ s │
│   │ │ 1 │ aac        │ AAC (Advanced Audio Coding) │ LC             │ audio      │ [0][0][0][0]     │ 0 │ ... │ │ } │
│   │ │   │            │                             │                │            │                  │ x │     │ │   │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │   │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │   │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │   │
│   │ │   │            │                             │                │            │                  │ 0 │     │ │   │
│   │ ╰───┴────────────┴─────────────────────────────┴────────────────┴────────────┴──────────────────┴───┴─────╯ │   │
╰───┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────┴───╯
```

```nu
# Extract the video streams from a video
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video
╭───┬────────────┬───────────────────────────────────────────┬─────────┬────────────┬──────────────────┬────────┬─────╮
│ # │ codec_name │              codec_long_name              │ profile │ codec_type │ codec_tag_string │ codec_ │ ... │
│   │            │                                           │         │            │                  │ tag    │     │
├───┼────────────┼───────────────────────────────────────────┼─────────┼────────────┼──────────────────┼────────┼─────┤
│ 0 │ h264       │ H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 │ Main    │ video      │ avc1             │ 0x3163 │ ... │
│   │            │                                           │         │            │                  │ 7661   │     │
╰───┴────────────┴───────────────────────────────────────────┴─────────┴────────────┴──────────────────┴────────┴─────╯
# Extract the audio streams from a video
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams audio
╭───┬────────────┬─────────────────────────────┬─────────┬────────────┬──────────────────┬────────────┬─────────┬─────╮
│ # │ codec_name │       codec_long_name       │ profile │ codec_type │ codec_tag_string │ codec_tag  │ sample_ │ ... │
│   │            │                             │         │            │                  │            │ fmt     │     │
├───┼────────────┼─────────────────────────────┼─────────┼────────────┼──────────────────┼────────────┼─────────┼─────┤
│ 1 │ aac        │ AAC (Advanced Audio Coding) │ LC      │ audio      │ mp4a             │ 0x6134706d │ fltp    │ ... │
╰───┴────────────┴─────────────────────────────┴─────────┴────────────┴──────────────────┴────────────┴─────────┴─────╯
```

```nu
# Extract the dimensions of a video stream
> ffprobe https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4 | streams video | first | dimensions
╭────────┬──────╮
│ width  │ 1280 │
│ height │ 720  │
╰────────┴──────╯
```

## FFMpeg

### Supported Filters

| name    | description                                                                                                                                                                                                                                |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| banner  | Print a banner for Nushell with information about the project                                                                                                                                                                              |
| crop    | Crop the input video to given dimensions.                                                                                                                                                                                                  |
| format  | Convert the input video to one of the specified pixel formats. Libavfilter will try to pick one that is suitable as input to the next filter.                                                                                              |
| fps     | Convert the video to specified constant frame rate by duplicating or dropping frames as necessary.                                                                                                                                         |
| overlay | Overlay one video on top of another.                                                                                                                                                                                                       |
| settb   | Set the timebase to use for the output frames timestamps. It is mainly useful for testing timebase configuration.                                                                                                                          |
| split   |                                                                                                                                                                                                                                            |
| vflip   | Flip the input video vertically.                                                                                                                                                                                                           |
| vloop   | loop video frames Same as the `loop` filter in ffmpeg, but had to be renamed due to collisions with the [nushell builtin](https://www.nushell.sh/commands/docs/loop.html)                                                                  |
| xfade   | Apply cross fade from one input video stream to another input video stream. The cross fade is applied for specified duration. Both inputs must be constant frame-rate and have the same resolution, pixel format, frame rate and timebase. |


### Examples

