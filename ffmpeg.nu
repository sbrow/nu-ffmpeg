export def cmd [ inputs: list<string> outputs: list<string> ]: nothing -> record {
  {
    input: $inputs
    filters: []
    output: $outputs
    args: []
    options: {
      chain_filters: false
    }
  }
}

export def "cmd to-args" []: record -> list<string> {
  let command = $in;

  [
    ...($command.input | reduce -f [] { |it, acc| $acc | append ['-i', $it ] })
    ...$command.args
    ...['-filter_complex' ($command.filters | filtergraph to-string)]
    ...($command.output)
  ]
}

# Run the given command
# Serves as a sink for a filter pipeline.
export def "run" [
  --dry-run (-d) # Print the command that would be run
  --print-command # Print the command, and then run it.
  --confirm
] {
  let cmd = $in;

  if $dry_run {
      [ffmpeg, ...($cmd | cmd to-args)]
  } else {
    if ($print_command) {
      print -e $"ffmpeg ($cmd | cmd to-args | str join ' ')";
    }
    if ($confirm) {
      let args = ['ffmpeg', ...($cmd | cmd to-args)];

      ['No' 'Yes'] | input list $"Run this command?\n($args | str join ' ')" | if $in == 'Yes' {
        ffmpeg ...($cmd | cmd to-args)
      }
    } else {
      ffmpeg ...($cmd | cmd to-args)
    }
  }
}

def "append last" [
  items: list
]: list -> list {
  update (($in | length) - 1) { $in | append $items }
}

export def "cmd filters append" [
  complex_filters: list<record>
]: record -> record {
  update filters { |cmd|
    let filters = $in;

    if ($cmd.options.chain_filters) {
      $filters | append last $complex_filters
    } else {
      $filters | append [$complex_filters]
    }
  }
}

export def "parse filtergraph" [
]: string -> list<table<name: string params: table<param: string, value: string>>> {
  split row ';' | each { parse filterchain }
}

export def "parse filterchain" [
]: string -> table<name: string params: table<param: string, value: string>> {
  split row ',' | each { parse filter }
}

export def "parse filter" [
]: string -> table<name: string params: table<param: string, value: string>> {
  parse --regex '^\s*(?:\[(?<input>[^\s]+)\]\s*)?(?<name>[^=\s\[]+)\s*(?:=(?<params>[^\[\s,;]*)\s*)?(?:\[(?<output>[^\s,;]+)\])?' | first | update params {
    parse --regex `(?:(?<param>[^=]+)=)?(?<value>[^:]+):?`
  } | update input { split row '][' | filter { is-not-empty }
  } | update output { split row '][' | filter { is-not-empty } }
}

# TODO: Remove export
export def "filtergraph to-string" [] { # : list<table> -> string {
  $in | each { filterchain to-string } | str join ';'
}

def "filterchain to-string" []: table -> string {
  $in | each { filter to-string }| str join ','
}

def "filter to-string" []: record<input: list<string> name: string params: table<name: string value: string> output: list<string>> -> string {
  $in | update input {
    str join ']['
  } | update output {
    str join ']['
  } | update params {
    each { update value { match ($in | describe) {
        'bool' => (if ($in) { '1' } else { '0' })
        _ => $in,
      } } | format pattern '{param}={value}' } | str join ':' | str replace -ar '(?<=^|:)=' ''
  } | format pattern '[{input}]{name}={params}[{output}]' | str replace -ar '\[\]|=(?=[\[,;])' ''
}

# Add a chain of filters to the command's filtergraph
export def filterchain [
  --input (-i): list<string> # sets the input of the last filterchain's first filter
  --output (-o): list<string> # sets the output of the last filterchain's last filter
  filter: closure # The filter, or filters to append to the filtergraph
] {
  let cmd = $in;
  let original_option = $cmd.options.chain_filters;

  (
    $cmd
    | update options.chain_filters { not $in }
    | update filters {
      let it = $in;

      if ($it | describe | str starts-with 'table') {
        [$it [] ]
      } else {
        $it | append [[]]
      }
    }
    | do $filter
    | if ($input | is-not-empty) {
      update filters {
        update (($in | length) - 1) {
          update 0.input $input
        }
      }
    } else { $in }
    | if ($output | is-not-empty) {
      update filters {
        update (($in | length) - 1) {
          update (($in | length) - 1) {
            update output $output
          }
        }
      }
    } else { $in }
    | update options.chain_filters $original_option
  );
}

# Build a record representaion of a complex filter
export def complex-filter [
  --input (-i): list<string> = []
  --output (-o): list<string> = []
  name: string
  params: record = {}
]: nothing -> record<input: list<string> name: string params: table<param: string, value: string> output: list<string>> {
  {
    input: $input
    name: $name
    params: ($params | transpose param value | compact param value)
    output: $output
  }
}

# Appends a single complex-filter to the end of the command's filtergraph
export def append-complex-filter [
  --input (-i): list<string> = []
  --output (-o): list<string> = []
  name: string
  params: record = {}
] {
  $in | cmd filters append [
    (complex-filter --input $input --output $output $name $params)
  ]
}

def is-not-empty []: any -> bool {
  is-empty | not $in
}
