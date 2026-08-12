# CPAN dependencies. Install with: cpanm --installdeps .
requires 'CGI';               # web/*.pl, fanel/client/download/faucet.pl
requires 'DBI';               # console/db_query.pl
requires 'Archive::Zip';      # needed to unpack MP3::Tag (zip distribution) when unzip is absent
requires 'MP3::Splitter';     # console/mp3split.pl
requires 'MP3::Tag';          # console/mp3split.pl
requires 'IO::Socket::SSL';   # lib/Volken/Https.pm
requires 'Mozilla::CA';       # lib/Volken/Https.pm
requires 'URI::Encode';       # lib/Volken/Https.pm
