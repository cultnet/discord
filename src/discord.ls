{ SendQueue } = require (if process.env.CULTNET_LIVE is \true then \@cultnet/send-queue/src/sendQueue else \@cultnet/send-queue)
{ Bus } = require (if process.env.CULTNET_LIVE is \true then \@cultnet/bus/src/bus else \@cultnet/bus)
{ Client } = require \discord.js
export Discord = { start }

function start token
  console.log "connecting to discord"
  discord = new Client!
  send = new SendQueue!
  send.throttle 550

  discord.on \ready attach-handlers

  return discord.login token

  function attach-handlers
    console.log "connected to discord"
    discord.on \message ({ guild, channel, member, author, clean-content, attachments }) ->
      if channel.type isnt \text # TODO: huh what
        return
      Bus.send \event \message \discord,
        source:
          gid: guild.id
          cid: channel.id
        server: guild.name
        channel: channel.name
        nick: member.nickname or author.username
        user-id: author.id
        is-mine: author.id is discord.user.id
        text: get-text ({ clean-content, attachments })
    discord.on \error -> process.exit!
    Bus.receive \action \message \discord ({ target, text }) ->
      guild = discord.guilds.resolve target.gid
      channel = guild.channels.resolve target.cid
      send.push -> channel.send text

function get-text { clean-content, attachments }
  text = clean-content
  if attachments.size > 0
    text := text + " " + attachments.map(-> it.url).join " "
  text
