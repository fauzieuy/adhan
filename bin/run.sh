#!/usr/bin/env bash

nohup bundle exec sidekiq -q adhan -r ./lib/adhan/job/schedule.rb > ./log/sidekiq.log &
sleep 2
source ${HOME}/.rvm/environments/ruby-2.5.1
nohup ruby ./run.rb > ./log/run.log &
