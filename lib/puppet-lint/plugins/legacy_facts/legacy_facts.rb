# Public: A puppet-lint custom check to detect legacy facts.
#
# This check will optionally convert from legacy facts like $::operatingsystem
# or legacy hashed facts like $facts['operatingsystem'] to the
# new structured facts like $facts['os']['name'].
#
# This plugin was adopted in to puppet-lint from https://github.com/mmckinst/puppet-lint-legacy_facts-check
# Thanks to @mmckinst, @seanmil, @rodjek, @baurmatt, @bart2 and @joshcooper for the original work.
PuppetLint.new_check(:legacy_facts) do
  LEGACY_FACTS_VAR_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  # These facts that can't be converted to new facts.
  UNCONVERTIBLE_FACTS = ['memoryfree_mb', 'memorysize_mb', 'swapfree_mb',
                         'swapsize_mb', 'blockdevices', 'interfaces', 'zones',
                         'sshfp_dsa', 'sshfp_ecdsa', 'sshfp_ed25519',
                         'sshfp_rsa'].freeze

  # These facts will depend on how a system is set up and can't just be
  # enumerated like the EASY_FACTS below.
  #
  # For example a server might have two block devices named 'sda' and 'sdb' so
  # there would be a $blockdeivce_sda_vendor and $blockdeivce_sdb_vendor fact
  # for each device. Or it could have 26 block devices going all the way up to
  # 'sdz'. There is no way to know what the possibilities are so we have to use
  # a regex to match them.
  REGEX_FACTS = [%r{^blockdevice_(?<devicename>.*)_(?<attribute>model|size|vendor)$},
                 %r{^(?<attribute>ipaddress|ipaddress6|macaddress|mtu|netmask|netmask6|network|network6)_(?<interface>.*)$},
                 %r{^processor(?<id>[0-9]+)$},
                 %r{^sp_(?<name>.*)$},
                 %r{^ssh(?<algorithm>dsa|ecdsa|ed25519|rsa)key$},
                 %r{^ldom_(?<name>.*)$},
                 %r{^zone_(?<name>.*)_(?<attribute>brand|iptype|name|uuid|id|path|status)$}].freeze

  # These facts have a one to one correlation between a legacy fact and a new
  # structured fact.
  EASY_FACTS = {
    'architecture'                => "facts['os']['architecture']",
    'augeasversion'               => "facts['augeas']['version']",
    'bios_release_date'           => "facts['dmi']['bios']['release_date']",
    'bios_vendor'                 => "facts['dmi']['bios']['vendor']",
    'bios_version'                => "facts['dmi']['bios']['version']",
    'boardassettag'               => "facts['dmi']['board']['asset_tag']",
    'boardmanufacturer'           => "facts['dmi']['board']['manufacturer']",
    'boardproductname'            => "facts['dmi']['board']['product']",
    'boardserialnumber'           => "facts['dmi']['board']['serial_number']",
    'chassisassettag'             => "facts['dmi']['chassis']['asset_tag']",
    'chassistype'                 => "facts['dmi']['chassis']['type']",
    'domain'                      => "facts['networking']['domain']",
    'fqdn'                        => "facts['networking']['fqdn']",
    'gid'                         => "facts['identity']['group']",
    'hardwareisa'                 => "facts['processors']['isa']",
    'hardwaremodel'               => "facts['os']['hardware']",
    'hostname'                    => "facts['networking']['hostname']",
    'id'                          => "facts['identity']['user']",
    'ipaddress'                   => "facts['networking']['ip']",
    'ipaddress6'                  => "facts['networking']['ip6']",
    'lsbdistcodename'             => "facts['os']['distro']['codename']",
    'lsbdistdescription'          => "facts['os']['distro']['description']",
    'lsbdistid'                   => "facts['os']['distro']['id']",
    'lsbdistrelease'              => "facts['os']['distro']['release']['full']",
    'lsbmajdistrelease'           => "facts['os']['distro']['release']['major']",
    'lsbminordistrelease'         => "facts['os']['distro']['release']['minor']",
    'lsbrelease'                  => "facts['os']['distro']['release']['specification']",
    'macaddress'                  => "facts['networking']['mac']",
    'macosx_buildversion'         => "facts['os']['build']",
    'macosx_productname'          => "facts['os']['product']",
    'macosx_productversion'       => "facts['os']['version']['full']",
    'macosx_productversion_major' => "facts['os']['version']['major']",
    'macosx_productversion_minor' => "facts['os']['version']['minor']",
    'manufacturer'                => "facts['dmi']['manufacturer']",
    'memoryfree'                  => "facts['memory']['system']['available']",
    'memorysize'                  => "facts['memory']['system']['total']",
    'netmask'                     => "facts['networking']['netmask']",
    'netmask6'                    => "facts['networking']['netmask6']",
    'network'                     => "facts['networking']['network']",
    'network6'                    => "facts['networking']['network6']",
    'operatingsystem'             => "facts['os']['name']",
    'operatingsystemmajrelease'   => "facts['os']['release']['major']",
    'operatingsystemrelease'      => "facts['os']['release']['full']",
    'osfamily'                    => "facts['os']['family']",
    'physicalprocessorcount'      => "facts['processors']['physicalcount']",
    'processorcount'              => "facts['processors']['count']",
    'productname'                 => "facts['dmi']['product']['name']",
    'rubyplatform'                => "facts['ruby']['platform']",
    'rubysitedir'                 => "facts['ruby']['sitedir']",
    'rubyversion'                 => "facts['ruby']['version']",
    'selinux'                     => "facts['os']['selinux']['enabled']",
    'selinux_config_mode'         => "facts['os']['selinux']['config_mode']",
    'selinux_config_policy'       => "facts['os']['selinux']['config_policy']",
    'selinux_current_mode'        => "facts['os']['selinux']['current_mode']",
    'selinux_enforced'            => "facts['os']['selinux']['enforced']",
    'selinux_policyversion'       => "facts['os']['selinux']['policy_version']",
    'serialnumber'                => "facts['dmi']['product']['serial_number']",
    'swapencrypted'               => "facts['memory']['swap']['encrypted']",
    'swapfree'                    => "facts['memory']['swap']['available']",
    'swapsize'                    => "facts['memory']['swap']['total']",
    'system32'                    => "facts['os']['windows']['system32']",
    'uptime'                      => "facts['system_uptime']['uptime']",
    'uptime_days'                 => "facts['system_uptime']['days']",
    'uptime_hours'                => "facts['system_uptime']['hours']",
    'uptime_seconds'              => "facts['system_uptime']['seconds']",
    'uuid'                        => "facts['dmi']['product']['uuid']",
    'xendomains'                  => "facts['xen']['domains']",
    'zonename'                    => "facts['solaris_zones']['current']",
  }.freeze

  # A list of valid hash key token types
  HASH_KEY_TYPES = Set[
    :STRING,  # Double quoted string
    :SSTRING, # Single quoted string
    :NAME,    # Unquoted single word
  ].freeze

  def check
    tokens.select { |x| LEGACY_FACTS_VAR_TYPES.include?(x.type) }.each do |token|
      fact_name = ''

      # Get rid of the top scope before we do our work. We don't need to
      # preserve it because it won't work with the new structured facts.
      if token.value.start_with?('::')
        fact_name = token.value.sub(%r{^::}, '')

      # This matches using legacy facts in a the new structured fact. For
      # example this would match 'uuid' in $facts['uuid'] so it can be converted
      # to facts['dmi']['product']['uuid']"
      elsif token.value == 'facts'
        fact_name = hash_key_for(token)

      elsif token.value.start_with?("facts['")
        fact_name = token.value.match(%r{facts\['(.*)'\]})[1]
      end

      next unless EASY_FACTS.include?(fact_name) || UNCONVERTIBLE_FACTS.include?(fact_name) || fact_name.match(Regexp.union(REGEX_FACTS))
      notify :warning, {
        message: "legacy fact '#{fact_name}'",
        line: token.line,
        column: token.column,
        token: token,
        fact_name: fact_name,
      }
    end
  end

  # If the variable is using the $facts hash represented internally by multiple
  # tokens, this helper simplifies accessing the hash key.
  def hash_key_for(token)
    lbrack_token = token.next_code_token
    return '' unless lbrack_token && lbrack_token.type == :LBRACK

    key_token = lbrack_token.next_code_token
    return '' unless key_token && HASH_KEY_TYPES.include?(key_token.type)

    key_token.value
  end

  def fix(problem)
    fact_name = problem[:fact_name]

    # Check if the variable is using the $facts hash represented internally by
    # multiple tokens and remove the tokens for the old legacy key if so.
    if problem[:token].value == 'facts'
      loop do
        t = problem[:token].next_token
        remove_token(t)
        break if t.type == :RBRACK
      end
    end

    if EASY_FACTS.include?(fact_name)
      problem[:token].value = EASY_FACTS[fact_name]
    elsif fact_name.match(Regexp.union(REGEX_FACTS))
      if (m = fact_name.match(%r{^blockdevice_(?<devicename>.*)_(?<attribute>model|size|vendor)$}))
        problem[:token].value = "facts['disks']['" << m['devicename'] << "']['" << m['attribute'] << "']"
      elsif (m = fact_name.match(%r{^(?<attribute>ipaddress|ipaddress6|macaddress|mtu|netmask|netmask6|network|network6)_(?<interface>.*)$}))
        problem[:token].value = "facts['networking']['interfaces']['" << m['interface'] << "']['" << m['attribute'].sub('address', '') << "']"
      elsif (m = fact_name.match(%r{^processor(?<id>[0-9]+)$}))
        problem[:token].value = "facts['processors']['models'][" << m['id'] << ']'
      elsif (m = fact_name.match(%r{^sp_(?<name>.*)$}))
        problem[:token].value = "facts['system_profiler']['" << m['name'] << "']"
      elsif (m = fact_name.match(%r{^ssh(?<algorithm>dsa|ecdsa|ed25519|rsa)key$}))
        problem[:token].value = "facts['ssh']['" << m['algorithm'] << "']['key']"
      elsif (m = fact_name.match(%r{^ldom_(?<name>.*)$}))
        problem[:token].value = "facts['ldom']['" << m['name'] << "']"
      elsif (m = fact_name.match(%r{^zone_(?<name>.*)_(?<attribute>brand|iptype|name|uuid|id|path|status)$}))
        problem[:token].value = "facts['solaris_zones']['zones']['" << m['name'] << "']['" << m['attribute'] << "']"
      end
    end
  end
end
