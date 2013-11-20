Package.describe({
  summary: "Meteor smart package for netmask node.js package"
});

Npm.depends({
  netmask: "0.0.2"
});

Package.on_use(function (api) {
  api.export('netmask');

  api.add_files([
    'server.js'
  ], 'server');
});