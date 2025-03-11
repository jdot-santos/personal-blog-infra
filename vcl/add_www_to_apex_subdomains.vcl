sub vcl_recv {
    #FASTLY recv
    if (!std.prefixof(req.http.host, "www.")) {
      set req.http.host = "www." + req.http.host;
      error 600 "add_www";
    }
}

sub vcl_error {
    #FASTLY error
    if (obj.status == 600 && obj.response == "add_www") {
      set obj.status = 308; # Or use 307 for temporary
      set obj.response = "Permanent redirect";
      set obj.http.Location = req.protocol + "://" req.http.host + req.url;
      synthetic {""};
      return (deliver);
    }
}