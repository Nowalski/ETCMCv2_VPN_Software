# ETCMCv2 Shadowbox – Build, Run & API Usage

> **Tip**
> If you use `nvm`, switch to the correct Node version before building:
>
> ```bash
> nvm use
> ```

---

# Build and Run

Shadowbox supports running on **Linux** and **macOS** hosts.

## Node.js App

```bash
task shadowbox:start
```

## Docker Container

```bash
task shadowbox:docker:start
```

---

> [!TIP]
> Some useful commands when working with **Docker images and containers**.

### Debug Image

```bash
docker run --rm -it --entrypoint=sh localhost/etcmcv2/shadowbox
```

### Debug Running Container

```bash
docker exec -it shadowbox sh
```

### Cleanup Dangling Images

```bash
docker rmi $(docker images -f dangling=true -q)
```

---

# Send a Test Request

```bash
curl --insecure https://[::]:8081/TestApiPrefix/server
```

---

# Access Keys Management API

The **ETCMCv2 Server** provides a **REST API for access key management**.

If you know the `apiUrl` of your ETCMCv2 Server (for example):

```
https://1.2.3.4:1234/3pQ4jf6qSr5WVeMO0XOo4z
```

you can directly manage the server’s access keys using HTTP requests.

---

# Find the Server's `apiUrl`

### Deployed with the Installation Script

Run:

```bash
grep "apiUrl" /opt/ETCMCV2/access.txt | cut -d: -f 2-
```

### Deployed with the ETCMCv2 Manager

Check the **Settings tab**.

### Local Deployments from Source

The `apiUrl` is simply:

```
https://[::]:8081/TestApiPrefix
```

---

# API Examples

Replace `$API_URL` with your actual `apiUrl`.

### List Access Keys

```bash
curl --insecure $API_URL/access-keys/
```

### Create an Access Key

```bash
curl --insecure -X POST $API_URL/access-keys
```

### Get an Access Key

Example for **ID 1**:

```bash
curl --insecure $API_URL/access-keys/1
```

### Rename an Access Key

```bash
curl --insecure -X PUT -F 'name=albion' $API_URL/access-keys/2/name
```

### Remove an Access Key

```bash
curl --insecure -X DELETE $API_URL/access-keys/1
```

---

# Data Limits for Access Keys

### Set a Data Limit for All Access Keys

Example: limit outbound data transfer access keys to **1 MB over 30 days**

```bash
curl --insecure -X PUT \
-H "Content-Type: application/json" \
-d '{"limit": {"bytes": 1000}}' \
$API_URL/server/access-key-data-limit
```

### Remove the Access Key Data Limit

```bash
curl --insecure -X DELETE $API_URL/server/access-key-data-limit
```

---

# Further Options

Consult the **OpenAPI specification and documentation** for more available options.

---

# Testing

## Manual Testing

Build and run your image with:

```bash
task shadowbox:docker:start
```

---

## Integration Test

The integration test will **build and run the image** and execute a set of automated tests.

```bash
task shadowbox:integration_test
```

### What the Integration Test Does

1. Sets up **three containers**

   * client
   * shadowbox
   * target

2. Creates **two Docker networks**

3. Creates a **user on the shadowbox server**

4. Connects to the target through shadowbox using a **Shadowsocks client**

```
client <-> shadowbox <-> target
```

---

# Testing Changes to the Server Config

If your change introduces **new fields in the server config which are needed at server start-up time**, you may need to remove the existing test configuration.

### Delete Existing Config

```bash
rm /tmp/ETCMCV2/persisted-state/shadowbox_server_config.json
```

### Manual Editing

You may need to edit the JSON string inside:

```
src/shadowbox/Taskfile.yml
```
