package WebService::TTRSS;

# https://tt-rss.org/gitlab/fox/tt-rss/wikis/ApiReference

use Moo 2;

use HTTP::Tiny;
use JSON 'encode_json', 'decode_json';
use Data::Dumper::Concise;

has _ua => (
  is => 'ro',
  builder => sub {
    HTTP::Tiny->new(
      agent => 'WebService::TTRSS/' . ($_[0]->VERSION||'unversioned'),
    )
  },
);

sub post_to_api {
  my ($self, $method, @args) = @_;

  my $postdata = {
    op => $method,
    ( $self->has_session_id ? ( sid => $self->session_id ) : () ),
    @args,
  };

  warn 'Postdata: ' . Dumper($postdata) if $self->debug;

  my $r = $self->_ua->post(
    $self->root_uri => {
      content => encode_json($postdata),
    },
  );

  warn 'Response: ' . Dumper($r) if $self->debug;

  die "Failed to make web request: $r->{status} $r->{reason}"
    unless $r->{success};

  my $content = decode_json($r->{content});

  warn 'Decoded Content: ' . Dumper($content) if $self->debug;

  die "Failure from TTRSS API: $content->{content}{error}"
    if $content->{status};

  return $content
}

sub _simple_post { $_[0]->post_to_api($_[1])->{content}{$_[2]} }

has _root_uri => (
  is       => 'ro',
  required => 1,
  init_arg => 'root_uri',
);

has debug => ( is => 'rw' );

has root_uri => (
  is => 'ro',
  lazy => 1,
  init_arg => undef,
  builder => sub {
    my $uri = shift->_root_uri;

    return $uri if $uri =~ m(/api/$);
    return "${uri}api/" if $uri =~ m(/$);
    return "$uri/api/";
  },
);

has session_id => (
  is => 'rw',
  predicate => 'has_session_id',
  clearer => 'clear_session_id',
);

has api_level => (
  is => 'rw',
  lazy => 1,
  builder => sub { shift->get_api_level },
);

sub get_api_level { shift->_simple_post( qw( getApiLevel level ) ) }

sub version { shift->_simple_post( qw (getVersion version ) ) }

sub login {
  my ($self, %args) = @_;

  my $res = $self->post_to_api( login => %args );

  my $c = $res->{content};

  $self->session_id($c->{session_id});

  $self->api_level($c->{api_level})
    if exists $c->{api_level};

  return;
}

sub logout {
  my $self = shift;

  my $ret = $self->_simple_post( qw( logout status ) );

  $self->clear_session_id;

  $ret
}

sub is_logged_in { shift->_simple_post( qw( isLoggedIn status ) ) }

sub unread { shift->_simple_post( qw( getUnread unread ) ) }

sub counters {
  my ($self, $mode) = @_;

  $mode ||= 'flc';
  shift->post_to_api( 'getCounters', output_mode => $mode )->{content}
}

=head2 feeds

=over

=item * cat_id

=item * unread_only

=item * limit

=item * offset

=item * include_nested

=back

=cut

sub feeds { shift->post_to_api( 'getFeeds', @_ )->{content} }

=head2 categories

=over

=item * unread_only

=item * enable_nested

=item * include_empty

=back

=cut

sub categories { shift->post_to_api( getCategories => @_ )->{content} }

=head2 headlines

=over

=item * feed_id

=item * limit

=item * skip

=item * filter

=item * is_cat

=item * show_excerpt

=item * show_content

=item * view_mode

=item * include_attachments

=item * since_id

=item * include_nested

=item * order_by

=item * sanitize

=item * force_update

=item * has_sandbox

=item * include_header

=back

=cut

sub headlines { shift->post_to_api( getHeadlines => @_ )->{content} }

sub update_article { shift->post_to_api( updateArticle => @_ )->{content} }

sub article {
  shift->post_to_api( getArticle => ( article_id => shift ) )->{content}
}

sub config { shift->post_to_api('getConfig')->{content} }

sub update_feed {
  shift->post_to_api( updateFeed => ( feed_id => shift ) )->{content}
}

sub pref { shift->post_to_api( getPref => ( pref_name => shift ) )->{content}{value} }

sub catchup_feed { shift->post_to_api( catchupFeed => @_ )->{content} }

sub labels { shift->post_to_api('getLabels')->{content} }

# TODO
sub set_article_label {}

# TODO
sub share_to_published {}

sub subscribe_to_feed { shift->post_to_api( subscribeToFeed => @_ )->{content} }

sub unsubscribe_feed {
  shift->post_to_api( unsubscribeFeed => ( feed_id => shift ) )->{content}
}

sub feed_tree { shift->post_to_api( getFeedTree => @_ )->{content} }

1;
