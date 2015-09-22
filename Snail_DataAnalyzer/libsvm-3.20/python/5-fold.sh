python csv2libsvm5fold.py

# ./../svm-scale leaveT0merged.ml > leaveT0merged.ml.scale
./../svm-scale leaveT1merged.ml > leaveT1merged.ml.scale
./../svm-scale leaveT2merged.ml > leaveT2merged.ml.scale
./../svm-scale leaveT3merged.ml > leaveT3merged.ml.scale
./../svm-scale leaveT4merged.ml > leaveT4merged.ml.scale
./../svm-scale leaveT5merged.ml > leaveT5merged.ml.scale
# ./../svm-scale leaveT6merged.ml > leaveT6merged.ml.scale
# ./../svm-scale leaveT7merged.ml > leaveT7merged.ml.scale
# ./../svm-scale leaveT8merged.ml > leaveT8merged.ml.scale
# ./../svm-scale leaveT9merged.ml > leaveT9merged.ml.scale

# ./../svm-scale T0merged.ml > T0merged.ml.scale
./../svm-scale T1merged.ml > T1merged.ml.scale
./../svm-scale T2merged.ml > T2merged.ml.scale
./../svm-scale T3merged.ml > T3merged.ml.scale
./../svm-scale T4merged.ml > T4merged.ml.scale
./../svm-scale T5merged.ml > T5merged.ml.scale
# ./../svm-scale T6merged.ml > T6merged.ml.scale
# ./../svm-scale T7merged.ml > T7merged.ml.scale
# ./../svm-scale T8merged.ml > T8merged.ml.scale
# ./../svm-scale T9merged.ml > T9merged.ml.scale

python main.py > out.txt