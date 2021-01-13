#!/bin/sh -e

set -x

AUTH=`echo -n "$AUTH_USERNAME:$AUTH_PASSWORD" | base64`

sed -i "s/auth:.*/auth: \"$AUTH_USERNAME:$AUTH_PASSWORD\"/" /home/ngrok/.ngrok2/ngrok.yml
sed -i "s/authtoken:.*/authtoken: $NGROK_AUTHTOKEN/" /home/ngrok/.ngrok2/ngrok.yml
sed -i "s/    addr:.*/    addr: $NGROK_ADDR/" /home/ngrok/.ngrok2/ngrok.yml

# Run Ngrok in background
nohup ngrok start -log=stdout -config=/home/ngrok/.ngrok2/ngrok.yml --all &

# Wait for Ngrok to register and then get dynamic address
sleep 2
URL=`curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'`

# Update Tines Agent with URL
echo "Updating Tines Global Resource to $URL"
curl -s -X PUT $TINES_URL/api/v1/global_resources/$TINES_GR_ID -H 'content-type: application/json' -H "x-user-email: $TINES_EMAIL" -H "x-user-token: $TINES_TOKEN" -d "{\"name\": \"$TINES_GR_NAME\", \"value_type\": \"json\", \"value\": {\"url\": \"$URL\", \"credential\": \"$AUTH\"}}"

# Monitor background Ngrok service
while sleep 10; do
  ps aux |grep ngrok |grep -q -v grep
  PROCESS_1_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  if [ $PROCESS_1_STATUS -ne 0 ]; then
    echo "Ngrok has exited so I will too."
    exit 1
  else
    echo "Ngrok is still running."
  fi
done
