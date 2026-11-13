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

- **Tested on Railway:** `docker login`, `docker push` and `docker pull` from GitHub Actions (a 150 MB layer each way in about 10 seconds), and a 537 MB multi-arch image with a 229 MB layer copied in and pulled back intact with crane; anonymous and wrong-password requests get 401; deleting both tags of the 537 MB image and restarting freed its space while the other image still pulled; an upgrade with images on the volume kept them. All at 0.5 GB of memory, with no out-of-memory kills. Deploying a Railway service from the registry wasn't tested: private registry credentials need a Pro plan.
- **Deleting images:** delete the tag, for example `crane delete <domain>/my-app:1.0` (or a digest, `my-app@sha256:…`). On the next start of the service (redeploy or restart), images that no tag points to and their layers are removed, and the space comes back. Turn this off with `GC_ON_START=false` if you keep images by digest only. Multi-arch images keep all their platforms.
- **Storage:** images take volume space, and Railway volumes have a plan size: 0.5 GB on Free and Trial, 5 GB on Hobby and 50 GB on Pro. Hobby and Pro can grow it in the volume's settings, Pro up to 1 TB. One small image fits in 0.5 GB; a real registry wants Hobby or above.
- **Memory:** about 20 MB idle and under 40 MB while pushing; it runs on the Free plan's 0.5 GB. Railway counts the kernel's file cache as memory, and a push showed as 480 MB of it, so the template drops the image store's cache every 15 minutes.
- **Image:** `ghcr.io/two-workspaces/docker-registry`, built from this repository's Dockerfile on `registry:3.1.2`, with `apache2-utils` added for the password file and `python3` for the cache trimmer.

## Why Deploy Docker Registry on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Docker Registry on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
