# hops-chan
# version 1.0
#       
# / i think you said plenty. /
#

#use
use Getopt::Std;
use warnings;
use strict;
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32;
use POSIX qw/strftime/;

# user specific
my $hostsfile = "C:/Windows/System32/drivers/etc/hosts";
my ($lenhip,$ipspace) = "";
my ($hname,$hip,$huser) = "";
my ($path, $filename) = Win32::GetFullPathName($0);
my $longpath = Win32::GetFullPathName($path);
my $numhosts = 0;

# args
my %args;
getopts('gh', \%args);

# registry
my $pound=$Registry->Delimiter("/");
my $diskKey = $Registry->{"HKEY_CURRENT_USER/Software/SimonTatham/PuTTY/Sessions/"}
	or die "Can't read key: $^E\n";

# help
my $help = "\n\tHOPS - Hosts from Putty sessions.\n\n\t$0 [-gh]\n\n\t-g - generate hosts file.\n\t-h - print this message.\n";

# subs
sub read_file {
    my ($filename) = @_;
    open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
    local $/ = undef;
    my $all = <$in>;
    close $in;
    return $all;
}
 
sub write_file {
    my ($filename, $content) = @_;
    open my $out, '>:encoding(UTF-8)', $filename or die "Could not open '$filename' for writing $!";;
    print $out $content;
    close $out;
    return;
}

# main
if ($args{g}) {
    my $data = read_file($hostsfile);
    $data =~ s/# Oracle.*/# Oracle\n/s;
    foreach my $entry ( $diskKey->SubKeyNames ) {
        ($hname,$hip,$huser) = split('\%20', $entry);
        $hip = substr $hip, 1, -1;
        $lenhip = length($hip);
        $ipspace = 16 - $lenhip;
        $data .= "$hip"." " x $ipspace."$hname.domain.com $hname\n";
        $numhosts = $numhosts + 1;
    }
    write_file($hostsfile, $data);
    print "Done! Processed $numhosts hosts.\n";
}
elsif ($args{h}) { print $help; exit 1; }
else { print "Use -h to display help information.\n"; exit 1; }

# end
exit 0;
