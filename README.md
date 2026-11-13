# Deploy and Host Docker Registry on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/docker?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=docker-registry)

Docker Registry is the open-source server behind private image hosting: you `docker push` images to it and pull them anywhere, the same way you use Docker Hub. This template runs the official registry ([CNCF Distribution](https://distribution.github.io/distribution/)) on Railway behind HTTPS and a password, with images kept on a volume.

This is a community template, not made or supported by Docker, Inc.

## About Hosting Docker Registry

A registry needs HTTPS (Docker refuses plain HTTP to anything but localhost), a login, and storage that survives restarts. Railway's domain gives it HTTPS, and this template adds:

- **Password login** from `REGISTRY_USERNAME` and `REGISTRY_PASSWORD`, set at deploy time
- **Images on a volume** at `/var/lib/registry`
- **Deleting images that frees space:** deletes are enabled, and on every start the registry removes layers no image uses (`GC_ON_START`)
- **Uploads that work behind Railway's proxy:** relative upload URLs, so pushes stay on your https address

**Use it:**

```
docker login <your-domain>.up.railway.app -u admin
docker tag my-app <your-domain>.up.railway.app/my-app:1.0
docker push <your-domain>.up.railway.app/my-app:1.0
```

The password is the service's `REGISTRY_PASSWORD` variable. To deploy an image from it on Railway, create a service from that image and add the same user name and password under the service's **Settings > Source > Private registry credentials** (a Pro plan feature on Railway).

## Common Use Cases

- A private home for the images your CI builds, without Docker Hub's pull limits or paid private repositories
- Images that stay in your own Railway project, next to the services that run them
- A pull-through target for air-gapped or internal tooling

## Dependencies for Docker Registry Hosting

- A Docker, Podman, crane or other OCI client to push and pull

### Deployment Dependencies

- [Distribution (registry) docs](https://distribution.github.io/distribution/)
- [distribution/distribution](https://github.com/distribution/distribution)
- [Template source](https://github.com/two-workspaces/docker-registry)

### Implementation Details

- **Tested on Railway:** PENDING
- **Deleting images:** the registry API deletes by digest, for example `crane delete <domain>/my-app@sha256:…` or `regctl tag delete <domain>/my-app:1.0`. The space comes back at the next start of the service (redeploy or restart).
- **Storage:** images take volume space, and Railway volumes have a plan size: 0.5 GB on Free and Trial, 5 GB on Hobby and 50 GB on Pro, which you can grow in the volume's settings. One small image fits in 0.5 GB; a real registry wants Hobby or above.
- **Memory:** PENDING
- **Image:** `ghcr.io/two-workspaces/docker-registry`, built from this repository's Dockerfile on `registry:3.1.2`, with `apache2-utils` added for the password file.

## Why Deploy Docker Registry on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Docker Registry on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
