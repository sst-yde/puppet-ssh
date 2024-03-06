# @summary
#   Managed ssh server configuration
#
# @api private
#
class ssh::server::config {
  assert_private()

  $options = $ssh::server::merged_options

  case $ssh::server::validate_sshd_file {
    true: {
      $sshd_validate_cmd = $ssh::server::sshd_validate_cmd
    }
    default: {
      $sshd_validate_cmd = undef
    }
  }

  if $ssh::server::use_augeas {
    $options.each |String $k, Hash $v| {
      sshd_config { $k:
        * => $v,
      }
    }
  } else {
    concat { $ssh::server::sshd_config:
      ensure       => present,
      owner        => $ssh::server::sshd_config_owner,
      group        => $ssh::server::sshd_config_group,
      mode         => $ssh::server::sshd_config_mode,
      validate_cmd => $sshd_validate_cmd,
      notify       => Service[$ssh::server::service_name],
    }

    concat::fragment { 'global config':
      target  => $ssh::server::sshd_config,
      content => template("${module_name}/sshd_config.erb"),
      order   => '00',
    }
  }

  if $ssh::server::use_issue_net {
    file { $ssh::server::issue_net:
      ensure  => file,
      owner   => $ssh::server::issue_net_owner,
      group   => $ssh::server::issue_net_group,
      mode    => $ssh::server::issue_net_mode,
      content => template("${module_name}/issue.net.erb"),
      notify  => Service[$ssh::server::service_name],
    }

    concat::fragment { 'banner file':
      target  => $ssh::server::sshd_config,
      content => "Banner ${ssh::server::issue_net}\n",
      order   => '01',
    }
  }
}
