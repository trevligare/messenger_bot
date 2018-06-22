class ClassificationTransferJob
  require 'pp'

  def perform
    ClassifiedMessage.in_batches.each_record do |message|
      pp message.inspect
      success = submit(message)
      message.destroy if success
    end
  end

  private

  def prepare_params(message)
    {
      token: Rails.application.config.reporting_token,
      reporter: message.classifier_id,
      classification: message.classification,
      text: message.text
    }

  end

  def submit(message)

    response = HTTParty.post(
      "#{Rails.application.config.reporting_uri}/api/v1/reports",
       body: prepare_params(message).to_json,
       headers: headers
    )
    response.code == 201
  end

  def headers
    {}.tap do |h|
      h['Content-Type'] = 'application/json'
      h['Accept'] = 'application/json'
    end
  end
end
