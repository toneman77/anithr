#!/bin/bash 
#gives us USERID, PASSW and KONGURL
source $HOME/scripts/kong.auth

# our list and points:
curl -s "${KONGURL}getRankings&ranking_index=0&ranking_id=event_guild_siege" --compressed -o /tmp/ourlist.json && echo "."
# their list and points:
curl -s "${KONGURL}getRankings&ranking_index=1&ranking_id=event_guild_siege" --compressed -o /tmp/theirlist.json && echo "."

# island overview: 
curl -s "getGuildSiegeStatus" --compressed -o /tmp/islands.json && echo "."


# our attacks
echo "#### our attacks ####"
jq -r '.rankings.data[]| .name +","+ (.stat|tostring) +","+ (.matches_played|tostring)' /tmp/ourlist.json
OURREST=$(jq -r '.rankings.data[]| .name +","+ (.stat|tostring) +","+ (.matches_played|tostring)' /tmp/ourlist.json | awk '{split($0,a,","); sum += a[3]} END {print 500-sum}')
echo

# their attacks
echo "#### their attacks ####"
jq -r '.rankings.data[]| .name +","+ (.stat|tostring) +","+ (.matches_played|tostring)' /tmp/theirlist.json
THEIRREST=$(jq -r '.rankings.data[]| .name +","+ (.stat|tostring) +","+ (.matches_played|tostring)' /tmp/theirlist.json | awk '{split($0,a,","); sum += a[3]} END {print 500-sum}')
echo

# report
# our islands
# doesnt work anymore. kong changed sth
echo "#### our islands ####"
jq -r '.guild_siege_status.locations[] | .data.name +","+ .hp' /tmp/islands.json 
echo

#their islands
echo "#### their islands ####"
jq -r '.guild_siege_status.enemy_locations[] | .data.name +","+ .hp' /tmp/islands.json 
echo 

# result
echo "#### POINTS ####"
jq -r '.guild_siege_status | (.points|tostring) +" vs "+ (.enemy_points|tostring)' /tmp/islands.json 

# remaining fights
echo "#### remaining attacks ####"
echo "${OURREST} vs ${THEIRREST}"
echo
date
