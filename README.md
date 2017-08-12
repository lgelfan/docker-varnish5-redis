# docker-varnish5-redis
Docker Varnish 5 container with redis and official Varnish vmods support

## Description:
Includes sample config for redis vmod. Change host/location values as needed to public/private/docker host values.

Stock Varnish Modules provide:

- Simpler handling of HTTP cookies
- Variable support
- Request and bandwidth throttling
- Modify and change complex HTTP headers
- 3.0-style saint mode,
- Advanced cache invalidations, and more.
- Client request body access

Redis VMOD by [carlosabalde/libvmod-redis](https://github.com/carlosabalde/libvmod-redis)

### Usage:

- build image, .e.g.:
`docker build -t varnish5:develop .`

- run image, e.g.:
```
docker run --rm --name varnish -p 6081:6081 \
  -v $(pwd)/default.vcl:/etc/varnish/default.vcl:ro \
  --link=web --link=redis \
  varnish5:develop
```
This will link local default.vcl file so you can work on the vcl file. Rebuild image to bake-in updated vcl file if desired.
Restart image after making updates to config. Assumes you have a backend service named "web" and redis container "redis".

### VMODS
- redis and throttle are enabled

This will test stability of image build to make sure it starts ok. And it's also the two primary ones I use :)

- To add/remove VMODs, see `import` statement in default.vcl.

Sample config included to test throttle (by IP) and read/write redis, adjust host values to match your environment. See link below for docs.


### References:
- https://github.com/varnish/varnish-modules
- https://github.com/carlosabalde/libvmod-redis
- https://github.com/redis/hiredis

### Notes:
Uses Ubuntu 16.04 image without build tools. VMODS were built in a separate container and binaries copied here to save space and build time. 
This creates some dependencies so ymmv for Varnish > 5.1.

I did not have great luck building on Alpine end-to-end, but may revisit.

### demo:
To use the sample default.vcl config, set up a Docker Compose file or start the 2 services + Varnish via:
- `docker run --name=web nginx:1.12-alpine`
- `docker run --name=redis -d redis:3.2-alpine`
- varnish (see above)
