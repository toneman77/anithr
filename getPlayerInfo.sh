#!/bin/bash 
#gives us USERID, PASSW and KONGURL
source $HOME/scripts/kong.auth

TMP=$(mktemp).json
PLAYERID=$1
# clean our file
curl -s "${KONGURL}getUserProfile&target_user_id=${PLAYERID}" --compressed -o ${TMP}2 && echo -n "."
echo "id,name,level,xp,rare,epic,legs,mythic,arenalvl,crowns,guild,guildid" > /tmp/${PLAYERID}.csv
# jq magic!
jq -r '.user_profile_info | [.user_id, .name, .level, .xp, (.cards_by_rarity| ."2", ."3", ."4", ."5"), .pvp_data.level, .pvp_data.rating, .guild.name, .guild.id |tostring] | join(",")' ${TMP}2 >> /tmp/${PLAYERID}.csv
THENAME="$(jq -r '.user_profile_info | .name' ${TMP}2)"
sleep $[ ( $RANDOM % 5 ) + 1 ]s
echo done
mv /tmp/${PLAYERID}.csv "/mnt/bunker/${THENAME}-${PLAYERID}.csv"
subl "/mnt/bunker/${THENAME}-${PLAYERID}.csv"
rm ${TMP}*
