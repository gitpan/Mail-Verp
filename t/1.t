# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################


use Test;
BEGIN { plan tests => 8 };
use Mail::Verp;
ok(1); # If we made it this far, we're ok.

#########################

my $x = Mail::Verp->new;

ok(defined($x) && $x->isa('Mail::Verp'));


my $sender = 'local@source.com';
my %remote = qw(
                remote+foo@example.com  local-remote+2Bfoo=example.com@source.com
                node42!ann@old.example.com local-node42+21ann=old.example.com@source.com
               );
=pod

print STDERR "$s $r1 encodes -> ", $x->encode($s, $r1), "\n";
print STDERR "$s $r2 encodes -> ", $x->encode($s, $r2), "\n";

=cut


while (my ($k, $v) = each %remote){

    my $encoded = $x->encode($sender, $k);

    print "Checking if $k encodes to $encoded\n";

    ok($encoded eq $v);

    my ($decoded_sender, $decoded_remote) = $x->decode($encoded);
   
    print "Checking if sender decodes to $sender\n";
 
    ok($decoded_sender eq $sender);

    print "Recipient $decoded_remote decodes to $k\n";

    ok($decoded_remote eq $k);
}

