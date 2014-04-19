#!
# Run from terminal within the +dentist directory.
find . -type f | grep '_test.m$' | sed 's/\/\+*/\./g' | sed 's/^\./dentist/g' | sed 's/\.m$//g' | perl -ne 'chomp; print "display('\''" . $_ . "'\'')\n"; print $_ . ";\n"' > testSuite.m
