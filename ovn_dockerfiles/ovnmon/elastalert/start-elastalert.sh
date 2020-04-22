#!/bin/bash -e

# Elastalert should not be running with a PROXY server.
unset https_proxy
unset http_proxy
unset HTTPS_PROXY
unset HTTP_PROXY

# if an elastalert index override was specified, then use it
if [[ -n "${ELASTALERT_INDEX:-}" ]]
then
   indexname="${ELASTALERT_INDEX}"
else
   indexname="elastalert_status"
fi

# Set the timezone.
if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
	unlink /etc/localtime
	ln -s /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
	echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
	echo "Container timezone not modified"
fi

if [[ -n "${ELASTICSEARCH_USERNAME:-}" ]]
then
	flags="--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}"
else
	flags=""
fi

#Set Elasticsearch secure mode
if [ "$ELASTICSEARCH_SECURE" = "true" ]; then
   if ! curl -f $flags https://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT} --cert /etc/elasticsearch/elasticsearch_client_cert.pem --cacert /etc/elasticsearch/elasticsearch_client_ca_cert.pem --key /etc/elasticsearch/elasticsearch_client_key.pem  >/dev/null 2>&1
   then
	  echo "Elasticsearch not available at https://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}"
	  echo 'Try again later?'
	  exit 1
   else
	  if ! curl -f $flags https://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/$indexname --cert /etc/elasticsearch/elasticsearch_client_cert.pem --cacert /etc/elasticsearch/elasticsearch_client_ca_cert.pem --key /etc/elasticsearch/elasticsearch_client_key.pem >/dev/null 2>&1
	  then
		 echo "Creating Elastalert index ($indexname) in Elasticsearch..."
	     elastalert-create-index  --ssl --verify-certs --index $indexname --old-index ""
	     echo "Done creating elastalert index ($indexname) in Elasticsearch..."
	  else
	     echo "Elastalert index ${indexname} already exists in Elasticsearch."
	  fi
   fi
else
   if ! curl -f $flags ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT} >/dev/null 2>&1
   then
   	 echo "Elasticsearch not available at ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}"
   	 echo 'Try again later?'
   	 exit 1
   else
   	 if ! curl -f $flags ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/$indexname >/dev/null 2>&1
   	 then
   		echo "Creating Elastalert index ($indexname) in Elasticsearch..."
   	    elastalert-create-index --index $indexname --old-index ""
   	    echo "Done creating elastalert index ($indexname) in Elasticsearch..."
   	 else
   	    echo "Elastalert index ${indexname} already exists in Elasticsearch."
   	 fi
   fi
fi

exec "$@"