#! /usr/bin/env python
#---------------------------------------------------------------------
# Slightly modified pystache to handle the extension
# issue for the template files
#
# Jens Boettge <boettge@mpi-halle.mpg.de>	2017-08-01 15:36:02 +0200
#---------------------------------------------------------------------
__requires__ = 'pystache==0.5.4'
import sys
from pkg_resources import load_entry_point
import pystache.defaults as defaults


if __name__ == '__main__':
	defaults.TEMPLATE_EXTENSION=False
	sys.exit(
		load_entry_point('pystache==0.5.4', 'console_scripts', 'pystache')()
	)
