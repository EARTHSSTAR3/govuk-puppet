# == Class: govuk_crawler::config
#
# Class for configuring the AWS keys used to upload crawler results to S3.
#
# [*aws_access_key*]
#   access key for AWS
#
# [*aws_secret_key*]
#   secret for chosen AWS key
#
# Will be set using environment variables, see:
# http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment
#
# [*crawler_user*]
#   User that the synchronisation cron job runs as.
#   Default: 'govuk-crawler'
#
class govuk_crawler::config (
  $aws_access_key = undef,
  $aws_secret_key = undef,
  $crawler_user   = 'govuk-crawler',
) {
  $env_name = 's3_sync_mirror'

  file { ["/etc/govuk/${env_name}", "/etc/govuk/${env_name}/env.d"]:
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    force   => true,
    mode    => '0755',
  }

  File {
    owner   => $crawler_user,
    group   => $crawler_user,
    mode    => '0600',
    ensure  => present,
  }

  if $aws_secret_key {
    file { "/etc/govuk/${env_name}/env.d/AWS_SECRET_ACCESS_KEY":
      content => $aws_secret_key,
    }
  } else {
    file { "/etc/govuk/${env_name}/env.d/AWS_SECRET_ACCESS_KEY":
      ensure => 'absent',
    }
  }

  if $aws_access_key {
    file { "/etc/govuk/${env_name}/env.d/AWS_ACCESS_KEY_ID":
      content => $aws_access_key,
    }
  } else {
    file { "/etc/govuk/${env_name}/env.d/AWS_ACCESS_KEY_ID":
      ensure => 'absent',
    }
  }
}
