table solution_redirects {
    "/": "/personal-blog/",
    "/personal-blog": "/personal-blog/",
    "/personal-blog/posts": "/personal-blog/posts/",
    "/personal-blog/contact": "/personal-blog/contact/",
    "/personal-blog/about": "/personal-blog/about/",
    "/sitemap.xml": "/personal-blog/sitemap.xml"
}

table paths_to_block {
    "/test-block": ""
}

sub vcl_recv {
#FASTLY recv

    # Normally, you should consider requests other than GET and HEAD to be uncacheable
    # (to this we add the special FASTLYPURGE method)
    if (req.method != "HEAD" && req.method != "GET" && req.method != "FASTLYPURGE") {
    return(pass);
    }

    # If you are using image optimization, insert the code to enable it here
    # See https://www.fastly.com/documentation/reference/io/ for more information.

    # Add www. to apex hostname and subdomains
    if (!std.prefixof(req.http.host, "www.") && !std.suffixof(req.http.host, "global.ssl.fastly.net")) {
      set req.http.host = "www." + req.http.host;
      error 600 "add_www";
    }

    # redirect home page or /personal-blog
    if (table.contains(solution_redirects, req.url.path)) {
        error 620 "redirect";
    }

    if (table.contains(paths_to_block, req.url.path)) {
        error 621 "block";
    }

    return(lookup);
}

sub vcl_hash {
  set req.hash += req.url;
  set req.hash += req.http.host;
#FASTLY hash
  return(hash);
}

sub vcl_hit {
#FASTLY hit
  return(deliver);
}

sub vcl_miss {
#FASTLY miss
  return(fetch);
}

sub vcl_pass {
#FASTLY pass
  return(pass);
}

sub vcl_fetch {
#FASTLY fetch

  # Unset headers that reduce cacheability for images processed using the Fastly image optimizer
  if (req.http.X-Fastly-Imageopto-Api) {
    unset beresp.http.Set-Cookie;
    unset beresp.http.Vary;
  }

  # Log the number of restarts for debugging purposes
  if (req.restarts > 0) {
    set beresp.http.Fastly-Restarts = req.restarts;
  }

  # If the response is setting a cookie, make sure it is not cached
  if (beresp.http.Set-Cookie) {
    return(pass);
  }

  # By default we set a TTL based on the `Cache-Control` header but we don't parse additional directives
  # like `private` and `no-store`. Private in particular should be respected at the edge:
  if (beresp.http.Cache-Control ~ "(?:private|no-store)") {
    return(pass);
  }

  # If no TTL has been provided in the response headers, set a default
  if (!beresp.http.Expires && !beresp.http.Surrogate-Control ~ "max-age" && !beresp.http.Cache-Control ~ "(?:s-maxage|max-age)") {
    set beresp.ttl = 3600s;

    # Apply a longer default TTL for images processed using Image Optimizer
    if (req.http.X-Fastly-Imageopto-Api) {
      set beresp.ttl = 2592000s; # 30 days
      set beresp.http.Cache-Control = "max-age=2592000, public";
    }
  }

  return(deliver);
}

sub vcl_error {
#FASTLY error

    # Add www. to apex hostname and subdomains
    if (obj.status == 600 && obj.response == "add_www") {
      set obj.status = 308; # Or use 307 for temporary
      set obj.response = "Permanent redirect";
      set obj.http.Location = req.protocol + "://" req.http.host + req.url;
      synthetic {""};
      return (deliver);
    }

    # redirect based on table
    if (obj.status == 620 && obj.response == "redirect") {
      set obj.status = 308;
      set obj.http.Location = "https://" + req.http.host + table.lookup(solution_redirects, req.url.path);
      return (deliver);
    }

    if (obj.status == 621 && obj.response == "block") {
      set obj.status = 403;
      set obj.response = "Forbidden";
      return(deliver);
    }

    return(deliver);
}

sub vcl_deliver {
#FASTLY deliver
  return(deliver);
}

sub vcl_log {
#FASTLY log
}