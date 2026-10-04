from configparser import ConfigParser, ExtendedInterpolation
parser = ConfigParser(interpolation=ExtendedInterpolation())
# the default BasicInterpolation could be used as well
parser.read_string("""
[DEFAULT]
hash = #

[hashes]
shebang =
  ${hash}!/usr/bin/env python
  ${hash} -*- coding: utf-8 -*-

extensions =
  enabled_extension
  another_extension
  #disabled_by_comment
  yet_another_extension

interpolation not necessary = if # is not at line start
even in multiline values = line #1
  line #2
  line #3
""")
print(parser['hashes']['shebang'])



print(parser['hashes']['extensions'])




print(parser['hashes']['interpolation not necessary'])

print(parser['hashes']['even in multiline values'])
