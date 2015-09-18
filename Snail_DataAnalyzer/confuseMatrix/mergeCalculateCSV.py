import csv
import glob
import numpy as np
from os.path import basename
from os.path import splitext

csvFiles = glob.glob('./*.csv')

result = np.zeros((11,11))

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
np.savetxt("mergeAllResult.csv", a, delimiter=",", fmt='%i', header="p15_r-15,p15_r0,p15_r15,p15_r45,p25_r0,p45_r-15,p45_r0,p45_r15,p45_r45,p65_r0,p0_r0")