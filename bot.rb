require 'discordrb'
require 'sqlite3'
require 'pp'
require 'yaml'

CONFIG = YAML.load_file('secrets.yml')

@bot = Discordrb::Commands::CommandBot.new \
  token: CONFIG['token'],
  client_id: 317_719_740_099_592_192, prefix: '/'

@db = SQLite3::Database.new 'reuben.db'

@bot.command :ping do
  'Pong!'
end

@bot.command :rep do |event, arg|
  arg_id = arg.tr('<>@', '')
  # User is in the form of [user.id, User]
  next "Whoops! I can't find user #{arg}" if @bot.users.find { |user| user[0].to_s == arg_id }.nil?
  count = @db.execute('SELECT COUNT(*) FROM reps WHERE receiver=?', [arg_id])[0][0]
  "#{arg} has #{count} rep"
end

@bot.command :echo do |event, *args|
  args.join(' ')
end

# Event handler for adding reputation, new thumbs up emoji = +1 rep
@bot.reaction_add do |event|
  if event.emoji.name == '👍' && event.user.id != event.message.user.id
    p "👍 #{event.user.name}##{event.user.id} repped #{event.message.user.name}##{event.message.user.id}"
    @db.execute('INSERT INTO reps (giver, receiver, message, channel, server) VALUES (?, ?, ?, ?, ?)',
                  [event.user.id, event.message.user.id, event.message.id,
                  event.channel.id, event.channel.server.id])
  end
end

# Event handler for removing reputation
@bot.reaction_remove do |event|
  if event.emoji.name == '👍' && event.user.id != event.message.user.id
    p "#{event.user.name}##{event.user.id} reversed rep for #{event.message.user.name}##{event.message.user.id}"
    @db.execute('DELETE FROM reps WHERE giver=? AND receiver=? and message=? and channel=? and server=? limit 1')
  end
end

@bot.run
