import glob
# import csv2libsvm
from os.path import basename
from os.path import splitext

import sys
import csv
from collections import defaultdict


def construct_line( label, line ):
	new_line = []
	if float( label ) == 0.0:
		label = "0"
	new_line.append( label )

	for i, item in enumerate( line ):
		if item == '' or float( item ) == 0.0:
			continue
		new_item = "%s:%s" % ( i + 1, item )
		new_line.append( new_item )
	new_line = " ".join( new_line )
	new_line += "\n"
	return new_line

def csv2libsvm(input_file, output_file):

	label_index = 9
	skip_headers = True

	i = open( input_file, 'rb' )
	o = open( output_file, 'wb' )

	reader = csv.reader( i )

	if skip_headers:
		headers = reader.next()

	for line in reader:
		if label_index == -1:
			label = '1'
		else:
			label = line.pop( label_index )

		new_line = construct_line( label, line )
		o.write( new_line )


files = glob.glob('./*.csv')

for x in files:
	csv2libsvm(x, './' + splitext(basename(x))[0] +'.ml')

