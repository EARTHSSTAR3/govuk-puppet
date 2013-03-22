class nginx::config {

  file { '/etc/nginx':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/nginx/etc/nginx';
  }

  $server_name_max_hash_size = extlookup('nginx_server_name_max_hash_size',512)
  file { '/etc/nginx/nginx.conf':
    ensure  => present,
    content => template('nginx/etc/nginx/nginx.conf.erb'),
  }
  nginx::log {  [
                'access.log',
                'error.log'
                ]:
                  logstream => true;
  }

  file { ['/etc/nginx/sites-enabled', '/etc/nginx/sites-available']:
    ensure  => directory,
    recurse => true, # enable recursive directory management
    purge   => true, # purge all unmanaged junk
    force   => true, # also purge subdirs and links etc.
    require => File['/etc/nginx'];
  }

  file { '/etc/nginx/mime.types':
    ensure  => present,
    source  => 'puppet:///modules/nginx/etc/nginx/mime.types',
    require => File['/etc/nginx'],
    notify  => Class['nginx::service'];
  }


  file { ['/var/www', '/var/www/cache']:
    ensure => directory,
    owner  => 'www-data',
  }

  file { '/var/www/error':
    ensure  => directory,
    source  => 'puppet:///modules/nginx/error',
    purge   => true,
    recurse => true,
    force   => true,
    require => File['/var/www'],
  }

  @@nagios::check { "check_nginx_active_connections_${::hostname}":
    check_command       => "check_graphite_metric!${::fqdn_underscore}.nginx.nginx_connections-active!500!1000",
    service_description => 'nginx high active conn',
    host_name           => $::fqdn,
  }

}
