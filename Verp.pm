package Mail::Verp;

use 5.000;
use strict;

use Carp;

use vars qw($VERSION @ENCODE_MAP @DECODE_MAP);
$VERSION = '0.03';

my @chars =  qw(@ : % ! - [ ]);

@ENCODE_MAP = map { quotemeta($_), sprintf '%.2X', ord($_) } ('+', @chars);
@DECODE_MAP = map { sprintf('%.2X', ord($_)), $_ } (@chars, '+');
push @DECODE_MAP, map { lc $_ } @DECODE_MAP;

sub new
{
    my $self = shift;
    $self = bless {}, ref($self) || $self;
}

sub encode 
{
    my $self = shift;
    my $sender = shift;
    my $recipient = shift;
    
    unless ($sender){
        carp "Missing sender address";
        return;
    }

    unless ($recipient){
        carp "Missing recipient address";
        return;
    }

    my ($slocal, $sdomain) = $sender  =~ m/(.+)\@([^\@]+)$/;

    unless ($slocal && $sdomain){
        carp "Cannot parse sender address [$sender]";
        return;
    }

    my ($rlocal, $rdomain) = $recipient =~ m/(.+)\@([^\@]+)$/;

    unless ($rlocal && $rdomain){
        carp "Cannot parse recipient address [$recipient]";
        return;
    }

    for (my $i = 0; $i < @ENCODE_MAP; $i += 2) {
        for my $t ($rlocal, $rdomain){
            $t  =~ s/$ENCODE_MAP[$i]/+$ENCODE_MAP[$i + 1]/g; 
        }
    }

    return qq[$slocal-$rlocal=$rdomain\@$sdomain];
}

sub decode
{
    my $self = shift;
    my $address = shift;

    unless ($address){
        carp "Missing encoded address";
        return;
    }

    if (my ($slocal, $rlocal, $rdomain, $sdomain) = $address =~ m/^(.+)-([^=]+)=([^\@]+)\@(.+)/){

        for (my $i = 0; $i < @DECODE_MAP; $i += 2) {
            for my $t ($rlocal, $rdomain){
                $t  =~ s/\+$DECODE_MAP[$i]/$DECODE_MAP[$i + 1]/g; 
            }
        }

        return (qq[$slocal\@$sdomain], qq[$rlocal\@$rdomain]) if wantarray;
        return qq[$rlocal\@$rdomain];
    }
    else {
        return $address;
    }
}


1;
__END__

=head1 NAME

Mail::Verp - encodes and decodes Variable Envelope Return Paths (VERP) addresses. 

=head1 SYNOPSIS

  use Mail::Verp;
  
  #Create a VERP envelope sender of an email to recipient@example.net.
  my $verp_email = $Mail::Verp->encode('sender@example.com', 'recipient@example.net');

  #If a bounce comes back, decode $verp_email to figure out
  #the original recipient of the bounced mail.
  my ($sender, $recipient) = $Mail::Verp->decode($verp_email);
 
  
=head1 ABSTRACT

Mail::Verp encodes and decodes Variable Envelope Return Paths (VERP) email addresses.

=head1 DESCRIPTION

Mail::Verp encodes the address of an email recipient into the envelope
sender address so that a bounce can be more easily handled even if the original recipient
is forwarding their mail to another address and the remote Mail Transport Agents send back
unhelpful bounce messages. The module must also be used to decode bounce recipient addresses.

=head1 FUNCTIONS

=over

=item new() 

Primarily useful to save typing. So instead of typing C<Mail::Verp> you can say
C<my $x = Mail::Verp->new;> then use C<$x> whereever C<Mail::Verp> is usually required.

=item encode(LOCAL-ADDRESS, REMOTE-ADDRESS)

Encodes LOCAL-ADDRESS, REMOTE-ADDRESS into a verped address suitable for use
as an envelope, return, address. It may also be useful to use the same address in
Errors-To and Reply-To headers to compensate for broken Mail Transport Agents.

=item decode(VERPED-ADDRESS)

Decodes VERPED-ADDRESS into its constituent parts.
Returns LOCAL-ADDRESS and REMOTE-ADDRESS in list context, REMOTE-ADDRESS in scalar context.
Returns VERPED-ADDRESS if the decoding fails.

=back

=head2 EXPORT

None.

=head1 SEE ALSO

DJ Bernstein details verps here: http://cr.yp.to/proto/verp.txt
Sam Varshavchik  proposes an encoding here: http://www.courier-mta.org/draft-varshavchik-verp-smtpext.txt.

=head1 AUTHOR

Gyepi Sam, E<lt>gyepi@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gyepi Sam

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
