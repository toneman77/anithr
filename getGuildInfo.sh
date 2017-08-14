#!/bin/bash 
#gives us USERID, PASSW and KONGURL
source $HOME/scripts/kong.auth

TMP=$(mktemp).json
curl -s "${KONGURL}updateGuild" --compressed -o "${TMP}" && echo -n "."
jq -r '.faction.members[] | .name +","+ .user_id' ${TMP} > /tmp/g.csv

# clean our file
# put in csv header
echo "id,name,level,xp,rare,epic,legs,mythic" > /tmp/x.csv 

# magic!
# you can omit that if you only want the players
for i in $(sed "s/.*,//" /tmp/g.csv)
do
    # get user info
    curl -s "${KONGURL}getUserProfile&target_user_id=${i}" --compressed -o ${TMP}2 && echo -n "."
    # jq magic!
    jq -r '.user_profile_info | [.user_id, .name, .level, .xp, (.cards_by_rarity| ."2", ."3", ."4", ."5")|tostring] | join(",")' ${TMP}2 >> /tmp/x.csv
    # dont let them see that this is automated!
    sleep $[ ( $RANDOM % 5 ) + 1 ]s
done
sed -i "s/null/0/g" /tmp/x.csv
echo done
# subl /tmp/x.csv 
# we clean up
rm g.csv
rm ${TMP}*
