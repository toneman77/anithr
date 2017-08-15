#!/bin/bash 
#gives us USERID, PASSW and KONGURL
source "${HOME}/scripts/kong.auth"

# order in real life AT
# getHuntingTargets
# getRankingUser
# startHuntingBattle
# playCard

# peter 1001, stan 2002, bob 3001, roger 2001
# brian 1003, steve 2003, consuela 1004, ricky 2005
# gene 3004, zapp 5019
iWant=( 1001 2002 3001 2001 1003 2003 1004 2005 3004 5019 )

# do we have loot crates?
curl -s "${KONGURL}init" -o /tmp/ar.json
numCrates=$(jq -r '.user_items."30002".number' /tmp/ar.json)
while [[ $numCrates -gt 0 ]]
do
    curl -s "${KONGURL}useAdLockedItem&item_id=30002" -o /dev/null
    echo -n "loot crate opened, "
    ((numCrates--))
    sleep 5
done
echo

# how much arena energy?
curl -s "${KONGURL}getUserAccount" -o /tmp/ar.json
remainingBattles=$(jq -r ".user_data.stamina" /tmp/ar.json)
numLoops=$remainingBattles
echo "remaining arena battles: ${numLoops}"

# the loop
for (( i=1; i<=numLoops; i++ ))
do
    # get our initial opp
    sleep 2
    curl -s "${KONGURL}getHuntingTargets" --compressed -o /tmp/ar.json
    currOpp=$(jq -r ".hunting_targets[] | .commander.unit_id" /tmp/ar.json) || exit 77
    sleep 0.2
    curl -s "${KONGURL}getRankings" -o /dev/null
    oppUserId=$(jq -r ".hunting_targets[].user_id" /tmp/ar.json)
    echo -n ", currOpp is $currOpp"

    # start arena battle!
    curl -s "${KONGURL}startHuntingBattle&target_user_id=${oppUserId}" -o /tmp/ar.json
    # remainingbattles=$(jq -r ".user_data.stamina" /tmp/ar.json)
    # echo $remainingbattles remaining battles

    # may we battle
    # if [[ ${remainingbattles} = 0 ]]
    # then
    #     exit
    # fi

    # one that we want?
    sleep 4
    if [[ " ${iWant[@]} " =~ " ${currOpp} " ]]
    then
        # play that match!
        echo -n ", PLAY"
        curl -s "${KONGURL}setUserFlag&flag=autopilot&value=1" -o /dev/null
        sleep 1
        curl -s "${KONGURL}playCard&skip=true" --compressed -o /tmp/ar.json
        gold=$(jq -r '.battle_data.rewards."0".gold' /tmp/ar.json)
        points=$(jq -r '.battle_data.rewards."0".event_points' /tmp/ar.json)
        echo -n ", $gold gold, $points event points"
    else
        # skip right over!
        echo -n ", FORFEIT"
        curl -s "${KONGURL}forfeitBattle" --compressed -o /tmp/ar.json
    fi
    sleep 1

    # turn autobattle off
    curl -s "${KONGURL}setUserFlag&flag=autopilot&value=0" -o /dev/null
    # next rival is
    # oppuserid=$(jq -r ".hunting_targets[].user_id" /tmp/ar.json)
    echo "."

done

exit
logger "[TONE] played $i arenas"
