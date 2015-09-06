=== Run information ===

Scheme:       weka.classifiers.functions.LibSVM -S 0 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.001 -P 0.1 -model /Users/JesseHsiu -seed 1
Relation:     F2merged
Instances:    29150
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

Time taken to build model: 1042.78 seconds

=== Stratified cross-validation ===
=== Summary ===

Correctly Classified Instances       26978               92.5489 %
Incorrectly Classified Instances      2172                7.4511 %
Kappa statistic                          0.9193
Mean absolute error                      0.0115
Root mean squared error                  0.1071
Relative absolute error                  8.0721 %
Root relative squared error             40.1799 %
Coverage of cases (0.95 level)          92.5489 %
Mean rel. region size (0.95 level)       7.6923 %
Total Number of Instances            29150     

=== Detailed Accuracy By Class ===

                 TP Rate  FP Rate  Precision  Recall   F-Measure  MCC      ROC Area  PRC Area  Class
                 1.000    0.081    0.509      1.000    0.674      0.684    0.960     0.509     F2_p15_r-15
                 0.910    0.000    1.000      0.910    0.953      0.950    0.955     0.917     F2_p15_r0
                 0.924    0.000    1.000      0.924    0.960      0.958    0.962     0.930     F2_p15_r15
                 0.905    0.000    1.000      0.905    0.950      0.947    0.952     0.912     F2_p15_r45
                 0.895    0.000    1.000      0.895    0.945      0.942    0.948     0.903     F2_p15_r90
                 0.924    0.000    1.000      0.924    0.961      0.958    0.962     0.930     F2_p25_r0
                 0.929    0.000    1.000      0.929    0.963      0.961    0.964     0.934     F2_p45_r-15
                 0.932    0.000    1.000      0.932    0.965      0.962    0.966     0.937     F2_p45_r0
                 0.915    0.000    1.000      0.915    0.956      0.953    0.958     0.922     F2_p45_r15
                 0.903    0.000    1.000      0.903    0.949      0.947    0.952     0.910     F2_p45_r45
                 0.918    0.000    1.000      0.918    0.957      0.955    0.959     0.925     F2_p45_r90
                 0.926    0.000    1.000      0.926    0.962      0.959    0.963     0.932     F2_p65_r0
                 0.948    0.000    1.000      0.948    0.974      0.972    0.974     0.952     F2_p90_r0
Weighted Avg.    0.925    0.006    0.962      0.925    0.936      0.935    0.960     0.893     

=== Confusion Matrix ===

    a    b    c    d    e    f    g    h    i    j    k    l    m   <-- classified as
 2250    0    0    0    0    0    0    0    0    0    0    0    0 |    a = F2_p15_r-15
  202 2048    0    0    0    0    0    0    0    0    0    0    0 |    b = F2_p15_r0
  171    0 2079    0    0    0    0    0    0    0    0    0    0 |    c = F2_p15_r15
  214    0    0 2036    0    0    0    0    0    0    0    0    0 |    d = F2_p15_r45
  236    0    0    0 2014    0    0    0    0    0    0    0    0 |    e = F2_p15_r90
  170    0    0    0    0 2080    0    0    0    0    0    0    0 |    f = F2_p25_r0
  160    0    0    0    0    0 2090    0    0    0    0    0    0 |    g = F2_p45_r-15
  154    0    0    0    0    0    0 2096    0    0    0    0    0 |    h = F2_p45_r0
  191    0    0    0    0    0    0    0 2059    0    0    0    0 |    i = F2_p45_r15
  208    0    0    0    0    0    0    0    0 1942    0    0    0 |    j = F2_p45_r45
  184    0    0    0    0    0    0    0    0    0 2066    0    0 |    k = F2_p45_r90
  166    0    0    0    0    0    0    0    0    0    0 2084    0 |    l = F2_p65_r0
  116    0    0    0    0    0    0    0    0    0    0    0 2134 |    m = F2_p90_r0

