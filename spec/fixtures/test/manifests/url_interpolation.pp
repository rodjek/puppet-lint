file { 'test1':
  source => 'puppet:///foo'
}
file { 'test2':
  source => "puppet:///foo/${::fqdn}"
}
file { 'test3':
  source => "puppet:///${::fqdn}/foo"
}
file { 'test4':
  source => "puppet:///foo/${::fqdn}/bar"
}
