# TODO

* Fix row height (Do not use hardcoded value)

* Special case for delta and trend, when age == 0

* Set post count to 50

* Investigate SSL issues

* Write error msg to STDERR instead of info files, e.g.

    ----request----
    GET https://api.weibo.com/2/statuses/user_timeline.json?access_token=2.00OfsMMCIXGqBB50b811f921jG1VJB&uid=1618051664&count=100&page=1&trim_user=1&feature=1
    User-Agent: libwww-perl/5.833
    
    
    ----response----
    500 Can't connect to api.weibo.com:443 (SSL connect attempt failed because of handshake problemserror:00000000:lib(0):func(0):reason(0))
    Content-Type: text/plain
    Client-Date: Sun, 12 May 2013 02:01:22 GMT
    Client-Warning: Internal response
    
    500 Can't connect to api.weibo.com:443 (SSL connect attempt failed because of handshake problemserror:00000000:lib(0):func(0):reason(0))

* Add retry logic

* Add error handling logic to summary.pl:

    Use of uninitialized value $comments_count in multiplication (*) at /var/lib/openshift/517e40055004460bb30000a0/app-root/runtime/repo//pl/summary.pl line 13, <> line 16901.
    Use of uninitialized value $reposts_count in addition (+) at /var/lib/openshift/517e40055004460bb30000a0/app-root/runtime/repo//pl/summary.pl line 13, <> line 16901.
    Use of uninitialized value $age in hash element at /var/lib/openshift/517e40055004460bb30000a0/app-root/runtime/repo//pl/summary.pl line 21, <> line 16901.
    Use of uninitialized value $comments_count in multiplication (*) at /var/lib/openshift/517e40055004460bb30000a0/app-root/runtime/repo//pl/summary.pl line 13, <> line 16902.

    Argument "" isn't numeric in numeric gt (>) at /var/lib/openshift/517e40055004460bb30000a0/app-root/runtime/repo//pl/summary.pl line 69, <> line 26961.

