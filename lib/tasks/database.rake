namespace :database do
  desc "Scheduled job that cleans out soft_deleted or old messages"
  task clean: :environment do
    Message.vacuum
  end
end
