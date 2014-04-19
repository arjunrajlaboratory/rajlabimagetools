#!
# Run from terminal within the +improc2 directory.
find . -type f | grep '_test.m$' | sed 's/\/\+*/\./g' | sed 's/^\./improc2/g' | sed 's/\.m$//g' | perl -ne 'chomp; print "display('\''" . $_ . "'\'')\n"; print $_ . ";\n"' > testSuite.m
