package Mail::Verp;

use 5.000;
use strict;

use Carp;

use vars qw($VERSION @ENCODE_MAP @DECODE_MAP);
$VERSION = '0.01';

my @chars =  qw(@ : % ! - [ ]);

@ENCODE_MAP = map { quotemeta($_), sprintf '%.2X', ord($_) } ('+', @chars);
@DECODE_MAP = map { sprintf('%.2X', ord($_)), $_ } (@chars, '+');

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

    my ($slocal, $sdomain) = $sender    =~ m/(.+)\@([^\@]+)$/;

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

    if (my ($slocal, $rlocal, $rdomain, $sdomain) = $address =~ m/^([^-]+)-([^=]+)=([^\@]+)\@(.+)/){

        for (my $i = 0; $i < @DECODE_MAP; $i += 2) {
            for my $t ($rlocal, $rdomain){
                $t  =~ s/\+$DECODE_MAP[$i]/$DECODE_MAP[$i + 1]/g; 
            }
        }

        return (qq[$slocal\@$sdomain], qq[$rlocal\@$rdomain]);
    }
    else {
        carp "Cannot parse encoded address [$address]";
        return;
    }
}


1;
__END__

=head1 NAME

Mail::Verp - Perl extension for creating Variable Envelope Return Paths (VERP) addresses. 

=head1 SYNOPSIS

  use Mail::Verp;

  my $verp = Mail::Verp->new;

  
  #Create a VERP envelope sender of an email to recipient@example.net.
  my $verp_email = $verp->encode('sender@example.com', 'recipient@example.net');

  #If a bounce comes back, decode C<$verp_email> to figure out
  #the original recipient of the bounced mail.
  my ($sender, $recipient) = $verp->decode($verp_email);
 
 

=head1 ABSTRACT

Mail::Verp encodes and decodes Variable Envelope Return Paths
email addresses.

=head1 DESCRIPTION

Mail::Verp creates and decodes Variable Envelope Return Paths (VERP) addresses.
Verp encodes the address of an email recipient into the envelope
sender address so that a bounce can be more easily handled even if the original recipient
is forwarding their mail to another address and the remote Mail Transport Agents send back
unhelpful bounce messages.

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
