#!/usr/bin/perl

my $code_path    = "/home/eqemu/code/";
my $patches_path = $code_path . "utils/patches";
my $binary_path  = "/home/eqemu/code/build/bin";
my $server_path  = "/home/eqemu/server";

#::: Symlink server binaries
opendir(DH, $binary_path);
my @files = readdir(DH);

foreach my $file (@files) {
    my $source = $binary_path . "/" . $file;
    my $target = $server_path . "/" . $file;

    next if (substr($file, 0, 1) eq ".");
    next if (substr($file, 0, 2) eq "..");

    print "Symlinking Source: " . $source . " Target: " . $target . "\n";

    print `ln -s -f $source $target`
}

#::: Symlink server patches
opendir(DH, $patches_path);
@files = readdir(DH);

foreach my $file (@files) {
    my $source = $patches_path . "/" . $file;
    my $target = $server_path . "/" . $file;

    next if (substr($file, 0, 1) eq ".");
    next if (substr($file, 0, 2) eq "..");

    print "Symlinking Source: " . $source . " Target: " . $target . "\n";

    print `ln -s -f $source $target`
}