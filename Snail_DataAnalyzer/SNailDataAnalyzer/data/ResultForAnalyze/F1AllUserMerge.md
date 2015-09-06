=== Run information ===

Scheme:       weka.classifiers.functions.LibSVM -S 0 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.001 -P 0.1 -model /Users/JesseHsiu -seed 1
Relation:     F1merged
Instances:    29252
Attributes:   19
              SG_E0
              SG_D0
              SG_E1
              SG_D1
              SG_E2
              SG_D2
              SG_E3
              SG_D3
              SG_E4
              SG_D4
              SG_E5
              SG_D5
              SG_E6
              SG_D6
              SG_E7
              SG_D7
              SG_E8
              SG_D8
              ID
Test mode:    10-fold cross-validation

=== Classifier model (full training set) ===

LibSVM wrapper, original code by Yasser EL-Manzalawy (= WLSVM)

Time taken to build model: 1031.45 seconds

=== Stratified cross-validation ===
=== Summary ===

Correctly Classified Instances       27179               92.9133 %
Incorrectly Classified Instances      2073                7.0867 %
Kappa statistic                          0.9232
Mean absolute error                      0.0109
Root mean squared error                  0.1044
Relative absolute error                  7.6773 %
Root relative squared error             39.1848 %
Coverage of cases (0.95 level)          92.9133 %
Mean rel. region size (0.95 level)       7.6923 %
Total Number of Instances            29252     

=== Detailed Accuracy By Class ===

                 TP Rate  FP Rate  Precision  Recall   F-Measure  MCC      ROC Area  PRC Area  Class
                 0.957    0.024    0.769      0.957    0.853      0.845    0.967     0.739     F1_p15_r-15
                 0.923    0.000    1.000      0.923    0.960      0.957    0.961     0.928     F1_p15_r0
                 0.922    0.000    1.000      0.922    0.959      0.957    0.961     0.928     F1_p15_r15
                 0.919    0.000    1.000      0.919    0.958      0.955    0.959     0.925     F1_p15_r45
                 0.902    0.000    1.000      0.902    0.949      0.946    0.951     0.910     F1_p15_r90
                 0.924    0.000    1.000      0.924    0.960      0.958    0.962     0.930     F1_p25_r0
                 0.982    0.053    0.608      0.982    0.751      0.751    0.965     0.599     F1_p45_r-15
                 0.924    0.000    1.000      0.924    0.960      0.958    0.962     0.929     F1_p45_r0
                 0.909    0.000    1.000      0.909    0.952      0.950    0.954     0.916     F1_p45_r15
                 0.916    0.000    1.000      0.916    0.956      0.953    0.958     0.922     F1_p45_r45
                 0.931    0.000    1.000      0.931    0.964      0.962    0.965     0.936     F1_p45_r90
                 0.940    0.000    1.000      0.940    0.969      0.967    0.970     0.945     F1_p65_r0
                 0.931    0.000    1.000      0.931    0.964      0.962    0.965     0.936     F1_p90_r0
Weighted Avg.    0.929    0.006    0.952      0.929    0.935      0.932    0.962     0.888     

=== Confusion Matrix ===

    a    b    c    d    e    f    g    h    i    j    k    l    m   <-- classified as
 2154    0    0    0    0    0   96    0    0    0    0    0    0 |    a = F1_p15_r-15
   57 2077    1    0    0    0  116    0    0    0    0    0    0 |    b = F1_p15_r0
   47    1 2076    0    0    0  127    0    0    0    0    0    0 |    c = F1_p15_r15
   57    0    0 2067    0    0  126    0    0    0    0    0    0 |    d = F1_p15_r45
   64    0    0    0 2030    0  156    0    0    0    0    0    0 |    e = F1_p15_r90
   61    0    0    0    0 2079  110    0    0    0    0    0    0 |    f = F1_p25_r0
   41    0    0    0    0    0 2209    0    0    0    0    0    0 |    g = F1_p45_r-15
   62    0    0    0    0    0  110 2078    0    0    0    0    0 |    h = F1_p45_r0
   60    0    0    0    0    0  145    0 2045    0    0    0    0 |    i = F1_p45_r15
   57    0    0    0    0    0  133    0    0 2060    0    0    0 |    j = F1_p45_r45
   51    0    0    0    0    0  105    0    0    0 2094    0    0 |    k = F1_p45_r90
   44    0    0    0    0    0   90    0    0    0    0 2116    0 |    l = F1_p65_r0
   47    0    0    0    0    0  109    0    0    0    0    0 2094 |    m = F1_p90_r0

