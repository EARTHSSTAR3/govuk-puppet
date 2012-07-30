class ertp_base {
  include base

  include users
  include users::groups::govuk
  include users::groups::ertp
  include hosts::ertp
}

class ertp_base::mongo_server inherits ertp_base {
  include mongodb::server
  include mongodb::monitoring

  class {'mongodb::configure_replica_set':
    members => [
      'ertp-mongo-1',
      'ertp-mongo-2',
      'ertp-mongo-3'
    ]
  }
}

class ertp_base::frontend_server inherits ertp_base {
  case $::govuk_platform {
    staging: {
      class { 'nginx' : node_type => ertp_staging }
    }
    default: {
      class { 'nginx' : node_type => ertp_preview }
    }
  }

  include ertp::config
  include ertp::scripts
}

class ertp_base::api_server inherits ertp_base {
  case $::govuk_platform {
    staging: {
      class { 'nginx' : node_type => ertp_api_staging }
    }
    default: {
      class { 'nginx' : node_type => ertp_api_preview }
    }
  }

  include ertp::api::scripts
}

class ertp_base::api_server::dwp inherits ertp_base::api_server {
  include ertp::dwp::api::config
}

class ertp_base::api_server::ero inherits ertp_base::api_server {
  include ertp::ero::api::config
}

class ertp_base::api_server::citizen inherits ertp_base::api_server {
  include ertp::citizen::api::config
}

class ertp_base::api_server::all inherits ertp_base::api_server {
  include ertp::config
}

class ertp_base::development inherits ertp_base {
  include ertp_base::mongo_server
  include ertp::config
  class { 'nginx' : node_type => ertp }
  include ertp::config
  include ertp::scripts
}
