#!/usr/bin/perl

use strict;
use warnings;
use WWW::Mechanize;
use URI::URL;

BEGIN { require 'config.pl'; }

sub err_msg($)
{
  my ($mech) = @_;
  print STDERR "----request----\n", $mech->res()->request->as_string, "\n";
  print STDERR "----response----\n", $mech->res()->as_string, "\n";
  warn "Failed to fetch " . $mech->uri() . ": " . $mech->status();
}

sub get_token()
{
  my $mech = WWW::Mechanize->new();
  my $url = url('https://api.weibo.com/oauth2/authorize');
  $url->query_form(
    client_id     => CLIENT_ID,
    response_type => 'code',
    redirect_uri  => REDIRECT_URI,
  );
  
  $mech->get( $url );
  
  # "redirect_uri" is a fake one. We just need the "code" parameter
  $mech->requests_redirectable( ['GET'] );
  
  $mech->submit_form(
    form_name => 'authZForm',
    fields    => {
      userId    => USER_ID,
      passwd    => PASSWD,
    },
  );
  
  if ($mech->status() eq '302')
  {
    my $location = $mech->res()->header( 'Location' );
    if ($location =~ /code=(.*)/)
    {
      my $code = $1;
      $mech->post( 'https://api.weibo.com/oauth2/access_token',
          {
            client_id         => CLIENT_ID,
            client_secret     => CLIENT_SECRET,
            grant_type        => 'authorization_code',
            redirect_uri      => REDIRECT_URI,
            code              => $code,
          } );
      if ($mech->success())
      {
        my $resp = $mech->res();
        if ($resp->decoded_content() =~ /"access_token":"(.*?)"/)
        {
          print $1, "\n";
          return;
        }
      }
    }
  }
  err_msg($mech);
}

get_token();
