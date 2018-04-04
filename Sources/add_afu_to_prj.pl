#!/usr/bin/perl

open(OUTF, ">>prj/psl_fpga.prj") || die "Error";
open(WORKFILE, "<prj/afu.prj") || die "Error";
print OUTF <WORKFILE>;
close(WORKFILE);
close(OUTF);
