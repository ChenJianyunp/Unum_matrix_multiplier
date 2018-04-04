#!/usr/bin/perl

use File::Find;
use File::Copy;

if ($ARGV[0] eq "-d") {
    shift @ARGV;
    $dir = $ARGV[0];
}
else {
    die "Please include directory to operate on with '-d' option";
}

if ($ARGV[1] eq "-f") {
    shift @ARGV;
    $proj_file = $ARGV[1];
}
else {
    die "Please include output file name";
}

open (prj_file, ">$dir/../prj/$proj_file") or die "Can't open temp file.";
find(\&write_vivado_prj_files, $dir);
close prj_file or die "Can't close input file.";

sub write_vivado_prj_files
{
    my $file = $_;
    if ((-f $file) && ($file =~ /\.vhd/))
    {
        if($file =~ /synthesis_support/)
        {
        print prj_file 'vhdl ibm "' . "$dir" . "$file" . '"' . "\n";
	}
	else
        {
	print prj_file 'vhdl work "' . "$dir" . "$file" . '"' . "\n";
	}
    }
    elsif ((-f $file) && ($file =~ /\.v/))
    {
	print prj_file 'verilog work "' . "$dir" . "$file" . '"' . "\n";
    }
    elsif ((-f $file) && ($file =~ /\.sv/))
    {
        print prj_file 'system work "' . "$dir" . "$file" . '"' . "\n";
    }
}

