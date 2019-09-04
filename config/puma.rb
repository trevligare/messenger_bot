workers Integer(ENV['WEB_CONCURRENCY'] || 2)
max_threads_count = Integer(ENV.fetch('RAILS_MAX_THREADS') { 5 })
min_threads_count = Integer(ENV.fetch('RAILS_MIN_THREADS') { max_threads_count })
threads min_threads_count, max_threads_count

preload_app!

rackup      DefaultRackup
port        Integer(ENV.fetch('PORT') { 3000 })
environment ENV.fetch('RACK_ENV') { 'development' }
# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
