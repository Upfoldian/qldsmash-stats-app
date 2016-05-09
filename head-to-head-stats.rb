require 'json'
require 'date'

module Stats
	def self.getStats(targetPlayer, otherPlayers, playerResults)
		matchHistory = {}
		statsStr = ""
		puts "stats: #{targetPlayer}, #{otherPlayers}"
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

		puts matchHistory.keys
		stats = {:lastPlayed => {:date => "", :eventName => ""}, :lastBamStats => [], :last5WinPercent => 0, :totalWinPercent => 0}
		statsStr +=  "==========================================================================================\n"
		matchHistory.each do |name, results|

			if results == []
				statsStr +=  "\t No tournament sets recorded between #{targetPlayer} and #{name}"
				statsStr +=  "\n==========================================================================================\n"
			else
				statsStr +=  "#{targetPlayer}'s head to head stats against #{name}:\n\n"


				wins = 0
				losses = 0
				results.sort_by {|result| Date.strptime(result["date"], "%Y-%m-%d")}

				results[0..4].each do |last5|
					if last5['win'] == "true"
						wins+=1
					else
						losses+=1
					end
				end

				stats[:last5WinPercent] = (wins / (losses+wins*1.0)*100).round(2)

				wins = 0
				losses = 0

				results.each do |result|
					resultStr = ""
					if result['win'] == "true"
						wins+=1
						resultStr = "W"
					else
						losses+=1
						resultStr = "L"
					end
					result['tournamentName'] = result['tournamentName'].strip
					if result['tournamentName'].size > 40
						result['tournamentName'] = result['tournamentName'][0..40] + "..."
					end
					
					statsStr +=  "\t #{resultStr.ljust(4)} #{result['tournamentName'].ljust(45)} #{result['date']}\n"

					

					if result['tournamentName'].match("BAM")
						resultStr = result['win'] == "true" ? "W" : "L"
						stats[:lastBamStats] = stats[:lastBamStats].push({:won => resultStr})
					end


				end
				stats[:lastPlayed] = {:date => results[0]['date'], :eventName => results[0]['tournamentName']}
				stats[:totalWinPercent] = (wins/(wins+losses*1.0)*100).round(2)

				statsStr +=  "\n==========================================================================================\n\n"
				statsStr +=  "#{targetPlayer} last played #{name} on #{stats[:lastPlayed][:date]} at #{stats[:lastPlayed][:eventName]}\n"

				if stats[:lastBamStats] == []
					statsStr +=  "#{targetPlayer} has not played #{name} at a BAM event on record\n"
				else
					statsStr +=  "#{targetPlayer} has played #{name} at a BAM event #{stats[:lastBamStats].size} times!\n"
				end

				statsStr +=  "#{targetPlayer} has won #{stats[:totalWinPercent]}% of sets against #{name}, however in their last 5 sets, #{targetPlayer} has won #{stats[:last5WinPercent]}% of sets\n"
				if name.downcase == "scarpian" 
					statsStr += "Scarpian is the nicest and fairest player, with 3207 elo in that category!\n"
					statsStr += "Scarpian has placed 1st in the 'Biggest Homie' event at SGT 27 times running!\n"
					statsStr += "<a href='\hat'>Scarpian's hat</a> has won the most money matches on record, with 297 wins!\n"
					statsStr += "\nSorry for being a dingus scarp :|\n"
				end
				statsStr +=  "\n==========================================================================================\n\n"
			end

		end
		
		return statsStr
	end
end