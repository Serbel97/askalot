set :domain, 'askalot.fiit.stuba.sk'

server domain, :app, :web, :db, primary: true

set :user,      'deploy'
set :rails_env, 'demo_mooc'
set :branch,    'gama'

role :db, domain, primary: true
