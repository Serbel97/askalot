set :domain, 'askalot.fiit.stuba.sk'

server domain, :app, :web, :db, primary: true

set :user,      'deploy'
set :rails_env, 'edx_demo'
set :branch,    'master'

role :db, domain, primary: true
