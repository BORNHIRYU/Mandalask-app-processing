class AppController {
  final String home = "home";
  final String mandalaHome = "mandala";
  final String mandalaEditorState = "editor";
  final String taskCommiting = "taszap";
  final String taskComplete = "comp";
  final String taskLogViewer = "tlog";
  final String completeParentTask = "cpt";
  final int tasklogBtnX = 20;
  final int mandalaBtnX = 260;
  final int transitBtnW = 200;
  final int transitBtnY = 520;
  final int transitBtnH = 80;
  final int clock_centerX = 240;
  final int clock_centerY = 320;
  String state;


  AppController() {
    state = home;
  }


  void changeMode(String targetMode) {
    if (targetMode==mandalaEditorState && state!=mandalaEditorState) {
      canvas.init();
      canvas.on();
    } else if (targetMode!=mandalaEditorState && state==mandalaEditorState) {
      canvas.off();
    }

    app.state = targetMode;
  }


  void detectTapActions() {
    if (tasklogBtnX<=mouseX&&mouseX<=tasklogBtnX+transitBtnW && transitBtnY<=mouseY&&mouseY<=transitBtnY+transitBtnH) {
      // タスク時間を見るボタンが押された時の処理
      app.changeMode(app.taskLogViewer);
    } else if (mandalaBtnX<=mouseX&&mouseX<=mandalaBtnX+transitBtnY && transitBtnY<=mouseY&&mouseY<=transitBtnY+transitBtnH) {
      // マンダラートを見るボタンが押された時の処理
      mandala.init();
      app.changeMode(app.mandalaHome);
    }
  }


  void displayClock() {
    fill(0);
    textSize(64);
    textAlign(CENTER, CENTER);
    text(nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2), 240, 80); // display current time

    // アナログ時計のメモリ
    for (int i=0; i<60; i++) {
      // 5で割り切れる分のとき太くする
      if (i%5==0) {
        strokeWeight(2);
      } else {
        strokeWeight(1);
      }
      stroke(0);
      line(clock_centerX+140*cos(radians(i*6)), clock_centerY+140*sin(radians(i*6)), clock_centerX+150*cos(radians(i*6)), clock_centerY+150*sin(radians(i*6)));
    }

    // 時計の針の角度を指定
    float second_hand_radians = map(second(), 0, 60, -PI/2, TWO_PI-PI/2);
    float minute_hand_radians = map(minute(), 0, 60, -PI/2, TWO_PI-PI/2) + map(second(), 0, 60, 0, PI/30);
    float hour_hand_radians = map(hour()%12, 0, 12, -PI/2, TWO_PI-PI/2) + map(minute(), 0, 60, 0, PI/6);
    fill(0);
    stroke(0);
    strokeWeight(1);
    line(clock_centerX, clock_centerY, clock_centerX+120*cos(second_hand_radians), clock_centerY+120*sin(second_hand_radians));
    strokeWeight(3);
    line(clock_centerX, clock_centerY, clock_centerX+80*cos(minute_hand_radians), clock_centerY+80*sin(minute_hand_radians));
    strokeWeight(6);
    line(clock_centerX, clock_centerY, clock_centerX+40*cos(hour_hand_radians), clock_centerY+40*sin(hour_hand_radians));
    circle(clock_centerX, clock_centerY, 8);
  }


  void displayTransitBtn() {
    noStroke();
    fill(156, 192, 255);
    rect(tasklogBtnX, transitBtnY, transitBtnW, transitBtnH, 10);
    fill(255, 192, 156);
    rect(mandalaBtnX, transitBtnY, transitBtnW, transitBtnH, 10);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("タスク時間", tasklogBtnX+transitBtnW/2, transitBtnY+transitBtnH/2);
    text("マンダラート", mandalaBtnX+transitBtnW/2, transitBtnY+transitBtnH/2);
  }


  void show() {
    displayClock();
    displayTransitBtn();
  }


  void run() {
    bgEffect.show();

    if (state==home) {
      show();
    } else if (state==mandalaHome) {
      mandala.show();
    } else if (state==mandalaEditorState) {
      canvas.show();
    } else if (state==taskCommiting) {
      tclock.show();
    } else if (state==taskLogViewer) {
      tlog.show();
    } else if (state==completeParentTask) {
      cpt.complete();
    }
  }
}
