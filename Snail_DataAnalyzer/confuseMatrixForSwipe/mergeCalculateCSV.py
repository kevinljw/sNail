import csv
import glob
import numpy as np
from os.path import basename
from os.path import splitext

csvFiles = glob.glob('./*.csv')

result = np.zeros((5,5))

for currentfile in csvFiles:
	csvFile = open(currentfile, 'r')
	csvFile.next() # Skip header

	
	currentRow = 0

	for realData in csv.reader(csvFile):
		print realData
		currentCol = 0

		for rawData in realData:
			result[currentRow,currentCol] += int(rawData)
			currentCol += 1
		currentRow +=1

a = np.asarray(result)
# %1.3f
np.savetxt("mergeAllResult.csv", a, delimiter=",", fmt='%i', header="up, right, down, left, tap")