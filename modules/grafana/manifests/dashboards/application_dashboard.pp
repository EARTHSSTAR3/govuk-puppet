# == Define: grafana::dashboards::application_dashboard
#
# Automate the creation of app specific deployment Grafana dashboards
#
# === Parameters
#
# [*app_name*]
#   The dashboard application identifier name. This matches the name of the
#   deployed application
#
# [*docs_name*]
#   The dashboard application repository used for linking to the documentation
#   page for the application
#
# [*dashboard_directory*]
#   The directory where the Grafana config json files are created
#
# [*app_domain*]
#   The suffix that applications use for their domain names
#
# [*has_workers*]
#   Whether the application uses workers
#
# [*error_threshold*]
#   Point at which count turns `red` in the error count table data
#
# [*instance_prefix*]
#   Used for metrics that are named based on the instance name rather than the
#   application. For example, calculators_frontend vs finder_frontend.
#
define grafana::dashboards::application_dashboard (
  $app_name = $title,
  $docs_name = $title,
  $dashboard_directory = undef,
  $app_domain = undef,
  $has_workers = false,
  $error_threshold = 20,
  $warning_threshold = 10,
  $show_sidekiq_graphs = false,
  $show_controller_errors = true,
  $show_response_times = false,
  $show_slow_requests = true,
  $dependent_app_5xx_errors = undef,
  $show_external_request_time = false,
  $show_memcached = false,
  $instance_prefix = '',
  $sentry_environment = $::govuk::deploy::config::errbit_environment_name,

) {
  if $has_workers {
    $worker_row = [['worker_failures', 'worker_successes']]
  } else {
    $worker_row = []
  }

  if $show_controller_errors {
    $errors_by_controller_row = [
      ['errors_by_controller_action']
    ]
  } else {
    $errors_by_controller_row = []
  }

  if $show_response_times {
    $show_response_times_row = [
      ['response_times']
    ]
  } else {
    $show_response_times_row = []
  }

  if $show_slow_requests {
    $duration_by_controller_row = [
      ['response_times_by_controller_action']
    ]
  } else {
    $duration_by_controller_row = []
  }

  if $show_sidekiq_graphs {
    $sidekiq_graph_row = [
      ['sidekiq_queue_length', 'sidekiq_errors']
    ]
  } else {
    $sidekiq_graph_row = []
  }

  if $dependent_app_5xx_errors {
    $dependent_app_5xx_row = [
      ['dependent_app_5xx']
    ]
  } else {
    $dependent_app_5xx_row = []
  }

  if $show_memcached {
    $memcached_row = [
      [
        'memcached']
    ]
  } else {
    $memcached_row = []
  }

# These three are pretty specific to finder frontend.
# If you want to use them then they probably need more white-labelling.
  if $show_external_request_time {
    $external_request_row = [
      [
        'content_store_request_time',
        'registry_request_time',
        'search_api_request_time']
    ]
  } else {
    $external_request_row = []
  }

  $panel_partials = concat(
    [
      ['processor_count'],
      ['error_counts_table', 'links']
    ],
    $worker_row,
    $errors_by_controller_row,
    $show_response_times_row,
    $duration_by_controller_row,
    $dependent_app_5xx_row,
    $sidekiq_graph_row,
    $memcached_row,
    $external_request_row
  )

  file {
    "${dashboard_directory}/${app_name}.json":
    notify  => Service['grafana-server'],
    content => template('grafana/dashboards/application_dashboard_template.json.erb');
  }
}
