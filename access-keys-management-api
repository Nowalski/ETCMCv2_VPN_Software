Tip

If you use nvm, switch to the correct Node version with nvm use.

Build and Run:

Shadowbox supports running on linux and macOS hosts.

Node.js App

task shadowbox:start
Docker Container

task shadowbox:docker:start
[!TIP] Some useful commands when working with Docker images and containers:

Debug Image:

docker run --rm -it --entrypoint=sh localhost/etcmcv2/shadowbox
Debug Running Container:

docker exec -it shadowbox sh
Cleanup Dangling Images:

docker rmi $(docker images -f dangling=true -q)
Send a Test Request

curl --insecure https://[::]:8081/TestApiPrefix/server
Access Keys Management API
The ETCMCV2 Server provides a REST API for access key management. If you know the apiUrl of your ETCMCV2 Server (e.g. https://1.2.3.4:1234/3pQ4jf6qSr5WVeMO0XOo4z), you can directly manage the server's access keys using HTTP requests:

Find the Server's apiUrl:

Deployed with the Installation Script: Run grep "apiUrl" /opt/ETCMCV2/access.txt | cut -d: -f 2-

Deployed with the ETCMCV2 Manager: Check the "Settings" tab.

Local Deployments from Source: The apiUrl is simply https://[::]:8081/TestApiPrefix

API Examples:

Replace $API_URL with your actual apiUrl.

List access keys: curl --insecure $API_URL/access-keys/

Create an access key: curl --insecure -X POST $API_URL/access-keys

Get an access key (e.g. ID 1): curl --insecure $API_URL/access-keys/1

Rename an access key: curl --insecure -X PUT -F 'name=albion' $API_URL/access-keys/2/name

Remove an access key: curl --insecure -X DELETE $API_URL/access-keys/1

Set a data limit for all access keys: (e.g. limit outbound data transfer access keys to 1MB over 30 days) curl --insecure -X PUT -H "Content-Type: application/json" -d '{"limit": {"bytes": 1000}}' $API_URL/server/access-key-data-limit

Remove the access key data limit: curl --insecure -X DELETE $API_URL/server/access-key-data-limit

And more...

Further Options:

Consult the OpenAPI spec and documentation for more options.

Testing
Manual
Build and run your image with:

task shadowbox:docker:start
Integration Test
The integration test will not only build and run your image, but also run a number of automated tests.

task shadowbox:integration_test
This does the following:

Sets up three containers (client, shadowbox, target) and two networks.
Creates a user on shadowbox.
Connects to target through shadowbox using a Shadowsocks client: client <-> shadowbox <-> target
Testing Changes to the Server Config:
If your change includes new fields in the server config which are needed at server start-up time, then you mey need to remove the pre-existing test config:

Delete Existing Config: rm /tmp/ETCMCV2/persisted-state/shadowbox_server_config.json

Manually Edit: You'll need to edit the JSON string within src/shadowbox/Taskfile.yml.
