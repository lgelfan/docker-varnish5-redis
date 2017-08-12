#
# This is an example VCL file for Varnish.
#
# Includes sample config for redis vmod. Change host/location values as needed 
#   to public/private/docker host values.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

import vsthrottle;
import redis;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "10.0.1.35";
    .port = "8999";
}

sub vcl_init {
    # VMOD configuration: simple case, keeping up to one Redis connection
    # per Varnish worker thread.
    new db = redis.db(
        location="10.0.1.35:6379",
        type=master,
        connection_timeout=500,
        shared_connections=false,
        max_connections=1);
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    # Redis Simple command execution.
    db.command("SET");
    db.push("testvar");
    db.push("my val 12345");
    db.execute();
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
    #

    db.command("GET");
    db.push("testvar");
    db.execute();
    if (db.reply_is_error()) {
        set resp.http.X-Foo = "vredis error";
    } else {
        set resp.http.X-Foo = db.get_string_reply();
    }

	if (obj.hits > 0) {
		set resp.http.X-Varnish-Cache = "HIT";
	} else {
		set resp.http.X-Varnish-Cache = "MISS";
	}
}
