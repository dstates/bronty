#! /usr/local/bin/perl

use warnings;
use strict;

my $file = shift @ARGV;
my $text = join(" ", @ARGV);

my $fh;
open($fh, "<", $file) or die "Can't open $file\n";

while ( <$fh> ) {
  while ( m/(\[\[(\+)+\]\])/ ) {
    my $len = length($1);
    my $part = center($len, trim_to_field($len, \$text));
    $_ =~ s/\[\[(\+)+\]\]/$part/;
  }
  while ( m/(\[\[(\>)+\]\])/ ) {
    my $len = length($1);
    my $part = right($len, trim_to_field($len, \$text));
    $_ =~ s/\[\[(\>)+\]\]/$part/;
  }
  while ( m/(\[\[(\<)+\]\])/ ) {
    my $len = length($1);
    my $part = left($len, trim_to_field($len, \$text));
    $_ =~ s/\[\[(\<)+\]\]/$part/;
  }
  print; 
}

sub left {
  my $width  = shift;
  my $message = shift || '';
  return sprintf("%-${width}.${width}s", $message);
}

sub right {
  my $width  = shift;
  my $message = shift || '';
  return sprintf("%${width}.${width}s", $message);
}

sub center {
  my $width  = shift;
  my $message = shift || '';
  my $pad = " " x ( ($width - length($message)) / 2);
  return left($width, $pad . $message);
}

# trim_to_field
#
#   arguments:
#   length - field length (minimum 4)
#   message - scalar reference to string (must have a value)
#
#   returns portion of message that fits into length,
#   truncates message by the number of things it removes.

sub trim_to_field {
  my ($len, $message) = @_;
  
  return if not $$message;
  return if $len < 5;

  my $line = '';
  $$message =~ s/^\s*//;

  WORD: { do {
    my ($word, $remainder) = split(' ', $$message, 2); # grab next word

    if (length($line . $word) +1 > $len) { # next word pushes us over..
      if ($line) { # if the line has stuff in it, we're done
        last WORD;
      }
      # the only word in the buffer is longer than the line, hyphenate it
      if (substr($word, $len -1, 2) =~ m/[a-zA-Z]{2}/) {
        $$message = substr($word, $len - 1);
        $$message .= " " . $remainder if $remainder;
        $line .= substr($word, 0, $len -1) . "-";
        last WORD;
      }
      else {
        $$message = substr($word, $len);
        $$message .= " " . $remainder if $remainder;
        $line .= substr($word, 0, $len);
        last WORD;
      }
    }

    if ($line) {
      $line .= " " . $word;
    }
    else {
      $line = $word;
    }

    $$message = $remainder;
  } while ($$message);} # loop until message is empty

  return $line;
}

