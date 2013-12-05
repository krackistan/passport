@Parties = new Meteor.Collection 'parties'
@Guests = new Meteor.Collection 'guests'

Meteor.startup ->
  Deps.autorun ->
    # Local
    Meteor.subscribe 'parties'
    Meteor.subscribe 'guests', Session.get 'currentPartyId'

    # Public
    Meteor.subscribe 'invite', Session.get 'currentGuestId'

  Deps.autorun ->
    updateLocal()
    Meteor.setTimeout updateLocal, 100
    Meteor.setTimeout updateLocal, 250
    Meteor.setTimeout updateLocal, 1000
    Meteor.setTimeout updateLocal, 2500

updateLocal = ->
  Meteor.call 'amILocal', (err, isLocal) ->
    throw err if err
    console.log isLocal
    Session.set 'isLocal', isLocal

Meteor.Router.add
  '/': 'parties'
  '/party/:id':
    to: 'guests'
    and: (id) ->
      Session.set 'currentPartyId', id
  '/invite/:id':
    to: 'invite'
    and: (id) ->
      Session.set 'currentGuestId', id

  '/invite/:id/gate':
    to: 'gate'
    and: (id) ->
      Session.set 'currentGuestId', id

Meteor.Router.beforeRouting = ->
  Session.set 'currentPartyId', false
  Session.set 'currentPartyName', false
  Session.set 'currentPartyTime', false
  Session.set 'currentGuestId', false
  Session.set 'currentGateNumber', 1
  Session.set 'choseWrongOption', false


# Parties

Template.parties.list = ->
  Parties.find {},
    sort:
      created: -1

Template.parties.isLocal = ->
  Session.get 'isLocal'

Template.parties.events
  'submit form': (e) ->
    e.preventDefault()
    data = _.object([o.name, o.value] for o in $(e.target).serializeArray())
    return unless data?.name and data?.time
    $(e.target).trigger 'reset'
    Parties.insert
      name: data.name
      time: data.time
      created: new Date()


# Guests

Template.guests.party = ->
  party = Parties.findOne
    _id: Session.get 'currentPartyId'
  Session.set 'currentPartyName', party?.name
  Session.set 'currentPartyTime', party?.time
  party

Template.guests.list = ->
  Guests.find
    partyId: Session.get 'currentPartyId'
  ,
    sort:
      check: 1
      host: 1

Template.guests.myGuest = ->
  guest = Guests.findOne
    _id: Session.get 'myGuestId'

Template.guests.isLocal = ->
  Session.get 'isLocal'

Template.guests.events
  'submit form': (e, template) ->
    e.preventDefault()
    data = _.object([o.name, o.value] for o in $(e.target).serializeArray())
    return unless data?.host and data?.guest
    $(e.target).trigger 'reset'
    Guests.insert
      name: data.guest
      host: data.host
      partyId: Session.get 'currentPartyId'
      partyName: Session.get 'currentPartyName'
      partyTime: Session.get 'currentPartyTime'
      rsvp: false
      check: false
      created: new Date()
    , (err, id) ->
      throw err if err
      Session.set 'myGuestId', id

Template.guestItem.events
  'click input.check-in-button': (e, template) ->
    e.preventDefault()
    Guests.update
      _id: template.data._id
    ,
      $set:
        check: true


# Invite

Template.invite.guest = ->
  Guests.findOne
    _id: Session.get 'currentGuestId'

Template.invite.party = ->
  guest = Guests.findOne
    _id: Session.get 'currentGuestId'

Template.invite.events
  'click .continue-button': (e) ->
    Meteor.Router.to Meteor.Router.gatePath Session.get 'currentGuestId'

Template.gate.isGate = (number) ->
  Session.equals 'currentGateNumber', number

Template.gate.choseWrongOption = ->
  Session.get 'choseWrongOption'

Template.gate.events
  'click .start-over': (e) ->
    Session.set 'choseWrongOption', false
    Session.set 'currentGateNumber', 1

  'click .correct-option': (e) ->
    unless Session.get 'choseWrongOption'
      current = Session.get 'currentGateNumber'
      Session.set 'currentGateNumber', current + 1

  'click .wrong-option': (e) ->
    Session.set 'choseWrongOption', true

  'click .rsvp': (e) ->
    e.preventDefault()
    Guests.update
      _id: Session.get 'currentGuestId'
    ,
      $set:
        rsvp: true
    Meteor.Router.to Meteor.Router.invitePath Session.get 'currentGuestId'
