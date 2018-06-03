Facebook::Messenger::Bot.on :message do |message|
  message.mark_seen
  message.typing_on

  if message.quick_reply
    handle_quick_reply(message)
  else
    handle_text(message)
  end
  message.typing_off
end

def handle_quick_reply(incoming)
  classification, message_id = incoming.quick_reply.split(':', 2)
  stored = Message.find(message_id)
  if classification == 'nothing'
    reply_not_saved(incoming, stored)
  else
    reply_thank_you(incoming, stored, classification)
  end
end

def reply_not_saved(incoming, stored)
  stored.allow_removal!
  incoming.reply(text: 'Jag har redan glömt bort vad du sa :)')
rescue => e
  puts e.inspect
  incoming.reply(text: 'Något gick fel, försök gärna igen :( 2 ')
end

def reply_thank_you(incoming, stored, classification)
  ClassifiedMessage.create!(
    classifier_id: stored.sender_id,
    text: stored.text,
    classification: classification
  )
  stored.allow_removal!
  incoming.reply(text: 'Tack för att du hjälper till och gör internet till en säkrare plats!')
rescue => e
  puts e.inspect
  incoming.reply(text: 'Något gick fel, försök gärna igen :( 3 ')
end

def handle_text(incoming)
  return if Message.find_by(mid: incoming.id)
  stored = Message.create!(
    sender_id: incoming.sender['id'],
    text: incoming.text,
    mid: incoming.id
  )
  incoming.reply(
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
  puts e.inspect
  incoming.reply(text: 'Något gick fel, försök gärna igen :( 4 ')
end
