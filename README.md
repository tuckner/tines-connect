# Tines Connect

Tines Connect is a container for [Ngrok](https://ngrok.com/) which can help provide access to resources that would generally not be internet accessible.

## Install

1. Create an Ngrok account. Find your `authtoken` value.

2. Create a Global Resource in Tines and identify the ID number of the resource.

3. Fill out `environment.txt`.

4. Set the tunnel destination in [ngrok.yml](https://ngrok.com/docs/secure-tunnels/ngrok-agent/reference/config/#tunnel-definitions).

5. Build the container.

```
docker build . --tag tines-connect
```

6. Run the container.

```
docker run --env-file environment.txt --name tines-connect tines-connect 
```
