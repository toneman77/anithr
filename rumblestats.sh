#!/bin/bash 
#gives us USERID, PASSW and KONGURL
source $HOME/scripts/kong.auth

if [[ $1 = "x" ]]
then
    imashell=1
else
    imashell=0
fi
if [[ $imashell = 0 ]]; then
     sleep 53
fi
curl -s "${KONGURL}getGuildWarStatus" --compressed -o /tmp/out.json && \
curl -s "${KONGURL}getRankings&ranking_index=0&ranking_id=event_guild_war" --compressed -o /tmp/rank.json && \
curl -s "${KONGURL}getRankings&ranking_index=1&ranking_id=event_guild_war" --compressed -o /tmp/rankopp.json

FOLD=/mnt/thor/multimedia/stats
ROUND="$(jq -r '.guild_war_matches[] | "Round " + (.id+1|tostring)' /tmp/out.json | sort -nk2 | tail -1)"
weAre=$(jq -r '.guild_war_current_match| .us_name' /tmp/out.json)
theyAre=$(jq -r '.guild_war_current_match| .them_name' /tmp/out.json)
ourPoints=$(jq -r '.guild_war_current_match| .us_kills' /tmp/out.json)
theirPoints=$(jq -r '.guild_war_current_match| .them_kills' /tmp/out.json)
numOurplayers=$(jq -r '.rankings.data[] | .name +" "+ .stat' /tmp/rank.json | wc -l)
numOppplayers=$(jq -r '.rankings.data[] | .name +" "+ .stat' /tmp/rankopp.json | wc -l)
remainingTimeTemp=$(jq '(.guild_war_current_match | .end_time) - .time' /tmp/out.json)
remainingTime="$(date -d@${remainingTimeTemp} -u +%H:%Mh)"
remainingTimeS="$(date -d@${remainingTimeTemp} -u +%H:%M:%S)"
if [[ $numOurplayers = 0 ]]
then
    xnumlad=1
else
    xnumlad=$numOurplayers
fi
ourAverage=$(echo $ourPoints / $xnumlad |bc)
if [[ $numOppplayers = 0 ]]
then
    xnumopp=1
else
    xnumopp=$numOppplayers 
fi
theirAverage=$(echo $theirPoints / $xnumopp |bc)
ourPredict=$(echo "$ourAverage * 50" | bc)
theirPredict=$(echo "$theirAverage *50" | bc)
ROUND=$(echo $ROUND | sed 's/[^0-9]*//g')
if [[ $imashell = 0 ]]; then
    echo ROUND,$ROUND > "${FOLD}/Our-Round ${ROUND}.csv"
    echo $remainingTimeS time left,vs $theyAre >> "${FOLD}/Our-Round ${ROUND}.csv"
    jq -r '.rankings.data[] | .name + "," + .stat' /tmp/rank.json|sort >> "${FOLD}/Our-Round ${ROUND}.csv"
else
    echo "=== MATCH REPORT ==="
    echo Current round $ROUND, $weAre vs $theyAre 
    echo $ourPoints vs $theirPoints points
    echo $numOurplayers vs $numOppplayers players
    echo That\'s a $ourAverage vs $theirAverage average
    echo Approximated outcome is $ourPredict vs $theirPredict 
    echo we have $remainingTime time left
    echo
    echo Previous rounds:
    jq -r '.guild_war_matches[] | "Round " + (.id+1|tostring) +" vs "+ .them_name +": "+ .us_kills +" - "+ .them_kills' /tmp/out.json | sort -k2n
fi
