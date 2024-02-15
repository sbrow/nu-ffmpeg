use std [assert];

use ffmpeg.nu *;
use filters.nu *;

#[test]
def can_parse_filters_with_inputs_and_outputs [] {
    let got = '[foo]loop=loop=1[bar]' | parse filter;

    assert equal $got { input: ['foo'] name: 'loop' params: [{param: 'loop', value: '1'}] output: ['bar'] };
}

#[test]
def can_parse_filters_with_multiple_inputs [] {
    let got = '[main][flip] overlay=0:H/2 ' | parse filter;

    assert equal $got { input: ['main' 'flip'] name: 'overlay' params: [{param: '', value: '0'} {param: '' value: 'H/2'}] output: [] };
}

#[test]
def can_parse_filters_with_multiple_outputs [] {
    let got = 'overlay=0:H/2 [main][flip]' | parse filter;

    assert equal $got { input: [] name: 'overlay' params: [{param: '', value: '0'} {param: '' value: 'H/2'}] output: ['main' 'flip'] };
}

#[test]
def can_parse_filters_with_multiple_params [] {
    let got = '[foo]loop=loop=2:size=1[bar]' | parse filter;

    assert equal $got { input: ['foo'] name: 'loop' params: [{param: 'loop', value: '2'} {param: 'size' value: '1'}] output: ['bar'] };
}

#[test]
def can_parse_filterchain [] {
    let got = '[tmp] crop=iw:ih/2:0:0, vflip [flip]' | parse filterchain;

    assert equal $got [
      {
        input: ['tmp']
        name: 'crop'
        params: [
          {param: '' value: 'iw'}
          { param: '' value: 'ih/2'}
          { param: '', value: '0'}
          { param: '', value: '0'}
        ]
        output: []
      }
      {
        input: []
        name: 'vflip'
        params: []
        output: ['flip']
      }
    ];
}

#[test]
def can_parse_filtergraph [] {
    let got = 'split [main][tmp]; [tmp] crop=iw:ih/2:0:0, vflip [flip]; [main][flip] overlay=0:H/2' | parse filtergraph;

    assert equal $got [
      [
        {input: [], name: 'split', params: [], output: ['main' 'tmp']}
      ]
      [
        {input: [tmp], name: 'crop', params: [
          { param: '' value: 'iw' }
          { param: '' value: 'ih/2' }
          { param: '' value: '0' }
          { param: '' value: '0' }
        ], output: []}
        {input: [], name: 'vflip', params: [], output: ['flip']}
      ]
      [
        {input: ['main' 'flip'], name: 'overlay', params: [
          { param: '' value: '0' }
          { param: '' value: 'H/2' }
        ], output: []}
      ]
    ];
}
#[test]
def can_convert_filtergraph_to_string [] {
    let got = 'split [main][tmp]; [tmp] crop=iw:ih/2:0:0, vflip [flip]; [main][flip] overlay=0:H/2' | parse filtergraph | filtergraph to-string;

    let want = 'split[main][tmp];[tmp]crop=iw:ih/2:0:0,vflip[flip];[main][flip]overlay=0:H/2';

    assert equal $got $want;
}

#[test]
def boolean_params_are_converted_to_1_or_0 [] {
  let got = (cmd ['INPUT'] ['OUTPUT'] | crop -k | run -d | get 4);
  let want = 'crop=w=iw:x=0:y=0:keep_aspect=1:exact=0';

  assert equal $got $want;
}

#[test]
def without_filterchain_chains_are_concated [] {
    let got = (cmd ['INPUT'] ['OUTPUT'] | fps 25 | loop 2 1);

    assert equal $got {
        input: ['INPUT']
        filters: [
          [
            {
              input: []
              name: 'fps'
              params: [
                {param: 'fps' value: '25'}
              ]
              output: []
            }
            #{
            #  input: []
            #  name: 'settb'
            #  params: [
            #    {param: 'expr' value: '1/25'}
            #  ]
            #  output: []
            #}
          ]
          [{
            input: []
            name: 'loop'
            params: [
              {param: 'loop' value: 2}
              {param: 'size' value: 1}
            ]
            output: []
          }]
        ]
        output: ['OUTPUT']
        args: []
        options: { chain_filters: false }
      };
}
#[test]
def filterchain_concats_filters [] {
    let got = (cmd ['INPUT'] ['OUTPUT'] | filterchain { fps 25 -i ['in'] | loop 2 1 -o ['out']});

    assert equal $got {
        input: ['INPUT']
        filters: [[
              {
                input: ['in']
                name: 'fps'
                params: [
                  {param: 'fps' value: '25'}
                ]
                output: []
              }
              #{
              #  input: []
              #  name: 'settb'
              #  params: [
              #    {param: 'expr' value: '1/25'}
              #  ]
              #  output: []
              #}
              {
                input: []
                name: 'loop'
                params: [
                  {param: 'loop' value: 2}
                  {param: 'size' value: 1}
                ]
                output: ['out']
              }
            ]]
        output: ['OUTPUT']
        args: []
        options: { chain_filters: false }
      };
}

#[test]
def filterchain_appends_current_filter [] {
    let got = (cmd ['INPUT'] ['OUTPUT'] | fps 12 | filterchain { fps 25 -i ['in'] | loop 2 1 -o ['out']});

    assert equal $got {
        input: ['INPUT']
        filters: [
          [
            {
              input: []
              name: 'fps'
              params: [
                {param: 'fps' value: '12'}
              ]
              output: []
            }
          ]
          [
            {
              input: ['in']
              name: 'fps'
              params: [
                {param: 'fps' value: '25'}
              ]
              output: []
            }
            #{
            #  input: []
            #  name: 'settb'
            #  params: [
            #    {param: 'expr' value: '1/25'}
            #  ]
            #  output: []
            #}
            {
              input: []
              name: 'loop'
              params: [
                {param: 'loop' value: 2}
                {param: 'size' value: 1}
              ]
              output: ['out']
            }
          ]
        ]
        output: ['OUTPUT']
        args: []
        options: { chain_filters: false }
      };
}
