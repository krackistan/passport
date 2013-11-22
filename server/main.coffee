Parties = new Meteor.Collection 'parties'
Guests = new Meteor.Collection 'guests'

Parties.allow
  insert: (userId, doc) -> isLocal userId

Guests.allow
  insert: (userId, doc) -> isLocal userId
  update: -> true
  remove: -> true

Meteor.publish 'parties', ->
  return unless isLocal @userId
  Parties.find()

Meteor.publish 'guests', (partyId) ->
  return unless isLocal @userId
  Guests.find
    partyId: partyId

Meteor.publish 'invite', (guestId) ->
  Guests.find
    _id: guestId
  ,
    fields:
      name: 1
      host: 1
      partyName: 1
      partyTime: 1
      rsvp: 1
      check: 1

# TODO: Fix this dirty hack
Meteor.methods
  'headersToken': (token) ->
    return unless headers.list[token]

    @_sessionData.headers = headers.list[token]
    delete headers.list[token]

    ip = @_sessionData?.headers?['x-ip-chain']?.split(',')?[0]
    @setUserId ip if ip and ip isnt @userId

  'isLocal': (ip) ->
    isLocal ip

isLocal = (ip) ->
  return true # for debugging in localhost
  return false unless ip
  return new netmask.Netmask('10.12.0.0/20').contains ip