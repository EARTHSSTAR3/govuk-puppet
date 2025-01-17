# == Class: govuk::node::s_backend
#
# Backend machine definition. Backend machines are used for running
# publishing, administration and management applications.
#
class govuk::node::s_backend inherits govuk::node::s_base {
  include govuk::node::s_app_server

  if ($::aws_environment == 'staging') or ($::aws_environment == 'production') {
    include ::hosts::default
    include ::hosts::backend_migration
  }

  limits::limits { 'root_nofile':
    ensure     => present,
    user       => 'root',
    limit_type => 'nofile',
    both       => 16384,
  }

  limits::limits { 'root_nproc':
    ensure     => present,
    user       => 'root',
    limit_type => 'nproc',
    both       => 1024,
  }

  package { 'graphviz':
    ensure => installed,
  }

  package { 'redis-tools':
    ensure => installed,
  }

  include govuk_aws_xray_daemon

  include imagemagick

  include nginx

  if ( $::aws_migration and ($::aws_environment != 'production') ) {
    concat { '/etc/nginx/lb_healthchecks.conf':
      ensure => present,
      before => Nginx::Config::Vhost::Default['default'],
    }
    $extra_config = 'include /etc/nginx/lb_healthchecks.conf;'
  } else {
    $extra_config = ''
  }

  # If we miss all the apps, throw a 500 to be caught by the cache nginx
  nginx::config::vhost::default { 'default':
    extra_config => $extra_config,
  }

  if $::aws_migration {
    include icinga::client::check_pings
  }

  # Ensure memcached is available to backend nodes
  include collectd::plugin::memcached
  class { 'memcached':
    max_memory => '12%',
    listen_ip  => '0.0.0.0',
  }

  # Set Plek for AWS to Carrenza communication
  if ( ( $::aws_migration == 'backend' ) and ($::aws_environment == 'staging') ) or ( ($::aws_migration == 'backend' ) and ($::aws_environment == 'production') ) {
    $app_domain = hiera('app_domain')

    govuk_envvar {
      'PLEK_SERVICE_PUBLISHING_API_URI': value  => "https://publishing-api.${app_domain}";
    }
  }
}
