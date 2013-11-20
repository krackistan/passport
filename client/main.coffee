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
  Session.set 'currentGuestId', false


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
    return unless data?.name and data?.when
    $(e.target).trigger 'reset'
    Parties.insert
      name: data.name
      when: data.when
      created: new Date()


# Guests

Template.guests.party = ->
  Parties.findOne
    _id: Session.get 'currentPartyId'

Template.guests.list = ->
  Guests.find
    party: Session.get 'currentPartyId'
  ,
    sort:
      host: 1

Template.guests.myGuest = ->
  guest = Guests.findOne
    _id: Session.get 'myGuestId'

Template.guests.isLocal = ->
  Session.get 'isLocal'

Template.guests.events
  'submit form': (e) ->
    e.preventDefault()
    data = _.object([o.name, o.value] for o in $(e.target).serializeArray())
    return unless data?.host and data?.guest
    $(e.target).trigger 'reset'
    Guests.insert
      name: data.guest
      host: data.host
      party: Session.get 'currentPartyId'
      rsvp: false
      check: false
      created: new Date()
    , (err, id) ->
      throw err if err
      Session.set 'myGuestId', id


# Invite

Template.invite.guest = ->
  Guests.findOne
    _id: Session.get 'currentGuestId'

Template.invite.events
  'click input.rsvp-button': (e) ->
    e.preventDefault()
    Guests.update
      _id: Session.get 'currentGuestId'
    ,
      $set:
        rsvp: true

Template.guestItem.events
  'click input.check-in-button': (e, template) ->
    e.preventDefault()
    Guests.update
      _id: template.data._id
    ,
      $set:
        check: true