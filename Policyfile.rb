# frozen_string_literal: true

name 'snort'

default_source :supermarket

run_list 'test::default'
named_run_list :default, 'test::default'

cookbook 'snort', path: '.'
cookbook 'test', path: 'test/fixtures/cookbooks/test'
