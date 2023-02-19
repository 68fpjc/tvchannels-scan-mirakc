#! /bin/sh

{
  echo "resource:"
  echo "  logos:"
  jq -r '.[]
  | {type: .type, channel: .channel, service: .services[]}
  | [
      .type,
      .channel,
      .service.name,
      (.service.nid | tostring),
      (.service.tsid | tostring),
      (.service.sid | tostring),
      (.service.logoId | tostring)
    ]
  | join(" ")' \
  | while read TYPE CHANNEL NAME NID TSID SID LOGOID ; do
    echo -n ${TYPE} ${CHANNEL} ${NID} ${TSID} ${SID} ${LOGOID} >&2
    {
      RESULT=$(cat logos/*.json \
      | jq ".[] | select(.type == 0 and .services? != null)
        | {type: .type, id: .id, version: .version, data: .data, service: .services[]}
        | select(.service.nid == ${NID} and .service.tsid == ${TSID} and .service.sid == ${SID})")
    }
    [ -z "${RESULT}" ] && {
      RESULT=$(cat logos/*.json \
      | jq ".[] | select(.type == 0 and .services? == null and .id == ${LOGOID} and .nid == ${NID})")
    }
    if [ -n "${RESULT}" ] ; then
      echo " ... OK" >&2
      echo "      # ${NAME}"
      # modified for mirakc v2
      # echo "    - service-triple: [${NID}, ${TSID}, ${SID}]"
      echo "    - service-id: $(expr ${NID} '*' 100000 '+' ${SID})"
      echo "      image: /var/lib/mirakc/logos/${NID}-${TSID}-${SID}.png"
      echo
      echo "${RESULT}" | jq -r '.data' | cut -d ',' -f 2 | base64 -d >logos/${NID}-${TSID}-${SID}.png
    else
      echo >&2
    fi
  done
} >logos/logos-mirakc.yml
