# GoodJob is our background queue. Postgres-backed so we don't need Redis.
# See https://github.com/bensheldon/good_job#configuration

Rails.application.configure do
  # Test env uses ActiveJob's :test adapter (set in config/environments/test.rb)
  # so `have_enqueued_job` matchers work and jobs don't hit the queue table.
  unless Rails.env.test?
    config.active_job.queue_adapter = :good_job
  end

  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.queues = "default:5"

  # When the worker service is running (i.e. running `good_job start`),
  # the web container should NOT poll for jobs — let the worker do it.
  config.good_job.execution_mode =
    if ENV["GOOD_JOB_EXECUTION_MODE"] == "external"
      :external
    elsif Rails.env.test?
      :inline
    else
      :async
    end
end
