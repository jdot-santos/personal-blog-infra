table solution_redirects {
    "/": "/personal-blog/",
    "/personal-blog": "/personal-blog/"
}


sub vcl_recv {
    #FASTLY recv
    if (table.contains(solution_redirects, req.url.path)) {
        error 620 "redirect";
    }
    return (lookup);
}

sub vcl_error {
    #FASTLY error
    if (obj.status == 620 && obj.response == "redirect") {
        set obj.status = 308;
        set obj.http.Location = "https://" + req.http.host + table.lookup(solution_redirects, req.url.path);
        return (deliver);
    }
    return (deliver);
}