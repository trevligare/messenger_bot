namespace :classifications do
  desc "Transfers classified messages"
  task transfer: :environment do
    ClassificationTransferJob.new.perform
  end
end
