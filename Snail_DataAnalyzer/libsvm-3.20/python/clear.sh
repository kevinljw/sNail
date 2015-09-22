rm *.csv
rm *.ml
rm *.scale
rm *.txt
rm *.predict

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U47/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user47predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user47predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user47predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U46/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user46predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user46predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user46predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U45/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user45predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user45predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user47predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U44/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user44predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user44predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user44predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U41/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user41predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user41predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user41predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U40/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user40predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user40predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user40predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U39/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user39predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user39predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user39predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U38/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user38predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user38predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user38predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U37/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user37predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user37predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user37predict/0.8_1.0_1.2/

mv ../../../Snail_DataAnalyzer/SNailDataAnalyzer/data/StudyOne/Result/PerUserLeaveOneOutByTime/U36/*.csv ./

python csv2libsvm.py

./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale

./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale

python main.py > out.txt

mv *.predict ../../confuseMatrix/user36predict/0.8_1.0_1.2/
mv out.txt ../../confuseMatrix/user36predict/0.8_1.0_1.2/
mv *.ml ../../confuseMatrix/user36predict/0.8_1.0_1.2/
