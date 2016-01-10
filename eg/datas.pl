#!/usr/bin/env perl

use 5.14.2;
use warnings;

use WebService::TTRSS;

my $x = WebService::TTRSS->new(
  root_uri => 'https://rss.afoolishmanifesto.com',
  debug => $ENV{TTRSS_DEBUG},
);

$x->login( user => 'admin', password => $ENV{TTRSS_PASSWORD});

say $x->session_id;
say $x->unread;
say $x->version;

use Devel::Dwarn;
# Dwarn $x->counters('t');
# Dwarn $x->categories;
# Dwarn $x->headlines( limit => 10, feed_id => 22 );
# Dwarn $x->article( 138 );
# Dwarn $x->update_article( article_ids => 138, field => 3, data => undef );
# Dwarn $x->article( 138 );
# Dwarn $x->config;
# say $x->pref('icons_dir');
# Dwarn $x->labels;
# Dwarn $x->feed_tree;
# Dwarn $x->subscribe_to_feed( feed_url => 'http://blogs.perl.org/users/raiph1/atom.xml' );
# my $feed_data = Dwarn [grep $_->{feed_url} eq 'http://blogs.perl.org/users/raiph1/atom.xml', @{$x->feeds}];
# Dwarn $x->update_feed( $feed_data->[0]{id} );
# Dwarn $x->catchup_feed( feed_id => $feed_data->[0]{id} );
# Dwarn $x->unsubscribe_feed( $feed_data->[0]{id} );
