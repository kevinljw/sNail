import csv
import glob
from os.path import basename
from os.path import splitext
import numpy as np

# a = numpy.asarray([ [1,2,3], [4,5,6], [7,8,9] ])
# numpy.savetxt("foo.csv", a, delimiter=",")


folders = glob.glob('./data/*')

# print "haha"


# f = open('example.csv', 'r')  
classification = [0,1,2,3,4,5,6,7,8,9,10]


for x in folders:
	csvfiles = glob.glob('./data/'+ splitext(basename(x))[0] + '/*.csv')
	# predictedfiles = glob.glob('./data/'+ splitext(basename(x))[0] + '/*.csv')

	result = np.zeros((11,11))


	for currentCSV in csvfiles:

		
		if "leave" in currentCSV: continue
		
		csvFile = open(currentCSV, 'r')
		csvFile.next() # Skip header

		predictfile = open('./data/'+ splitext(basename(x))[0] + '/'+ currentCSV[-12:-4] + ".ml.predict", 'r')
		prefictData = csv.reader(predictfile)



		for realData in csv.reader(csvFile):
			predictResult = prefictData.next()

			# print realData[9] + "/" + predictResult[0]
			result[realData[9],predictResult[0]] += 1

			# if realData[9] == predictResult[0]:
			# 	print "ok"
			# else :
			# 	print "fail"
			

		csvFile.close()
		predictfile.close()

		# for y_result in range(0,11):
		# 	total = 0
		# 	for x_result in xrange(0,11):
		# 		total += result[y_result, x_result ]

		# 	for x_result in xrange(0,11):
		# 		result[y_result, x_result ] = float(result[y_result, x_result ]/total)


		a = np.asarray(result)
		np.savetxt(splitext(basename(x))[0] +"result.csv", a, delimiter=",", fmt='%i', header="p15_r-15,p15_r0,p15_r15,p15_r45,p25_r0,p45_r-15,p45_r0,p45_r15,p45_r45,p65_r0,p0_r0")

	