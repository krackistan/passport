Parties = new Meteor.Collection 'parties'
Guests = new Meteor.Collection 'guests'

Meteor.startup ->
  Deps.autorun ->
    # Local
    Meteor.subscribe 'parties'
    Meteor.subscribe 'guests', Session.get 'currentPartyId'

    # Public
    Meteor.subscribe 'invite', Session.get 'currentGuestId'

  Deps.autorun ->
    Meteor.call 'isLocal', Meteor.userId(), (err, isLocal) ->
      throw err if err
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

Meteor.Router.beforeRouting = ->
  Session.set 'currentPartyId', false
  Session.set 'currentPartyName', false
  Session.set 'currentPartyTime', false
  Session.set 'currentGuestId', false
  Session.set 'currentGateNumber', 1
  Session.set 'choseCorrectOption', false
  Session.set 'choseWrongOption', false
  Session.set 'disableOptions', false


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
  'click input.rsvp-button': (e) ->
    e.preventDefault()
    Guests.update
      _id: Session.get 'currentGuestId'
    ,
      $set:
        rsvp: true

Template.gate.number = ->
  Session.get 'currentGateNumber'

Template.gate.events
  'click .advance-gate-button': (e) ->
    # Reset
    Session.set 'choseCorrectOption', false
    Session.set 'choseWrongOption', false
    Session.set 'disableOptions', false

    current = Session.get 'currentGateNumber'
    next = current + 1
    $('.gate').hide()
    $('.gate [name=\'gate-' + next + '\']').show()
    Session.set 'currentGateNumber', next

  'click .correct-option': (e) ->
    Session.set 'choseCorrectOption', true
    Session.set 'disableOptions', true

  'click .wrong-option': (e) ->
    Session.set 'choseWrongOption', true
    Session.set 'disableOptions', true