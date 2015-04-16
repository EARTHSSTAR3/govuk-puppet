# == Class: govuk::apps::performanceplatform_notifier
#
# Performance Platform notifier is an application which doesn't run
# as a service. It's triggered by cron periodically to send emails,
# so we only need `govuk::app::package`.
#
# === Parameters
#
# [*enabled*]
#   Should the app exist?
#
class govuk::apps::performanceplatform_notifier (
  $enabled = false,
) {

  if $enabled {
    include govuk::deploy

    $app_domain = hiera('app_domain')

    # vhost_full is a confusingly-named parameter. It's used to create
    # the /data/vhost/{$appname} directory at deploy time.
    govuk::app::package { 'performanceplatform-notifier':
      vhost_full => "performanceplatform-notifier.${app_domain}",
    }
  }
}
