package Math::Vector::Real::Neighbors;

our $VERSION = '0.01';

use strict;
use warnings;

use Sort::Key::Radix qw(nkeysort_inplace);

sub neighbors {
    my $class = shift;
    my ($bottom, $top) = Math::Vector::Real->box(@_);
    my $box = $top - $bottom;
    my $v = [map $_ - $bottom, @_];
    my $ixs = [0..$#_];
    my $dist2 = [($box->abs2 * 10) x @_];
    my $neighbors = [(undef) x @_];
    _neighbors($v, $ixs, $dist2, $neighbors, $box, 0);
    return @$neighbors;
}

sub neighbors_bruteforce {
    my $class = shift;
    my ($bottom, $top) = Math::Vector::Real->box(@_);
    my $box = $top - $bottom;
    my $v = [map $_ - $bottom, @_];
    my $ixs = [0..$#_];
    my $dist2 = [($box->abs2 * 10) x @_];
    my $neighbors = [(undef) x @_];
    _neighbors_bruteforce($v, $ixs, $dist2, $neighbors, $box, 0);
    return @$neighbors;
}

sub _neighbors_bruteforce {
    my ($v, $ixs, $dist2, $neighbors) = @_;
    my $ixix = 0;
    for my $i (@$ixs) {
        $ixix++;
        my $v0 = $v->[$i];
        for my $j (@$ixs[$ixix..$#$ixs]) {
            my $d2 = $v0->dist2($v->[$j]);
            if ($dist2->[$i] > $d2) {
                $dist2->[$i] = $d2;
                $neighbors->[$i] = $j;
            }
            if ($dist2->[$j] > $d2) {
                $dist2->[$j] = $d2;
                $neighbors->[$j] = $i;
            }
        }
    }
}

sub _neighbors {
    if (@{$_[1]} < 6) {
        _neighbors_bruteforce(@_);
    }
    else {
        my ($v, $ixs, $dist2, $neighbors, $box) = @_;
        my $dim = $box->max_component_index;
        nkeysort_inplace { $v->[$_][$dim] } @$ixs;

        my $bfirst = @$ixs >> 1;
        my $alast = $bfirst - 1;

        my $abox = $box->clone;
        $abox->[$dim] = $v->[$ixs->[$alast]][$dim] - $v->[$ixs->[0]][$dim];
        my $bbox = $box->clone;
        $bbox->[$dim] = $v->[$ixs->[$#$ixs]][$dim] - $v->[$ixs->[$bfirst]][$dim];

        _neighbors($v, [@$ixs[0..$alast]], $dist2, $neighbors, $abox);
        _neighbors($v, [@$ixs[$bfirst..$#$ixs]], $dist2, $neighbors, $bbox);

        for my $i (@$ixs[0..$alast]) {
            my $vi = $v->[$i];
            my $mind2 = $dist2->[$i];
            for my $j (@$ixs[$bfirst..$#$ixs]) {
                my $vj = $v->[$j];
                my $dc = $vj->[$dim] - $vi->[$dim];
                last unless ($mind2 > $dc * $dc);
                my $d2 = $vi->dist2($vj);
                if ($d2 < $mind2) {
                    $mind2 = $dist2->[$i] = $d2;
                    $neighbors->[$i] = $j;
                }
            }
        }

        for my $i (@$ixs[$bfirst..$#$ixs]) {
            my $vi = $v->[$i];
            my $mind2 = $dist2->[$i];
            for my $j (reverse @$ixs[0..$alast]) {
                my $vj = $v->[$j];
                my $dc = $vj->[$dim] - $vi->[$dim];
                last unless ($mind2 > $dc * $dc);
                my $d2 = $vi->dist2($vj);
                if ($d2 < $mind2) {
                    $mind2 = $dist2->[$i] = $d2;
                    $neighbors->[$i] = $j;
                }
            }
        }

        # my @dist2_cp = @$dist2;
        # my @neighbors_cp = @$neighbors;
        # _neighbors_bruteforce($v, $ixs, $dist2, $neighbors, $abox);
        # use 5.010;
        # say "ixs         : @$ixs";
        # say "neighbors_cp: @neighbors_cp[@$ixs]";
        # say "neighbors   : @$neighbors[@$ixs]";
    }
}

1;
__END__

=head1 NAME

Math::Vector::Real::Neighbors - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Math::Vector::Real::Neighbors;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Math::Vector::Real::Neighbors, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Salvador Fandino, E<lt>salva@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Salvador Fandino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
