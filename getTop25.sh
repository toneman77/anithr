#!/bin/bash 
#gives us USERID, PASSW and KONGURL
source $HOME/scripts/kong.auth
# rumble number + 50000, so this is rumble number 12
curl -s "${KONGURL}getRankings&ranking_id=event&ranking_index=50012" --compressed -o /tmp/rumbleranks.json
echo "rank,name,points,factionid"
jq -r '.rankings.data[] | [.rank, .name, .stat, .faction_id] | @csv' /tmp/rumranks.json
