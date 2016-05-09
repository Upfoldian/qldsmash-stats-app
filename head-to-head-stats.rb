require 'json'
require 'date'

module Stats
	def self.getStats(targetPlayer, otherPlayers, playerResults)
		matchHistory = {}
		statsStr = ""
		targetPlayerResults = playerResults.select{|player| player['playerName'].downcase == targetPlayer.downcase}[0]
		#puts targetPlayerResults.to_s[0..200]
		#player["resultData"] = player["resultData"].select do |result| 
		#	matchDate = Date.strptime(result["date"], "%Y-%m-%d")
		#	targetDate = Date.strptime("2016-03-01", "%Y-%m-%d")
		#	targetDate < matchDate
		#end
		otherPlayers.each do |otherPlayer|

			matchesAgainst = targetPlayerResults["matches"].select do |name|
				name["opponentName"].downcase == otherPlayer.downcase
			end

			matchHistory[otherPlayer] = matchesAgainst
		end

		puts "#{targetPlayer}, #{matchHistory.keys.to_s}"
		statsStr +=  "==========================================================================================\n"
		matchHistory.each do |name, results|

			results.sort_by {|result| Date.strptime(result["date"], "%Y-%m-%d")}

			if results == []
				statsStr +=  "\t No tournament sets recorded between #{targetPlayer} and #{name}"
				statsStr +=  "\n==========================================================================================\n"
			else
				statsHash = Stats.getStatsHash(name, results)
				statsStr +=  "#{targetPlayer}'s head to head stats against #{name}:\n\n"
				#stats[:results].push {:won => won, :eventName => event, :date => date}

				statsHash[:results].each do |result|

					resultChar = result[:won] == true ? "W" : "L"
					statsStr +=  "\t #{resultChar.ljust(4)} #{result[:eventName].ljust(45)} #{result[:date]}\n"

				end

				statsStr +=  "\n==========================================================================================\n\n"
				statsStr +=  "#{targetPlayer} last played #{name} on #{statsHash[:lastPlayed][:date]} at #{statsHash[:lastPlayed][:eventName]}\n"

				#if stats[:bamStats] == false
				#	statsStr +=  "#{targetPlayer} has not played #{name} at a BAM event on record\n"
				#else
				#	statsStr +=  "#{targetPlayer} has played #{name} at a BAM event #{stats[:lastBamStats].size} times!\n"
				#end
				statsStr +=  "#{targetPlayer} has won #{statsHash[:totalWinPercent]}% of sets against #{name}"
				if statsHash[:last5WinPercent] != false
					statsStr +=  ", however in their last 5 sets, #{targetPlayer} has won #{statsHash[:last5WinPercent]}% of sets\n"
				else 
					statsStr += "\n"
				end
				#statsStr += "#{targetPlayer} net elo against #{name} is #{statsHash[:netElo]}"
				statsStr += Stats.getFunStats(name)
				statsStr +=  "\n==========================================================================================\n\n"
			end

		end
		
		return statsStr
	end

	def self.getStatsHash(playerName, results)
		stats = {:lastPlayed => {:date => "", :eventName => ""}, :results => [], :bamStats => [], :last5WinPercent => false, :totalWinPercent => 0, :netElo => 0}

		stats[:lastPlayed] = {:date => results[0]['date'], :eventName => results[0]['tournamentName']}
		if (results.size > 5)
			wins = 0 
			losses = 0

			results[0..4].each do |last5| 
				if last5['win'] == "true" 
					wins += 1 
				else 
					losses += 1
				end
			end
			stats[:last5WinPercent] = (wins / (losses+wins*1.0)*100).round(2)

		end

		netElo = 0
		wins = 0 
		losses = 0

		results.each do |result|

			won = (result['win'] == "true" ? true : false)
			event = result['tournamentName'].strip
			date = result['date']
			eloChange = result['eloChange']

			event = event.size > 43 ? event[0..40]+"..." : event
			won ? wins += 1 : losses += 1
			netElo += eloChange
			won == true ? netElo += eloChange : netElo -= eloChange

			stats[:results].push ({:won => won, :eventName => event, :date => date})
			#stats[:bamStats].push({:won => resultStr, :event => event}) unless event.match("BAM") == nil

		end
		stats[:totalWinPercent] = (wins / (losses + wins * 1.0 ) *100 ).round(2)
		stats[:netElo] = netElo
		
		return stats
	end

	def self.getFunStats(name)
		funStatsStr = "\n"
		nameTest = name.downcase


		if nameTest == "scarpian" 
			funStatsStr += "#{name} is the nicest and fairest player, with 3207 elo in that category!\n"
			funStatsStr += "#{name} has placed 1st in the 'Biggest Homie' event at SGT 27 times running!\n"
			funStatsStr += "<a href='\hat'>#{name}'s hat</a> has won the most money matches on record, with 297 wins!\n"
			funStatsStr += "\nSorry for being a dingus scarp :|\n"
		elsif nameTest == "killy"
			funStatsStr += "#{name} has noticed 1 kouhai!\n"
			funStatsStr += "#{name} has worn a beanie to 33 different events!\n"
			funStatsStr += "#{name}'s smile is worth $3\n"
		elsif nameTest == "mm"
			funStatsStr += "#{name} has mastered 13 different meteors!\n"
			funStatsStr += "#{name} has consumed 532 litres of coke at smash events!\n"
		elsif nameTest == "kira"
			funStatsStr += "#{name} has SDed 704 stocks at smash events!\n"
			funStatsStr += "#{name} has caused 403 turned heads while walking at smash events!\n"
			funStatsStr += "#{name} has crushed the souls of 54 different players in pools!\n"
		elsif nameTest == "lunacy"
			funStatsStr += "#{name} has been noticed by senpai!\n"
			funStatsStr += "#{name} has baked 21 cakes at GCT!\n"
			funStatsStr += "#{name} has chased Boundaries 30 times!\n"
		elsif nameTest =="eval"
			funStatsStr += "#{name} has said \"you need to calm down\" 258 times!\n"
			funStatsStr += "#{name} has been playing with Robin for 712 hours!\n"
			funStatsStr += "#{name} has cursed Nana 23,117 times!\n"
		elsif nameTest == "saucydancer"
			funStatsStr += "#{name} has admired Mewtwo's tail 8031 times!\n"
			funStatsStr += "#{name} has naired 4,903,888 times in tournament sets!\n"
			funStatsStr += "#{name} has said \"deadset\" at tournaments 4932 times!\n"
		else
			funStatsStr += ""
		end
		return funStatsStr
	end

end