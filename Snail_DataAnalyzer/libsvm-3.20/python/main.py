import svmutil as svm
import glob
import csv
import os

files = glob.glob('./*.scale')
predictfiles = glob.glob('./*.predict')

for deletefile in predictfiles:
	os.remove(deletefile)
	

for currentFile in files:
	if "leave" in currentFile:
		y, x = svm.svm_read_problem(currentFile)
		yt, xt = svm.svm_read_problem('./' + currentFile[7:15] + ".ml.scale") 

		m = svm.svm_train(y, x, '-c 2 -g 0.0078125')
		p_label, p_acc, p_val = svm.svm_predict(yt, xt, m)
		
		# csv.writer(csvfile, delimiter=',')
		

		with open('./' + currentFile[7:15] + ".ml.predict", 'wb') as f:
			# writer = csv.writer(f,quoting=csv.QUOTE_NONE)
			for label in p_label:
				f.write(str(int(label)))
				f.write("\n")

		
	else:
		continue

