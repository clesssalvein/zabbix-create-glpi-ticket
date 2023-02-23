# Description

Creating tickets in GLPI when a trigger in Zabbix is triggered with Shell script via GLPI API.

# Prerequisites

## GLPI 9.3.x

- Create user **zabbix** (with right to add tickets and followup into tickets) and get its API key
- Enable API, Create API App **zabbix**, and get its API key

## Zabbix 4.x at Centos 7

- Install utils

```
yum install awk sed curl jq
```

- Create script, app permissions and put into it contents of the **glpiApiOpenTicket.sh** file

```
nano /usr/lib/zabbix/alertscripts
```

```
chmod +x /usr/lib/zabbix/alertscripts
```

- Add Media type **glpiApiOpenTicket** with script **glpiApiOpenTicket.sh**

- Create action **Create GLPI Ticket** with Send messages via Media type **glpiApiOpenTicket** in **Operations** and **Recovery operations**
