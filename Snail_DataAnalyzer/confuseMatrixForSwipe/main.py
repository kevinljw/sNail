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

	result = np.zeros((5,5))


	for currentCSV in csvfiles:

		
		if "leave" in currentCSV: continue
		
		csvFile = open(currentCSV, 'r')
		csvFile.next() # Skip header

		predictfile = open('./data/'+ splitext(basename(x))[0] + '/'+ currentCSV[-12:-4] + ".ml.predict", 'r')
		prefictData = csv.reader(predictfile)



		for realData in csv.reader(csvFile):
			predictResult = prefictData.next()

			classNum = 0
			predictNum = 0
			if int(realData[0]) == 0:
				classNum = 0
			if int(realData[0]) == 2:
				classNum = 1
			if int(realData[0]) == 4:
				classNum = 2
			if int(realData[0]) == 6:
				classNum = 3
			if int(realData[0]) == 9:
				classNum = 4

			if int(predictResult[0]) == 0:
				predictNum = 0
			if int(predictResult[0]) == 2:
				predictNum = 1
			if int(predictResult[0]) == 4:
				predictNum = 2
			if int(predictResult[0]) == 6:
				predictNum = 3
			if int(predictResult[0]) == 9:
				predictNum = 4

			# print realData[9] + "/" + predictResult[0]
			result[classNum,predictNum] += 1

			# if realData[9] == predictResult[0]:
			# 	print "ok"
			# else :
			# 	print "fail"
			

		csvFile.close()
		predictfile.close()

	# for y_result in range(0,11):
	# 	# print y_result
	# 	total = 0
	# 	for x_result in xrange(0,11):
	# 		total += result[y_result, x_result ]

	# 	print "total: " + str(total)

	# 	for x_result in xrange(0,11):
	# 		result[y_result, x_result ] = float(result[y_result, x_result ]/total)

	a = np.asarray(result)
	# %1.3f
	np.savetxt(splitext(basename(x))[0] +"result.csv", a, delimiter=",", fmt='%i', header="up, right, down, left, tap")

	