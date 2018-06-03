require 'facebook/messenger'

include Facebook::Messenger

Bot.on :message do |message|
  message.mark_seen

  message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
  message.sender      # => { 'id' => '1008372609250235' }
  message.seq         # => 73
  message.sent_at     # => 2016-04-22 21:30:36 +0200
  message.text        # => 'Hello, bot!'
  message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]

  if message.quick_reply
    handle_quick_reply(message)
  else
    handle_text(message)
  end
end

def handle_quick_reply(message)
  puts message.inspect
  if message.quick_reply == 'nothing'
    reply_not_saved(message)
  else
    reply_thank_you(message)
  end
end

def reply_not_saved(message)
  message.reply(text: 'Jag har redan glömt bort vad du sa :)')
end

def reply_thank_you(message)
  message.reply(text: 'Tack för att du hjälper till och gör internet till en säkrare plats!')
end

def handle_text(message)
  message.reply(
    text: 'Hur skulle du klassificera meddelandet ovan?',
    quick_replies: [
      {
        content_type: 'text',
        title: 'Som hat/hate speech',
        payload: 'hate'
      },
      {
        content_type: 'text',
        title: 'Som ett hot',
        payload: 'threat'
      },
      {
        content_type: 'text',
        title: 'Spara inte detta',
        payload: 'nothing'
      },
    ]
  )
end

Bot.on :postback do |postback|
  postback.sender    # => { 'id' => '1008372609250235' }
  postback.recipient # => { 'id' => '2015573629214912' }
  postback.sent_at   # => 2016-04-22 21:30:36 +0200
  postback.payload   # => 'EXTERMINATE'

  if (postback.payload != 'nothing')
    puts "Human answered #{postback.payload}"
    puts postback.inspect
    postback.reply(text: 'Tack för att du hjälper till och gör internet till en säkrare plats!')
  else
    postback.reply(text: 'Jag har redan glömt bort vad du sa :)')
  end
end
