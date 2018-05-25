
# Weibonews

Weibonews is a news aggregator based on Sina Weibo

## How to refresh access token

- First send a GET request to the following URL:

        https://api.weibo.com/oauth2/authorize?client_id=943327342&redirect_uri=http://lemontr2.com/response
- The server will redirect to the "redirect\_uri" with the authorization code; the authorization code is then used to exchange for the access token. E.g.:

        http://lemontr2.com/response?code=2a94e787b251ade37731c2aaa54aa5cd
- Now send a POST request to "https://api.weibo.com/oauth2/authorize". For example in PowerShell:

        $resp = Invoke-WebRequest -Uri "https://api.weibo.com/oauth2/access_token?client_id=943327342&redirect_uri=http://lemontr2.com/response&grant_type=authorization_code&client_secret=XXX&code=2a94e787b251ade37731c2aaa54aa5cd" -Method Post
        $resp.Content
    The response will be something like this
    
        {"access_token":"2.00OfsMMCIXGqBB7abe09659aRf2C1D","remind_in":"157679999","expires_in":157679999,"uid":"2012651764","isRealName":"true"}
- Copy and paste the "access_token" to "token.php"

