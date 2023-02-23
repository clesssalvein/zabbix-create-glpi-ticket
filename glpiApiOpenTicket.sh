#!/bin/bash

#####
#
# Creating glpi ticket when a trigger in zabbix is triggered
# by @ClessAlvein
#
#####


# VARS

# utils
echo=`which echo`
awk=`which awk`
sed=`which sed`

# glpi api path
glpiApiPath="http://192.168.199.238/apirest.php"

# glpi user "zabbix" token
userToken="j***O"

# api app "zabbix" token
appToken="Z***9"

# zabbix alert vars
# $1 - recipient
# $2 - topic
# $3 - message body
ticketName=${2}
ticketMessage=${3}


# SCRIPT START

# get glpi session_token
sessionToken=`curl -s -X GET \
-H 'Content-Type: application/json' \
-H "Authorization: user_token ${userToken}" \
-H "App-Token: ${appToken}" \
"${glpiApiPath}/initSession" \
| jq -r '.session_token'`;

# getting eventId from message body
eventId=`${echo} -e ${ticketMessage} | ${awk} '/EventID/{print $2}'`

# getting eventSeverity from message body
eventSeverity=`${echo} -e ${ticketMessage} | ${awk} -F": " '/Приоритет заявки/{print $2}'`

# zabbix severity has numeration 0-5. glpi severity has numeration 1-6. encrease zabbix's severity +1
eventSeverity=`echo $[${eventSeverity} + 1]`

# getting entityID from message body (it's in the Tag field of zabbix's host)
entityId=`${echo} -e ${ticketMessage} | ${awk} -F": " '/ID отдела организации в GLPI/{print $2}'`

# getting TriggerID from message body
triggerId=`${echo} -e ${ticketMessage} | ${awk} -F": " '/TriggerID/{print $2}'`


# Searching already created Ticket wit the same triggerID
# if there's a ticket with the same triggerID - we won't open new ticket, but ad followup to the already existed ticket

# searching ticket with triggerID that already exist with status "Not closed"
# put founded ticketID to array arrayOpenTicketIds
arrayOpenTicketIds=( $(curl -s -X GET -H 'Content-Type: application/json' -H "Session-Token: ${sessionToken}" \
    -H "App-Token: ${appToken}" "${glpiApiPath}/Ticket?searchText\[content\]=TriggerID:%20${triggerId}&searchText\[status\]=[1-5]" \
    | jq -r '.[]' | jq -r '.id') );

# if the array arrayOpenTicketIds is NOT empty
if ! [[ ${#arrayOpenTicketIds[@]} -eq 0 ]]; then
    # for each ticketID from array add followup to the ticket with this ticketID
    for openedTicketId in "${arrayOpenTicketIds[@]}";
    do
        curl -s -X POST -H 'Content-Type: application/json' -H "Session-Token: ${sessionToken}" \
            -H "App-Token: ${appToken}" -d '{"input": {"tickets_id": "'"${openedTicketId}"'", "content": "'"${ticketMessage}"'"}}' \
            "${glpiApiPath}/Ticket/${openedTicketId}/TicketFollowup";
        echo "$openedTicketId";
    done;
else
    # if there's no tickets with this ticketID
    # add new ticket
    curl -s -X POST -H 'Content-Type: application/json' -H "Session-Token: ${sessionToken}" -H "App-Token: ${appToken}" \
        -d '{"input": {"entities_id": "'"${entityId}"'","name": "'"${ticketName}"'","content": "'"${ticketMessage}"'","status": "2","priority": "'"${eventSeverity}"'"}}' \
        "${glpiApiPath}/Ticket/"
fi

# kill glpi API session
curl -s -X GET \
-H 'Content-Type: application/json' \
-H "Session-Token: ${sessionToken}" \
-H "App-Token: ${appToken}" \
"${glpiApiPath}/killSession";
