#!/bin/sh -e

set -x

# Run Ngrok in background
nohup ngrok start -log=stdout -config=/home/ngrok/.ngrok2/ngrok.yml --all &

# Wait for Ngrok to register and then get dynamic address
sleep 2
URL=`curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'`

# Update Tines Agent with URL
echo "Updating Tines Global Resource to $URL"
curl -s -X PUT $TINES_URL/api/v1/global_resources/$TINES_GR_ID -H 'content-type: application/json' -H "x-user-email: $TINES_EMAIL" -H "x-user-token: $TINES_TOKEN" -d "{\"name\": \"$TINES_GR_NAME\", \"value_type\": \"text\", \"value\": \"$URL\"}"

# Monitor background Ngrok service
while sleep 10; do
  ps aux |grep ngrok |grep -q -v grep
  PROCESS_1_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 ]; then
    echo "Ngrok has exited so I will too."
    exit 1
  else
    echo "Ngrok is still running."
  fi
done