class nagios::client::checks {

  include nagios::client::check_rw_rootfs

  anchor { ['nagios::client::checks::begin', 'nagios::client::checks::end']: }
  Anchor['nagios::client::checks::begin']
    -> Class['nagios::client::check_rw_rootfs']
    -> Anchor['nagios::client::checks::end']

  @nagios::nrpe_config { 'check_file_age':
    source => 'puppet:///modules/nagios/etc/nagios/nrpe.d/check_file_age.cfg',
  }

  @@nagios::check { "check_ping_${::hostname}":
    check_command       => 'check_ping!100.0,20%!500.0,60%',
    notification_period => '24x7',
    use                 => 'govuk_high_priority',
    service_description => 'unable to ping',
    host_name           => $::fqdn,
  }

  # left as a fallback in case someone forgets an individual disk check
  @@nagios::check { "check_disk_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_disk',
    service_description => 'low available disk space',
    use                 => 'govuk_high_priority',
    host_name           => $::fqdn,
    document_url        => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#low-available-disk-space',
  }

  @@nagios::check { "check_root_disk_space_${::hostname}":
    check_command       => 'check_nrpe!check_disk_space_arg!20% 10% /',
    service_description => 'low available disk space on root',
    use                 => 'govuk_high_priority',
    host_name           => $::fqdn,
    document_url        => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#low-available-disk-space',
  }
  @@nagios::check { "check_root_disk_inodes_${::hostname}":
    check_command       => 'check_nrpe!check_disk_inode_arg!20% 10% /',
    service_description => 'low available disk inodes on root',
    use                 => 'govuk_high_priority',
    host_name           => $::fqdn,
    document_url        => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#low-available-disk-space',
  }

  if $::lsbdistcodename == 'precise' {

    @@nagios::check { "check_boot_disk_space_${::hostname}":
      check_command       => 'check_nrpe!check_disk_space_arg!20% 10% /boot',
      service_description => 'low available disk space on /boot',
      use                 => 'govuk_high_priority',
      host_name           => $::fqdn,
      document_url        => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#boot-partition-is-full',
      }

  }

  @@nagios::check { "check_users_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_users',
    service_description => 'high user logins',
    host_name           => $::fqdn,
  }

  @@nagios::check { "check_zombies_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_zombie_procs',
    service_description => 'high zombie procs',
    host_name           => $::fqdn,
    document_url        => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#high-zombie-procs',
  }

  @@nagios::check { "check_procs_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_total_procs',
    service_description => 'high total procs',
    host_name           => $::fqdn,
    document_url        => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#ntp-drift-too-high',
  }

  @@nagios::check { "check_load_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_load',
    service_description => 'high load on',
    host_name           => $::fqdn,
  }

  @@nagios::check { "check_ssh_${::hostname}":
    check_command       => 'check_ssh',
    use                 => 'govuk_high_priority',
    service_description => 'unable to ssh',
    host_name           => $::fqdn,
  }

  # Check how much time the kernel is spending reading and writing to disk. This
  # checks the median (50th percentile) time (in milliseconds) spent per second
  # performing I/O operations over the last 5 minutes. The argument to
  # movingMedian is the number of data points to include in the moving average
  # frame, calculated below as
  #
  #   (5 minutes * 60 seconds minute^-1) / 10 seconds datapoint^-1
  #
  # This will not alert on short spikes in I/O unless they are very large.
  # Instead, it is intended to alert on persistent high I/O.

  $disk_time_window_minutes = 5
  $disk_time_window_points = ($disk_time_window_minutes * 60) / 10

  @@nagios::check::graphite { "check_disk_time_${::hostname}":
    desc      => 'high disk time',
    target    => "movingMedian(sum(${::fqdn_underscore}.disk-sd?.disk_time.*),${disk_time_window_points})",
    args      => "--from ${disk_time_window_minutes}mins",
    warning   => 100, # milliseconds
    critical  => 200, # milliseconds
    host_name => $::fqdn,
  }

  @@nagios::check { "check_ntp_time_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_ntp_time',
    service_description => 'ntp drift too high',
    host_name           => $::fqdn,
  }
}
