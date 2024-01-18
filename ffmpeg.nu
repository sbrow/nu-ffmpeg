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

export def "cmd filters append" [
  complex_filter: list<record>
]: record -> record {
  let cmd = $in;

  if ($cmd.options.chain_filters) {
    $cmd | update filters {
      let original = $in;

      ($original | range 0..-2) | append [
        (($original | default [] | last) | append $complex_filter)
      ]
    }
  } else {
    $cmd | update filters { append [$complex_filter] }
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
  } | update input { split row '][' | filter { not ($in | is-empty) }
  } | update output { split row '][' | filter { not ($in | is-empty) } }
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
    each { format '{param}={value}' } | str join ':' | str replace -ar '(?<=^|:)=' ''
  } | format '[{input}]{name}={params}[{output}]' | str replace -ar '\[\]|=(?=[\[,;])' ''
}

# Set the input and outputs of a filter chain
export def filterchain [
  #input: list<string>
  #output: list<string>
  filter: closure
] {
  let cmd = $in;
  let original_option = $cmd.options.chain_filters;

  # TODO: Assign inputs and outputs
  $cmd | update options.chain_filters { not $in } | do $filter | update options.chain_filters $original_option;
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
