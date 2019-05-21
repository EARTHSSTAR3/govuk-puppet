# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
define icinga::slack_contact (
  $slack_webhook_url,
  $slack_channel,
  $slack_username = 'Icinga',
  $icinga_status_cgi_url = 'https://example.org/cgi-bin/icinga/status.cgi',
  $icinga_extinfo_cgi_url = 'https://example.org/cgi-bin/icinga/extinfo.cgi'
) {

  include icinga::config::slack

  file {"/etc/icinga/conf.d/contact_${name}.cfg":
    content => template('icinga/slack_contact.cfg.erb'),
    require => Class['icinga::package'],
    notify  => Class['icinga::service'],
  }

}
