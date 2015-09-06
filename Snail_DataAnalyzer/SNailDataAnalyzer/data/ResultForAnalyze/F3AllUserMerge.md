=== Run information ===

Scheme:       weka.classifiers.functions.LibSVM -S 0 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.001 -P 0.1 -model /Users/JesseHsiu -seed 1
Relation:     F3merged
Instances:    29250
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

Time taken to build model: 946.16 seconds

=== Stratified cross-validation ===
=== Summary ===

Correctly Classified Instances       26981               92.2427 %
Incorrectly Classified Instances      2269                7.7573 %
Kappa statistic                          0.916 
Mean absolute error                      0.0119
Root mean squared error                  0.1092
Relative absolute error                  8.4037 %
Root relative squared error             40.9968 %
Coverage of cases (0.95 level)          92.2427 %
Mean rel. region size (0.95 level)       7.6923 %
Total Number of Instances            29250     

=== Detailed Accuracy By Class ===

                 TP Rate  FP Rate  Precision  Recall   F-Measure  MCC      ROC Area  PRC Area  Class
                 1.000    0.084    0.498      1.000    0.665      0.675    0.958     0.498     F3_p15_r-15
                 0.916    0.000    1.000      0.916    0.956      0.954    0.958     0.923     F3_p15_r0
                 0.922    0.000    1.000      0.922    0.960      0.957    0.961     0.928     F3_p15_r15
                 0.919    0.000    1.000      0.919    0.958      0.955    0.960     0.925     F3_p15_r45
                 0.888    0.000    1.000      0.888    0.940      0.938    0.944     0.896     F3_p15_r90
                 0.920    0.000    1.000      0.920    0.958      0.956    0.960     0.926     F3_p25_r0
                 0.915    0.000    1.000      0.915    0.956      0.953    0.958     0.922     F3_p45_r-15
                 0.920    0.000    1.000      0.920    0.958      0.956    0.960     0.926     F3_p45_r0
                 0.924    0.000    1.000      0.924    0.960      0.958    0.962     0.929     F3_p45_r15
                 0.902    0.000    1.000      0.902    0.949      0.946    0.951     0.910     F3_p45_r45
                 0.904    0.000    1.000      0.904    0.949      0.947    0.952     0.911     F3_p45_r90
                 0.932    0.000    1.000      0.932    0.965      0.963    0.966     0.937     F3_p65_r0
                 0.930    0.000    1.000      0.930    0.964      0.962    0.965     0.936     F3_p90_r0
Weighted Avg.    0.922    0.006    0.961      0.922    0.934      0.932    0.958     0.890     

=== Confusion Matrix ===

    a    b    c    d    e    f    g    h    i    j    k    l    m   <-- classified as
 2250    0    0    0    0    0    0    0    0    0    0    0    0 |    a = F3_p15_r-15
  188 2062    0    0    0    0    0    0    0    0    0    0    0 |    b = F3_p15_r0
  175    0 2075    0    0    0    0    0    0    0    0    0    0 |    c = F3_p15_r15
  182    0    0 2068    0    0    0    0    0    0    0    0    0 |    d = F3_p15_r45
  253    0    0    0 1997    0    0    0    0    0    0    0    0 |    e = F3_p15_r90
  180    0    0    0    0 2070    0    0    0    0    0    0    0 |    f = F3_p25_r0
  191    0    0    0    0    0 2059    0    0    0    0    0    0 |    g = F3_p45_r-15
  181    0    0    0    0    0    0 2069    0    0    0    0    0 |    h = F3_p45_r0
  172    0    0    0    0    0    0    0 2078    0    0    0    0 |    i = F3_p45_r15
  220    0    0    0    0    0    0    0    0 2030    0    0    0 |    j = F3_p45_r45
  217    0    0    0    0    0    0    0    0    0 2033    0    0 |    k = F3_p45_r90
  153    0    0    0    0    0    0    0    0    0    0 2097    0 |    l = F3_p65_r0
  157    0    0    0    0    0    0    0    0    0    0    0 2093 |    m = F3_p90_r0

