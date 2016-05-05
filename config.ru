require 'sinatra'
require 'json'
require 'cgi'
require 'sanitize'

require File.expand_path '../routes.rb', __FILE__

run StatsApp