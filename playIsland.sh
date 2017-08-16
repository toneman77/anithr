#!/bin/bash 
#gives us USERID, PASSW and KONGURL
source $HOME/scripts/kong.auth

# remaining energy
curl -s "${KONGURL}getUserAccount" --compressed -o /tmp/ax.json
myEner=$(jq -r ".user_data.energy" /tmp/ax.json)

#remaining matches
numMatches=$((myEner/8))

# do it
for ((i=1; i<=numMatches; i++))
do
    sleep 3
    # 164 is 22-1 only use 8 energy islands!!!
    curl -s "${KONGURL}startMission&mission_id=164" --compressed > /dev/null 2>&1
    sleep 3
    curl -s "${KONGURL}playCard&skip=True" --compressed > /dev/null 2>&1
done
logger "[TONE] played $i adventure matches"
