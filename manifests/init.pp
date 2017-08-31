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
) {

  include sc_supervisor
  include monit

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
