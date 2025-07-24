class CompleteParentTaskEffect {
  float h, s, b;
  int completeTxtY, peaceImgY;
  PImage parentImg, peaceImg;
  
  
  CompleteParentTaskEffect(){
  h = random(255);
  s = random(255);
  b = random(255);
  completeTxtY = -100;
  peaceImgY = 690;
  }


  void detectTapOperation() {
    progress.resetAllTasks();
    app.changeMode(app.mandalaHome);
    completeTxtY = -100;
    peaceImgY = 690;
  }


  void complete() {
    parentImg = loadImage(dataPath("tasks/parentTask.png"));
    peaceImg = loadImage(dataPath("imgs/peace_danda.jpg"));
    peaceImg.resize(400, 0);

    colorMode(HSB);
    background(255, 0, 0);
    // タスクを強調する演出
    for (int i=0; i<32; i++) {
      fill(h, s, b);
      h = random(255);
      s = 255;
      b = 223;
      arc(240, 320, 960, 960, PI*i/16., PI*(i+1)/16.);
    }

    fill(0);
    textSize(48);
    textAlign(CENTER, CENTER);
    text("♥たすくかんりょう♥", 240, completeTxtY);
    completeTxtY+=4;
    completeTxtY = constrain(completeTxtY, -100, 90);
    image(parentImg, 135, 135, 210, 210);
    image(peaceImg, 40, peaceImgY);
    text("タップで\n戻れよ!!", 330, peaceImgY+100);
    peaceImgY-=7;
    peaceImgY = constrain(peaceImgY, 360, 690);
    colorMode(RGB);
  }
}
