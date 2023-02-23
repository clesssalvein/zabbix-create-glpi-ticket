# Description

Creating tickets in GLPI (via GLPI API) when a trigger in Zabbix is triggered with Shell script.

# Prerequisites

## GLPI 9.3.x

- Create user **zabbix** (with right to add tickets and followup into tickets) and get its API key
- Enable API, Create API App **zabbix**, and get its API key

## Zabbix 4.x at Centos 7

- Install utils

```
yum install awk sed curl jq
```

- Create script, add permissions and put contents of the **glpiApiOpenTicket.sh** file into it

```
nano /usr/lib/zabbix/alertscripts
```

```
chmod +x /usr/lib/zabbix/alertscripts
```
- Edit script **glpiApiOpenTicket.sh** variables

- Add Media type **glpiApiOpenTicket** with script **glpiApiOpenTicket.sh**

- Create action **Create GLPI Ticket** with Send messages via Media type **glpiApiOpenTicket** in **Operations** and **Recovery operations**

- When the trigger triggered there will be created Ticket in GLPI, when the trigger problem will become OK status - there will be created a followup in the ticket
