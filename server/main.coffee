Parties = new Meteor.Collection 'parties'
Guests = new Meteor.Collection 'guests'

Meteor.startup () ->
# code to run on server at startup