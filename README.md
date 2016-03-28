Midterm


===

Setup

bundle install
rake db:migrate

===

Run

bundle exec ruby -W0 app/app.rb

to stop the server, ctrl-c currently does not work with eventmachine.

ctrl-z and then kill the process (eg. killall -9 ruby)
