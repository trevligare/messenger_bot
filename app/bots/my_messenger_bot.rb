Facebook::Messenger::Bot.on :message do |message|
  Rails.logger.info "Handling"
  MyMessengerBot.new(message)
end

class MyMessengerBot
  def initialize(message)
    Rails.logger.info "initialized"
    @message = message
    @message.mark_seen
    @message.typing_on

    if @message.quick_reply
      handle_quick_reply
    else
      handle_text
    end
    message.typing_off
  end

  def handle_quick_reply
    classification, message_id = @message.quick_reply.split(':', 2)
    stored = Message.find(message_id)
    if classification == 'nothing'
      reply_not_saved(stored)
    else
      reply_thank_you(stored, classification)
    end
  end

  def reply_not_saved(stored)
    stored.allow_removal!
    @message.reply(text: 'Jag har redan glömt bort vad du sa :)')
  rescue => e
    hash = SecureRandom.hex(3)
    Rails.logger.info "Bot error 2, #{hash}: #{e.inspect}"
    @message.reply(text: 'Något gick fel, försök gärna igen :( [Felkod: 2] ')
  end

  def reply_thank_you(stored, classification)
    ClassifiedMessage.create!(
      classifier_id: stored.sender_id,
      text: stored.text,
      classification: classification
    )
    stored.allow_removal!
    @message.reply(text: 'Tack för att du hjälper till och gör internet till en säkrare plats!')
  rescue => e
    hash = SecureRandom.hex(3)
    Rails.logger.info "Bot error 3, #{hash}: #{e.inspect}"
    @message.reply(text: 'Något gick fel, försök gärna igen :( [Felkod: 3] ')
  end

  def handle_text
    return if Message.find_by(mid: @message.id)
    stored = Message.create!(
      sender_id: @message.sender['id'],
      text: @message.text,
      mid: @message.id
    )
    @message.reply(
      text: 'Hur skulle du klassificera meddelandet ovan?',
      quick_replies: [
        {
          content_type: 'text',
          title: 'Som hat/hate speech',
          payload: "hate:#{stored.id}"
        },
        {
          content_type: 'text',
          title: 'Som ett hot',
          payload: "threat:#{stored.id}"
        },
        {
          content_type: 'text',
          title: 'Spara inte detta',
          payload: "nothing:#{stored.id}"
        },
      ]
    )
  rescue => e
    hash = SecureRandom.hex(3)
    Rails.logger.info "Bot error 4, #{hash}: #{e.inspect}"
    @message.reply(text: 'Något gick fel, försök gärna igen :( [Felkod: 4] ')
  end
end
