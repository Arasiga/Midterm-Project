Midterm

===

RubyPad was our Midterm project at the Lighthouse Labs Web Development Bootcamp. This web app allows a group of users to easily collaborate and work on some live code together. Users also have the ability to compile that code and chat amongst each other with our built in chat. 

===

Setup

bundle install
rake db:migrate

===

Run

bundle exec ruby -W0 app/app.rb

to stop the server, ctrl-c currently does not work with eventmachine.

ctrl-z and then kill the process (eg. killall -9 ruby)
