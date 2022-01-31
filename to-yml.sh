#! /bin/bash

echo "channels:"
jq -r $'.[]
| {names: [.services[].name], type, channel, sids: [.services[].sid]}
|
"  - name: \'" + if (.names | unique | length) == 1 then (.names[0]) else (.names | join(" / ")) end + "\'",
"    type: \'" + .type + "\'",
"    channel: \'" + .channel +  "\'",
"    # services: " + (.sids | tostring), ""
'
