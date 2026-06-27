# == Class: sc_monit
#
# ScaleCommerce Wrapper Module for sbitio-monit.
# Manages Supervisord.
#
# === Variables
#
# [*supervisor_init_script*]
#  full path to supervisor init wrapper script
#
# [*supervisor_conf_script*
#  full path to supervisor conf script
#
# [*supervisor_exec_path*]
#  path to supervisor executable
#
# [*use_supervisor*]
#  can be true or false, default is true.
#  determines if monit is managed via supervisord. Set false on nodes that do
#  not use supervisord (e.g. zpinit) to skip the supervisord wiring (and the
#  unconditional inclusion of the supervisord daemon).
#
# === Authors
#
# Adrian Kirchner <ak@scale.sc>
#
# === Copyright
#
# Copyright 2017 ScaleCommerce GmbH.
#

class sc_monit (
  $supervisor_exec_path   = '/usr/local/bin',
  $use_supervisor         = true,
) {

  include monit

  if $use_supervisor {
    include sc_supervisor

    # supervisor
    file { '/etc/init.d/monit':
      ensure => link,
      target => "${sc_supervisor::init_path}/supervisor-init-wrapper",
    }

    file { "${supervisord::config_include}/monit.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/monit.supervisor.conf.erb"),
      notify  => Class[supervisord::reload],
    }

    exec {'supervisorctl_monit_update':
      command     => "${supervisor_exec_path}/supervisorctl update",
      refreshonly => true,
    }
  }

}
