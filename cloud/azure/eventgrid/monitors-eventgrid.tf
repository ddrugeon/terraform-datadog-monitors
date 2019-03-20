resource "datadog_monitor" "eventgrid_no_successful_message" {
  count   = "${var.no_successful_message_rate_enabled ? 1 : 0}"
  name    = "[${var.environment}] Event Grid no successful message {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"
  message = "${coalesce(var.no_successful_message_rate_message, var.message)}"

  # Query is a bit weird, but we only want to check the no-data
  query = <<EOF
    ${var.no_successful_message_rate_time_aggregator}(${var.no_successful_message_rate_timeframe}):
      avg:azure.eventgrid_topics.publish_success_count${module.filter-tags.query_alert} by {resource_group,region,name} < 0
  EOF

  type = "metric alert"

  silenced = "${var.no_successful_message_rate_silenced}"

  notify_no_data      = true
  evaluation_delay    = "${var.evaluation_delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = false
  new_host_delay      = "${var.new_host_delay}"

  tags = ["env:${var.environment}", "type:cloud", "provider:azure", "resource:eventgrid", "team:claranet", "created-by:terraform", "${var.no_successful_message_rate_extra_tags}"]
}

resource "datadog_monitor" "eventgrid_failed_messages" {
  count   = "${var.failed_messages_rate_enabled ? 1 : 0}"
  name    = "[${var.environment}] Event Grid too many failed messages {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"
  message = "${coalesce(var.failed_messages_rate_message, var.message)}"

  query = <<EOF
    ${var.failed_messages_rate_time_aggregator}(${var.failed_messages_rate_timeframe}): (default(
      avg:azure.eventgrid_topics.publish_fail_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate() /
      (avg:azure.eventgrid_topics.publish_success_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate() +
       avg:azure.eventgrid_topics.publish_fail_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate() +
       avg:azure.eventgrid_topics.unmatched_event_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate()
      ) * 100, 0)
    ) > ${var.failed_messages_rate_thresold_critical}
  EOF

  type = "metric alert"

  thresholds {
    critical = "${var.failed_messages_rate_thresold_critical}"
    warning  = "${var.failed_messages_rate_thresold_warning}"
  }

  silenced = "${var.failed_messages_rate_silenced}"

  notify_no_data      = false
  evaluation_delay    = "${var.evaluation_delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = false
  new_host_delay      = "${var.new_host_delay}"

  tags = ["env:${var.environment}", "type:cloud", "provider:azure", "resource:eventgrid", "team:claranet", "created-by:terraform", "${var.failed_messages_rate_extra_tags}"]
}

resource "datadog_monitor" "eventgrid_unmatched_events" {
  count   = "${var.unmatched_events_rate_enabled ? 1 : 0}"
  name    = "[${var.environment}] Event Grid too many unmatched events {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"
  message = "${coalesce(var.unmatched_events_rate_message, var.message)}"

  query = <<EOF
    ${var.unmatched_events_rate_time_aggregator}(${var.unmatched_events_rate_timeframe}): (default(
      avg:azure.eventgrid_topics.unmatched_event_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate() /
      (avg:azure.eventgrid_topics.publish_success_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate() +
       avg:azure.eventgrid_topics.publish_fail_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate() +
       avg:azure.eventgrid_topics.unmatched_event_count${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate()
      ) * 100, 0)
    ) > ${var.unmatched_events_rate_thresold_critical}
  EOF

  type = "metric alert"

  thresholds {
    critical = "${var.unmatched_events_rate_thresold_critical}"
    warning  = "${var.unmatched_events_rate_thresold_warning}"
  }

  silenced = "${var.unmatched_events_rate_silenced}"

  notify_no_data      = false
  evaluation_delay    = "${var.evaluation_delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = false
  new_host_delay      = "${var.new_host_delay}"

  tags = ["env:${var.environment}", "type:cloud", "provider:azure", "resource:eventgrid", "team:claranet", "created-by:terraform", "${var.unmatched_events_rate_extra_tags}"]
}