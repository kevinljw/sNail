import csv
import glob

csvfiles = glob.glob('./*.csv')
predictedfiles = glob.glob('./*.predict')

f = open('example.csv', 'r')  

for i in range(0,csvfiles.length):
    print(i)