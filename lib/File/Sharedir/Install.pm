package File::Sharedir::Install;

use 5.008;
use strict;
use warnings;

use Carp;

use File::Spec;
use IO::Dir;

our $VERSION = '0.01';

our @DIRS;
our %TYPES;

require Exporter;

our @ISA = qw( Exporter);
our @EXPORT = qw( postamble install_share );

#####################################################################
sub install_shareXXX
{
    warn "init_dirscan";
    my $self = shift;
    if( $self->{SHARE} ) {
        my $S = $self->{SHARE};
        my $r = ref $S;
        unless( $r ) {
            share_dir( $S );
        }
        elsif( 'ARRAY' eq $r ) {
            foreach my $dir ( @{ $S } ) {
                share_dir( $dir );
            }
        }
        elsif( 'HASH' eq $r ) {
            foreach my $dir ( keys %{ $S } ) {
                share_dir( $dir, ref $S->{$dir} ? @{ $S->{$dir} } 
                                                       : $S->{$dir} );
            }
        }
    }
    # return $self->SUPER::init_dirscan();
}

#####################################################################
sub install_share
{
    my $dir  = @_ ? pop : 'share';
    my $type = @_ ? shift : 'dist';
    unless ( defined $type and $type eq 'module' or $type eq 'dist' ) {
        confess "Illegal or invalid share dir type '$type'";
    }
    unless ( defined $dir and -d $dir ) {
        confess "Illegal or missing directory '$dir'";
    }

    if( $type eq 'dist' ) {
        confess "Too many parameters to share_dir" if @_;
    }
    push @DIRS, $dir;
    $TYPES{$dir} = [ $type ];
    if( $type eq 'module' ) {
        my $module = _CLASS( $_[0] );
        unless ( defined $module ) {
            confess "Missing or invalid module name '$_[0]'";
        }
        push @{ $TYPES{$dir} }, $module;
    }

}

#####################################################################
sub postamble 
{
    my $self = shift;

    my @ret; # = $self->SUPER::postamble( @_ );
    foreach my $dir ( @DIRS ) {
        push @ret, postamble_share_dir( $self, $dir, @{ $TYPES{ $dir } } );
    }
    return join "\n", @ret;
}

#####################################################################
sub postamble_share_dir
{
    my( $self, $dir, $type, $mod ) = @_;

    my( $idir );
    if ( $type eq 'dist' ) {

        $idir = File::Spec->catdir( '$(INST_LIB)', 
                                    qw( auto share dist ), 
                                    '$(DISTNAME)'
                                  );

    } else {
        my $module = $mod;
        $module =~ s/::/-/g;

        $idir = File::Spec->catdir( '$(INST_LIB)', 
                                    qw( auto share module ), 
                                    $module
                                  );
    }

    my $files = {};
    _scan_share_dir( $files, $idir, $dir );

    my $autodir = '$(INST_LIB)';
    my $pm_to_blib = $self->oneliner(<<CODE, ['-MExtUtils::Install']);
pm_to_blib({\@ARGV}, '$autodir')
CODE

    my @cmds = $self->split_command( $pm_to_blib, %$files );

    my $r = join '', map { "\t\$(NOECHO) $_\n" } @cmds;

#    use Data::Dumper;
#    die Dumper $files;
    # Set up the install
    return <<"END_MAKEFILE";
config ::
$r

END_MAKEFILE
}


sub _scan_share_dir
{
    my( $files, $idir, $dir ) = @_;
    my $dh = IO::Dir->new( $dir ) or die "Unable to read $dir: $!";
    my $entry;
    while( defined( $entry = $dh->read ) ) {
        next if $entry =~ /^\./ or $entry =~ /(~|,v)$/;
        my $full = File::Spec->catfile( $dir, $entry );
        if( -f $full ) {
            $files->{ $full } = File::Spec->catfile( $idir, $entry );
        }
        elsif( -d $full ) {
            _scan_share_dir( $files, File::Spec->catdir( $idir, $entry ), $full );
        }
    }
}


#####################################################################
# Cloned from Params::Util::_CLASS
sub _CLASS ($) {
    (
        defined $_[0]
        and
        ! ref $_[0]
        and
        $_[0] =~ m/^[^\W\d]\w*(?:::\w+)*\z/s
    ) ? $_[0] : undef;
}

1;
__END__

=head1 NAME

File::Sharedir::Install - Perl extension for blah blah blah

=head1 SYNOPSIS

  use File::Sharedir::Install;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for File::Sharedir::Install, created by h2xs. It looks like the
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

Philip Gwyn, E<lt>fil@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Philip Gwyn

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
