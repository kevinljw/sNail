public class StudyMgr implements SerialListener{
  
   HandTieArduinoSystemOnProcessing mainClass;
   // public final static int NUM_OF_FINGERS = 5;
   public final static int NUM_OF_GESTURE_SET = 17;
   public final static int NUM_OF_EACH_TRAINING_TIMES = 10;
   public final static int NUM_OF_EACH_TRAINING_DATA = 20;
   public final static int SAMPLING_FPS = 20;
   public final static int SAMPLING_PERIOD = 1000/SAMPLING_FPS;
   
   public final static int NUM_OF_SG = 19;
   public final static int NUM_OF_SG_FIRSTROW = 9;

   public final static int NUM_OF_HAND_ROWS = 8;
   // public final static int NUM_OF_HAND_COLS = 5;
   public final static int GestureGrid = 6;

   public final static int ShowGauge_x = 400;
   public final static int ShowGauge_y = 30;

   public final static int EachSG_x = 50;
   public final static int EachSG_y = 20;   
   
   public final static int ShowGauge_dist = 30;
   
   public final static String StudyID = "11";
   
   public String ShowText = "Study #2";

   public int NowMainStage = 1;
   public int NowStudyStage = 0;
   

   public int NowGesture = 0;      
   public int LastGesture = 0;   

   public int NowRow = 0;        
             
   public boolean TransFlg = false; 
   public boolean PeriodRecordFlg = false; 
   public int PeriodRecordCounter;
   public boolean loadTableFlg = false; 
   
   public boolean autoSpace = false;
   public boolean autoL = false;

   private int millis;
   // public int RowCount;

   int tCountArray[] = new int[NUM_OF_GESTURE_SET+1]; 
   int tCfinishRound;

   Table table;
   
   // PImage img;
   int imgIndex =16;
   PImage[] imgArray = new PImage[NUM_OF_GESTURE_SET+1];
   boolean loadedImgFlg = false;

   public final static int imgWidth = 600;
   public final static int imgHeight = 100;

   public StudyMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;
//      mainClass.expImgManager.setIndividualImageDirPath(StudyID);

      for(int i=0; i< NUM_OF_GESTURE_SET; i++){
            
                tCountArray[i]=0;  
            
      }
      tCfinishRound=0;
//      for(int i=86; i<86+30;i++){
//          imgArray[i-86]=loadImage("Photo/IMG_0"+(i<100?("0"+i):i)+".JPG");
//      }
//      RowCount = 0;
      println("SAMPLING_PERIOD:"+SAMPLING_PERIOD);
      
   }
   public void start(){
     switch (NowMainStage){
        case 1 :      //start
            textSize(40);
            fill(0, 102, 153);
            text("Study Two", width*0.39, height*0.45); 
            
           break;
        case 2 :      //

            if(loadedImgFlg){
              showImage();
              textSize(35);
              fill(color(200));
              if(imgIndex<=10){

                  text("Number:"+imgIndex, width*0.75, height*0.95);
              }
              else{
                  switch (imgIndex) {
                      case 11:
                        text("Y", width*0.85, height*0.95);
                        break;
                      case 12:
                        text("L", width*0.85, height*0.95);
                        break;
                      case 13:
                        text("S", width*0.85, height*0.95);
                        break;
                      case 14:
                        text("Fuxk", width*0.8, height*0.95);
                        break;
                      case 15:
                        text("Rock", width*0.8, height*0.95);
                        break;
                  }
              }
            }
            else{
              text("Loading Images...", width*0.7, height*0.5); 
            }
            textSize(26);
            fill(0, 102, 153);
            text("Gesture:"+NowGesture+"\nRow:"+NowRow+"\nLast:"+LastGesture, width*0.02, height*0.06); 

            textSize(10);
            for(int nn=0; nn<NUM_OF_GESTURE_SET; nn++){
              text(nn, width*0.01, 126+nn*8.3);
            }
             

            for(int i=0; i< NUM_OF_GESTURE_SET; i++){
               for(int j=0; j<NUM_OF_EACH_TRAINING_TIMES; j++){
                  if(NowGesture == i && tCountArray[i]-1==j){
                    fill(color(0,255,0));
                  }
                  else{
                    fill((tCountArray[i]>j)?color(0):color(255));
                  }
                  rect(25+j*GestureGrid,height*0.2+i*GestureGrid+2*i,GestureGrid,GestureGrid);
               }
            }
            for(int r=0; r< NUM_OF_HAND_ROWS/2; r++){
                if(r==NowRow/2){
                    fill(color(0,255,0));
                }
                else{
                    fill(color(255));
                }
                rect(width*0.2+15,height*0.06-15+30*r,120,5);
                rect(width*0.2,height*0.06+30*r,150,5);
           
            }
            
            for(int sgi=0; sgi<NUM_OF_SG; sgi++){
                fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(sgi)));
                if(sgi<NUM_OF_SG_FIRSTROW){
                    rect(ShowGauge_x+sgi*EachSG_x,ShowGauge_y,EachSG_x,EachSG_y);
                }
                else{
                    rect(ShowGauge_x+(sgi-NUM_OF_SG_FIRSTROW-0.5)*EachSG_x,ShowGauge_y+ShowGauge_dist,EachSG_x,EachSG_y);

                }

            }
            
            fill(0,0,0);
            if(NowStudyStage==0){
               textSize(40);
               text("Press <BUTTON> to start", width*0.15, height*0.4); 
             }
             else{
               fill(255, 102, 153);
               textSize(40);
               
               if(TransFlg==false && PeriodRecordFlg==false){  
                 text("Record? <BUTTON>", width*0.15, height*0.4); 
               }
               else if(TransFlg){
                 text("ready? <BUTTON>", width*0.15, height*0.4); 
               } 
                 
             }
            if(PeriodRecordFlg){
              
                text(PeriodRecordCounter, width*0.15, height*0.44);

                if(millis()-millis>=SAMPLING_PERIOD){
                  // println("period:"+(millis()-millis));
                  millis = millis();
                  
                    if(PeriodRecordCounter+1<=NUM_OF_EACH_TRAINING_DATA){
                      PeriodRecordCounter++;
                      AddNewRow();        
                    }
                    else{
                        PeriodRecordFlg=false;
                        TransFlg=true;

                        if(randNextGes()){
                          if(NowRow+2 < NUM_OF_HAND_ROWS){
                                  NowRow+=2;
                                  tCfinishRound=0;
                                  NowStudyStage=0;
                                  for(int i=0; i< NUM_OF_GESTURE_SET; i++){
                          
                                            tCountArray[i]=0;  
                                           
                                  }
                                  saveTable(table, "StudyData/User"+StudyID+"_tmp.csv");
                              }
                              else{
                                  NowMainStage=3;
                                  saveTable(table, "StudyData/User"+StudyID+".csv");
                              }

                        }
                        loadWhichImage();
                    }
                }
            }
            if(autoSpace==true && PeriodRecordFlg==false){
               nextStep(); 
             }
           break;   
         case 3:
             textSize(40);
            fill(0, 0, 0);
            text("Done", width*0.39, height*0.45); 

          break;
        case 4:
             textSize(40);
            fill(0, 0, 0);
            text("One More Thing...", width*0.3, height*0.45); 

          break;
        case 5:
            // if(loadedImgFlg){
            //   showImage();
            // }
            // else{
            //   text("Loading Images...", width*0.7, height*0.5); 
            // }
            fill(color(0,255));
             textSize(16);
            text("Stage: 1   2   3   4   5", 10, height*0.32); 
             for(int st=1; st<=5; st++){
                if(NowStudyStage==st){
                    fill(color(0,255,0));
                }
                else{
                    fill(color(255));
                }
                ellipse(66 + (st-1)*26, height*0.35, 10, 10);
              }
              if(autoSpace==true){
               nextStepView(); 
             }
          break;
        case 6:
             textSize(40);
            fill(0, 0, 0);
            text("Thank You", width*0.32, height*0.45); 

          break;
     }
//     for(int k=0; k < 3; k++ ){
       
//     }

   }
   public color getHeatmapRGB(float value){
     float minimum=0.6;
     float maximum=1.4;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)),255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)), (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
   }
   public void performKeyPress(char k){
      
      switch (k) {
        case '1' :
            NowMainStage=1;
           break;
        case '2' :
            if(!loadedImgFlg){
                for(int i=0; i<NUM_OF_GESTURE_SET;i++){
                      imgArray[i]=loadImage("GestureSet/"+i+".jpg");
                  }
                imgArray[NUM_OF_GESTURE_SET]=loadImage("Photo/blank.jpg");
                loadedImgFlg=true;
            }

            for(int i=0; i< NUM_OF_GESTURE_SET; i++){
                tCountArray[i]=0;  
            }
            NowGesture=0;
            tCfinishRound =0;

            autoSpace=false;
            NewTable(); 
            NowMainStage=2;
            NowStudyStage=0;
            
            TransFlg=false;
            PeriodRecordFlg = false;
            PeriodRecordCounter = 0;
            NowRow = 0; 

           break;
        case '3' :
            if(!loadedImgFlg){
                for(int i=0; i<=NUM_OF_GESTURE_SET;i++){
                      imgArray[i]=loadImage("GestureSet/"+i+".JPG");
                  }
                imgArray[NUM_OF_GESTURE_SET]=loadImage("Photo/blank.jpg");
                loadedImgFlg=true;
            }
            NowMainStage=3;
           break;
        case 's':
            saveTable(table, "StudyData/User"+StudyID+".csv");
           break ;
        case ESC:
            saveTable(table, "StudyData/User"+StudyID+".csv");
           break;
        // case '~':
        //     println("Loading Table...");
        //     table = loadTable("StudyData/User"+StudyID+"_tmp.csv","header");
        //     int lastRow = table.getRowCount()-1;
        //     // NowDegree = table.getInt(lastRow,"Degree");      
        //     NowRow = table.getInt(lastRow,"Line1");
        //     NowGesture = table.getInt(lastRow,"Gesture"); 
        //     TransFlg=false;
        //     loadTableFlg = true;
        //     // lastStep();
        //    break;
        // case 'l':
        //       lastStep();
        //       DeleteRow();
        //    break;
        case '\\':
            println("Delete");
            lastStep();
           break ;
        case ' ' :
          nextStep();
          // nextStep();
          // if(loadedImgFlg && NowMainStage==2){
          //   nextStep();
          // }
          // else if(NowMainStage==3){
          //     NowMainStage=4;
          // }
          // else if(NowMainStage==4){
          //     NowMainStage=5;
          //     NowStudyStage=0;
              
          //     NowFinger = 0;
          //     NowLevel=0;      //mid
          //     NowBend=false;     //s
          //     nextStepView();
          //     autoSpace=false;
          // }
          // else if(NowMainStage==5){
          //     nextStepView();
          // }
          break;
        case 'o' :
            if(!autoL){
              autoSpace=!autoSpace;
            }
          break;
        // case 'p' :
        //     if(!autoSpace){
        //       autoL=!autoL;
        //     }
           
        //   break;
      }
   }
   public boolean randNextGes(){
        int randGes = floor(random(0, NUM_OF_GESTURE_SET));
        boolean fillYet =false;

        if(tCountArray[randGes]>tCfinishRound){

          int tmpi = (randGes+1 >= NUM_OF_GESTURE_SET)?0:randGes+1;

          while (tmpi!=randGes) {
            if(tCountArray[tmpi]<=tCfinishRound){
                  tCountArray[tmpi]++;
                  LastGesture = NowGesture;
                  NowGesture = tmpi;
                  // println("randGes: "+randGes+", tmpi: "+ tmpi);
                  fillYet = true;           
            }
            if(fillYet){
              tmpi = randGes;
              // println("out while");
            }
            else{
              tmpi=(tmpi+1>=NUM_OF_GESTURE_SET)?0:tmpi+1;
              // println(">tmpi: "+tmpi);
            }
          }
          
          if(!fillYet){
             
              if(tCfinishRound+1<NUM_OF_EACH_TRAINING_TIMES){
                 tCountArray[randGes]++;
                 LastGesture = NowGesture;
                NowGesture = randGes;
                tCfinishRound++;
              }
              else{
                return true;
              }

          }
        }
        else{
          tCountArray[randGes]++;
          LastGesture = NowGesture;
          NowGesture = randGes;
        }
        return false;
   }
   public void AddNewRow(){
    if(loadTableFlg){
        loadTableFlg=false;
    }
    else{
      TableRow tmpNewRow = table.addRow();

      // tmpNewRow.setString("Degree",str(NowDegree));
      tmpNewRow.setString("Gesture", str(NowGesture));
      tmpNewRow.setString("Times", str(tCfinishRound));
     
      tmpNewRow.setString("Line1", str(NowRow));
      tmpNewRow.setString("SG1_0",str(mainClass.sgManager.getOneElongationValsOfGauges(0)));
      tmpNewRow.setString("SG1_1",str(mainClass.sgManager.getOneElongationValsOfGauges(1)));
      tmpNewRow.setString("SG1_2",str(mainClass.sgManager.getOneElongationValsOfGauges(2)));
      tmpNewRow.setString("SG1_3",str(mainClass.sgManager.getOneElongationValsOfGauges(3)));
      tmpNewRow.setString("SG1_4",str(mainClass.sgManager.getOneElongationValsOfGauges(4)));
      tmpNewRow.setString("SG1_5",str(mainClass.sgManager.getOneElongationValsOfGauges(5)));
      tmpNewRow.setString("SG1_6",str(mainClass.sgManager.getOneElongationValsOfGauges(6)));
      tmpNewRow.setString("SG1_7",str(mainClass.sgManager.getOneElongationValsOfGauges(7)));
      tmpNewRow.setString("SG1_8",str(mainClass.sgManager.getOneElongationValsOfGauges(8)));
      
      tmpNewRow.setString("Line2", str(NowRow+1));

      tmpNewRow.setString("SG2_0",str(mainClass.sgManager.getOneElongationValsOfGauges(9)));
      tmpNewRow.setString("SG2_1",str(mainClass.sgManager.getOneElongationValsOfGauges(10)));
      tmpNewRow.setString("SG2_2",str(mainClass.sgManager.getOneElongationValsOfGauges(11)));
      tmpNewRow.setString("SG2_3",str(mainClass.sgManager.getOneElongationValsOfGauges(12)));
      tmpNewRow.setString("SG2_4",str(mainClass.sgManager.getOneElongationValsOfGauges(13)));  
      tmpNewRow.setString("SG2_5",str(mainClass.sgManager.getOneElongationValsOfGauges(14)));  
      tmpNewRow.setString("SG2_6",str(mainClass.sgManager.getOneElongationValsOfGauges(15)));  
      tmpNewRow.setString("SG2_7",str(mainClass.sgManager.getOneElongationValsOfGauges(16)));  
      tmpNewRow.setString("SG2_8",str(mainClass.sgManager.getOneElongationValsOfGauges(17)));  
      tmpNewRow.setString("SG2_9",str(mainClass.sgManager.getOneElongationValsOfGauges(18)));  
      
     
    }
    // RowCount++;

   }
   public void DeleteRow(){
     // RowCount--;
     if(table.getRowCount()>0){
       table.removeRow(table.getRowCount()-1);
     }
   }
   public void NewTable(){
      table = new Table();
      
      // table.addColumn("Degree");
      table.addColumn("Gesture");
      table.addColumn("Times");
    
      table.addColumn("Line1");
      table.addColumn("SG1_0");
      table.addColumn("SG1_1");
      table.addColumn("SG1_2");
      table.addColumn("SG1_3");
      table.addColumn("SG1_4");
      table.addColumn("SG1_5");
      table.addColumn("SG1_6");
      table.addColumn("SG1_7");
      table.addColumn("SG1_8");

      table.addColumn("Line2");
      table.addColumn("SG2_0");
      table.addColumn("SG2_1");
      table.addColumn("SG2_2");
      table.addColumn("SG2_3");
      table.addColumn("SG2_4");
      table.addColumn("SG2_5");
      table.addColumn("SG2_6");
      table.addColumn("SG2_7");
      table.addColumn("SG2_8");
      table.addColumn("SG2_9");

   }
   public void lastStep(){
        if(NowGesture != LastGesture){
          tCountArray[NowGesture]--;
          boolean subRoundFlg = false;
          for(int j =0; j<NUM_OF_GESTURE_SET; j++){
              if(tCountArray[j]>tCfinishRound){
                    subRoundFlg = true;
              }
          }
          if(!subRoundFlg){
              tCfinishRound--;

          }
          for(int i =0; i<NUM_OF_EACH_TRAINING_DATA; i++){
              DeleteRow();
          }
          NowGesture = LastGesture;
        }

   }
   public void nextStep(){
        if(NowMainStage==2){
            if(NowStudyStage==0){
                NowStudyStage=1;
                TransFlg=true;
                PeriodRecordFlg = false;
                PeriodRecordCounter = 0;
                randNextGes();
                tCfinishRound=0;
                   
            }
            else if(NowStudyStage==1){
                if(TransFlg){
                  TransFlg=false;  

                }
                else{
                  
                  PeriodRecordFlg = true;
                  PeriodRecordCounter = 0;
                  millis = millis();
                  
                }

            }

        }
        loadWhichImage();
   }
   public void loadWhichImage(){
            
       imgIndex = NowGesture;
     
   }
   // public void showSGPos(){
   //   final int SG_dist = 30;
   //   final int SG_X = 350;
   //   final int SG_Y = 130;
     
   //   for(int i=0; i<NUM_OF_HAND_COLS ; i++){
   //     for(int j=0; j<NUM_OF_HAND_ROWS ; j++){
          
   //         if(NowRow1==j && NowCol1==i){
   //            fill(255,0,0);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else if(NowRow2==j && NowCol2==i){
   //            fill(255,255,0);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else if(NowRow3==j && NowCol3==i){
   //            fill(0,0,255);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else if(NowRow4==j && NowCol4==i){
   //            fill(0,255,255);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else{
   //            fill(0,0,0);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 5, 5);
   //         }
          
   //     }
   //   }
   
   // }
   public void showImage(){
      if(NowStudyStage>0){
        image(imgArray[imgIndex], imgWidth, imgHeight, floor(width/4) , floor(height/2) );
      }
   }
  public void nextStepView(){
           
   }

   // public void performMousePress(){

   // }
  @Override
  public void registerToSerialNotifier(SerialNotifier notifier){
    notifier.registerForSerialListener(this);
  }
  @Override
  public void removeToSerialNotifier(SerialNotifier notifier){
    notifier.removeSerialListener(this);
  }
  
  @Override
  public void updateAnalogVals(float [] values){}
  @Override
  public void updateCaliVals(float [] values){}
  @Override
  public void updateTargetAnalogValsMinAmp(float [] values){}
  @Override
  public void updateTargetAnalogValsWithAmp(float [] values){}
  @Override
  public void updateBridgePotPosVals(float [] values){}
  @Override
  public void updateAmpPotPosVals(float [] values){}
  @Override
  public void updateCalibratingValsMinAmp(float [] values){}
  @Override
  public void updateCalibratingValsWithAmp(float [] values){}

  StringBuffer strBuffer = new StringBuffer();

 private String getImageFileName() {
   strBuffer.setLength(0);
   strBuffer.append(StudyID);
   strBuffer.append("_");
   strBuffer.append(NowGesture);
   strBuffer.append("_");
   strBuffer.append(NowRow);
   return strBuffer.toString();
 }

  @Override
  public void updateReceiveRecordSignal(){
    performKeyPress(' ');
//    mainClass.expImgManager.captureImage(getImageFileName());
  }

}
