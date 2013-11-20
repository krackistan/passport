Parties = new Meteor.Collection 'parties'
Guests = new Meteor.Collection 'guests'

Meteor.startup ->
# code to run on server at startup

Parties.allow
  insert: -> isLocal()

Guests.allow
  insert: -> isLocal()
  update: -> true
  remove: -> true

Meteor.publish 'parties', ->
  return unless isLocal()
  Parties.find()

Meteor.publish 'guests', (partyId) ->
  check(partyId, String)
  return unless isLocal()
  Guests.find
    party: partyId

Meteor.publish 'invite', (guestId) ->
  check(guestId, String)
  Guests.find
    _id: guestId
  ,
    fields:
      name: 1
      host: 1
      rsvp: 1
      check: 1

isLocal = ->
  false # iff local IP