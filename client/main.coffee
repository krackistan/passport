Parties = new Meteor.Collection 'parties'
Guests = new Meteor.Collection 'guests'


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


# Parties

Template.parties.list = ->
  Parties.find()

Template.parties.events
  'submit form': (e) ->
    e.preventDefault()
    data = _.object([o.name, o.value] for o in $(e.target).serializeArray())
    return unless data?.name
    $(e.target).trigger 'reset'
    Parties.insert
      name: data.name
      created: new Date()


# Guests

Template.guests.party = ->
  Parties.findOne
    _id: Session.get 'currentPartyId'

Template.guests.list = ->
  Guests.find
    party: Session.get 'currentPartyId'

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
      invited: new Date()
      rsvp: false


# Invite

Template.invite.guest = ->
  Guests.findOne
    _id: Session.get 'currentGuestId'

Template.invite.events
  'click input#rsvp': (e) ->
    e.preventDefault()
    Guests.update
      _id: Session.get 'currentGuestId'
    ,
      $set:
        rsvp: true