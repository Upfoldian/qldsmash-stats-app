require 'json'
require 'sinatra'
require 'cgi'
require 'sanitize'

require './head-to-head-stats.rb'

#set :bind '0.0.0.0'


class StatsApp < Sinatra::Base
	results = JSON.parse(File.read('newFormat-SSBU.json'), quirks_mode: true)
	results = results["players"]

	get '/' do 
		erb :index
	end

	post '/' do 
		targetPlayer = params[:targetPlayer].gsub(" ", "%20")
		otherPlayers = params[:otherPlayers].split(',').map{|x| x.strip.gsub(" ", "%20")}
		playerNames = [targetPlayer] + otherPlayers
		redir = "/players=#{playerNames.join(',')}"
		redirect to(redir)
	end

	get '/about' do
		erb :about
	end


	get '/players=*' do
		begin
			players = params[:splat][0]
			players = players.split ','
			targetPlayer = Sanitize.clean(players[0])
			otherPlayers = players[1..-1].map{|x| Sanitize.clean(x.strip)}
			playerNames = [targetPlayer] + otherPlayers
			playerNames = playerNames.map{|x| x.downcase}
			playerResults = results.select {|player| playerNames.include? player['playerName'].downcase}
			statString = Stats.getStats(targetPlayer, otherPlayers, playerResults)
			statsString =  CGI.escapeHTML(statString)
			erb :displayStats, :locals =>	{:stats => statString}
		rescue
			redirect '/blargh'
		end
	end
	
	post '/players=*' do
		redirect to('/')
	end
	
	get '/blargh' do
		erb :blargh
	end
end