# == Class: sc_monit
#
# ScaleCommerce Wrapper Module for sbitio-monit. Supervises monit via whichever
# process manager runs on the node (supervisord or zpinit).
#
# monit is declared as a `supervisord::program`, which self-dispatches: on a
# supervisord node it writes a supervisord program conf; on a zpinit node
# (sc::service_manager: zpinit) it writes a zpinit::service TOML instead. The
# `/etc/init.d/monit` shim points at sc_supervisor's backend-aware init wrapper,
# which drives supervisorctl or zpctl accordingly. So the same declaration works
# on both backends and a node migrates without touching this module.
#
# === Variables
#
# [*supervisor_exec_path*]
#  Deprecated/unused. Kept for backwards compatibility with existing data; the
#  program reload is now handled by supervisord::program (and, on zpinit, by the
#  init wrapper's first-load update).
#
# [*use_supervisor*]
#  true (default) supervises monit via the process manager. Set false to leave
#  monit's process supervision entirely unmanaged by this module.
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

    # /etc/init.d/monit -> the backend-aware init wrapper, which drives
    # supervisorctl or zpctl depending on which supervisor is PID 1.
    file { '/etc/init.d/monit':
      ensure => link,
      target => "${sc_supervisor::init_path}/supervisor-init-wrapper",
    }

    # Declare monit as a supervised program. supervisord::program
    # self-dispatches on sc::service_manager: a supervisord program conf on
    # supervisord nodes, a zpinit::service TOML on zpinit nodes. Either way monit
    # becomes known to the backend so the init wrapper can start it.
    supervisord::program { 'monit':
      command     => '/usr/bin/monit -I -c /etc/monit/monitrc',
      autostart   => true,
      autorestart => true,
    }

    # Remove the legacy raw program conf this module used to write directly;
    # supervisord::program now owns monit's program file (program_monit.conf).
    # A no-op on zpinit nodes (the file never existed there).
    file { "${supervisord::config_include}/monit.conf":
      ensure => absent,
    }

    # The program conf / TOML and the init shim must exist before Puppet starts
    # Service[monit] (declared by the monit module), or the first start hits an
    # unknown service.
    Supervisord::Program['monit'] -> Service['monit']
    File['/etc/init.d/monit']     -> Service['monit']
  }

}
