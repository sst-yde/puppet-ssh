# @summary
#   Manages ssh configuration
#
# @api private
#
class ssh::client::config {
  assert_private()

  $options = $ssh::client::merged_options
  $use_augeas = $ssh::client::use_augeas

  if $use_augeas {
    $options.each |String $k, Hash $v| {
      ssh_config { $k:
        * => $v,
      }
    }
  } else {
    concat { $ssh::client::ssh_config:
      ensure => present,
      owner  => $ssh::client::ssh_config_owner,
      group  => $ssh::client::ssh_config_group,
      mode   => $ssh::client::ssh_config_mode,
    }

    concat::fragment { 'ssh_config global config':
      target  => $ssh::client::ssh_config,
      content => template("${module_name}/ssh_config.erb"),
      order   => '00',
    }
  }
}
