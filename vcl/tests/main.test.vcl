// Unit tests for vcl/main.vcl. Run: falco test -I vcl/tests vcl/main.vcl

// ---- vcl_recv ----

// @scope: recv
sub test_recv_apex_raises_add_www {
  set req.http.host = "jsantosc.com";
  testing.call_subroutine("vcl_recv");
  assert.error(600, "add_www");
  assert.equal(req.http.host, "www.jsantosc.com");
}

// @scope: recv
sub test_recv_fastly_host_is_not_rewritten {
  set req.http.host = "jsantosc-feature.global.ssl.fastly.net";
  set req.url = "/personal-blog/";
  testing.call_subroutine("vcl_recv");
  assert.not_error();
  assert.state(lookup);
}

// @scope: recv
sub test_recv_non_get_passes {
  set req.method = "POST";
  set req.http.host = "jsantosc.com";
  testing.call_subroutine("vcl_recv");
  assert.state(pass);
}

// @scope: recv
sub test_recv_table_path_raises_redirect {
  set req.http.host = "www.jsantosc.com";
  set req.url = "/personal-blog";
  testing.call_subroutine("vcl_recv");
  assert.error(620, "redirect");
}

// @scope: recv
sub test_recv_blocked_path_raises_block {
  set req.http.host = "www.jsantosc.com";
  set req.url = "/test-block";
  testing.call_subroutine("vcl_recv");
  assert.error(621, "block");
}

// ---- vcl_error ----

// @scope: error
sub test_error_add_www_redirects_to_https {
  set req.http.host = "www.jsantosc.com";
  set req.url = "/personal-blog/posts/?a=1";
  set obj.status = 600;
  set obj.response = "add_www";
  testing.call_subroutine("vcl_error");
  assert.equal(obj.status, 308);
  assert.equal(obj.http.Location, "https://www.jsantosc.com/personal-blog/posts/?a=1");
}

// @scope: error
sub test_error_block_returns_403 {
  set req.url = "/test-block";
  set obj.status = 621;
  set obj.response = "block";
  testing.call_subroutine("vcl_error");
  assert.equal(obj.status, 403);
}

// One test per solution_redirects row: a new redirect starts with a red test here.
describe solution_redirects {
  before_error {
    set req.http.host = "www.jsantosc.com";
    set obj.status = 620;
    set obj.response = "redirect";
  }

  // @scope: error
  sub test_root {
    set req.url = "/";
    testing.call_subroutine("vcl_error");
    assert.equal(obj.status, 308);
    assert.equal(obj.http.Location, "https://www.jsantosc.com/personal-blog/");
  }

  // @scope: error
  sub test_personal_blog {
    set req.url = "/personal-blog";
    testing.call_subroutine("vcl_error");
    assert.equal(obj.http.Location, "https://www.jsantosc.com/personal-blog/");
  }

  // @scope: error
  sub test_posts {
    set req.url = "/personal-blog/posts";
    testing.call_subroutine("vcl_error");
    assert.equal(obj.http.Location, "https://www.jsantosc.com/personal-blog/posts/");
  }

  // @scope: error
  sub test_contact {
    set req.url = "/personal-blog/contact";
    testing.call_subroutine("vcl_error");
    assert.equal(obj.http.Location, "https://www.jsantosc.com/personal-blog/contact/");
  }

  // @scope: error
  sub test_about {
    set req.url = "/personal-blog/about";
    testing.call_subroutine("vcl_error");
    assert.equal(obj.http.Location, "https://www.jsantosc.com/personal-blog/about/");
  }

  // @scope: error
  sub test_sitemap {
    set req.url = "/sitemap.xml";
    testing.call_subroutine("vcl_error");
    assert.equal(obj.http.Location, "https://www.jsantosc.com/personal-blog/sitemap.xml");
  }
}

// ---- vcl_fetch ----

// @scope: fetch
sub test_fetch_default_ttl_without_cache_headers {
  set beresp.status = 200;
  testing.call_subroutine("vcl_fetch");
  assert.equal(beresp.ttl, 3600s);
  assert.state(deliver);
}

// @scope: fetch
sub test_fetch_no_store_passes {
  set beresp.http.Cache-Control = "no-store";
  testing.call_subroutine("vcl_fetch");
  assert.state(pass);
}
