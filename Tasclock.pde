class TaskClock {
  final int startCommittingTaskAlertX = 50;
  final int startCommittingTaskAlertY = 540;
  final int startCommittingTaskAlertW = 380;
  final int startCommittingTaskAlertH = 80;
  final int stopToggleLeftEndX = 80;
  final int stopToggleRightEndX = 400;
  final int stopToggleY = 580;
  final int stopToggleLeftEndDoubleRadius = 60;
  int stopToggleX;
  int stopToggleLeftCoverX;
  int stopToggleFlameX;
  final int stopToggleFlameY = stopToggleY-stopToggleLeftEndDoubleRadius/2-10;
  int stopToggleFlameW;
  final int stopToggleFlameH = 80;
  final int stopToggleLeftCoverY = stopToggleFlameY;
  final int stopToggleTxtCoverX = 80;
  final int stopToggleTxtCoverY = stopToggleY-stopToggleLeftEndDoubleRadius/2-10;
  int stopToggleTxtCoverW;
  final int stopToggleTxtCoverH = stopToggleFlameH;
  final int bottomGoBackMandalaBtnX = 10;
  final int bottomGoBackMandalaBtnY = 540;
  final int bottomGoBackMandalaBtnW = 460;
  final int bottomGoBackMandalaBtnH = 100;
  PImage commitingTaskImg;
  String committingTaskImgFname;
  int committingChildTaskIndex, committingChildTaskNum;
  boolean isCompleteChildTask;
  boolean isCommittingTaskNow;
  boolean isRunningStopwatch;
  int currentBeginMillis;
  int totalCommittingTimeMillis;
  int currentSessionsDurationMillis;
  int currentTotalCommittingTimeMillis;
  boolean isSwipingNow;
  boolean isOnToggle;
  int taskCommitStartYear, taskCommitStartMonth, taskCommitStartDay, taskCommitStartHour, taskCommitStartMinutes, taskCommitStartSeconds;


  TaskClock() {
    stopToggleX = stopToggleLeftEndX;
    stopToggleLeftCoverX = stopToggleLeftEndX;
    stopToggleFlameX = 80;
    stopToggleFlameW = 400 - stopToggleFlameX;
    stopToggleTxtCoverW = stopToggleX - stopToggleLeftEndX;
    isCompleteChildTask = false;
    isCommittingTaskNow = false;
    isRunningStopwatch = false;
    currentBeginMillis = 0;
    totalCommittingTimeMillis = 0;
    isSwipingNow = false;
    isOnToggle = false;
  }


  String toMinSec(int mls) {
    final int allSec =  (mls - mls%1000)/1000;
    final int sec = allSec%60;
    final String secTxt = nf(sec, 2);
    final int allMin = (allSec-sec)/60;
    final int min = allMin%60;
    final String minTxt = nf(min, 2);
    final int allHour = (allMin-min)/60;
    return allHour + ":" +minTxt + ":" + secTxt;
  }


  void setChildTask(int targetChildTaskNum) {
    isCompleteChildTask = false;
    isRunningStopwatch = false;
    totalCommittingTimeMillis = 0;
    currentSessionsDurationMillis = 0;
    committingChildTaskNum = targetChildTaskNum;
    committingChildTaskIndex = targetChildTaskNum-1;
    committingTaskImgFname = dataPath("tasks/childrenTask" + committingChildTaskNum +".png");
    commitingTaskImg = loadImage(committingTaskImgFname);
    stopToggleX = stopToggleLeftEndX;
  }


  void detectTapActions() {
    if (!isRunningStopwatch && mouseX<=80 && mouseY<=40) {
      app.changeMode(app.mandalaHome);
    } else if (isCompleteChildTask && bottomGoBackMandalaBtnX<=mouseX&&mouseX<=bottomGoBackMandalaBtnX+bottomGoBackMandalaBtnW && bottomGoBackMandalaBtnY<=mouseY&&mouseY<=bottomGoBackMandalaBtnY+bottomGoBackMandalaBtnH) {
      app.changeMode(app.mandalaHome);
    } else if (!isCompleteChildTask && !isRunningStopwatch && startCommittingTaskAlertX<=mouseX&&mouseX<=startCommittingTaskAlertX+startCommittingTaskAlertW && startCommittingTaskAlertY<=mouseY&&mouseY<=startCommittingTaskAlertY+startCommittingTaskAlertH) {
      isRunningStopwatch = true;
      taskCommitStartYear = year();
      taskCommitStartMonth = month();
      taskCommitStartDay = day();
      taskCommitStartHour = hour();
      taskCommitStartMinutes = minute();
      taskCommitStartSeconds = second();
      println(taskCommitStartYear, taskCommitStartMonth, taskCommitStartDay, taskCommitStartHour, taskCommitStartMinutes, taskCommitStartSeconds);
    }
  }


  void detectSwipeActions() {
    if (!isSwipingNow && !isOnToggle) {
      // スワイプの開始地点がトグルの円上にあるか判定
      if (sqrt(sq(mouseX-stopToggleLeftEndX) + sq(mouseY-stopToggleY))<=stopToggleLeftEndDoubleRadius/2) {
        isOnToggle = true;
      }
      isSwipingNow = true;
    }
    if (isOnToggle) {
      stopToggleX = constrain(mouseX, stopToggleLeftEndX, stopToggleRightEndX);
    }
  }


  void detectReleaseAction() {
    isSwipingNow = false;
    isOnToggle = false;
    if (!isCompleteChildTask && stopToggleX>=stopToggleRightEndX-10) {
      isRunningStopwatch = false;
      // タスクに取り組んだ時間を計算
      totalCommittingTimeMillis += currentSessionsDurationMillis;
      int totalCommittingTimeAllSeconds = (totalCommittingTimeMillis-totalCommittingTimeMillis%1000)/1000;
      int totalCommittingSeconds = totalCommittingTimeAllSeconds%60;
      int totalCommittingTimeAllMinutes = (totalCommittingTimeAllSeconds-totalCommittingSeconds)/60;
      int totalCommittingTimeMinutes = totalCommittingTimeAllMinutes%60;
      int totalCommittingAllHours = (totalCommittingTimeAllMinutes-totalCommittingTimeMinutes)/60;
      progress.addTaskCommitData(taskCommitStartYear, taskCommitStartMonth, taskCommitStartDay, taskCommitStartHour, taskCommitStartMinutes, taskCommitStartSeconds, totalCommittingAllHours, totalCommittingTimeMinutes, totalCommittingSeconds);
      progress.pgsetCompletedChildTask(committingChildTaskIndex);
      isCompleteChildTask = true;
      stopToggleX = stopToggleRightEndX;
    } else if (isCompleteChildTask) {
      stopToggleX = stopToggleRightEndX;
    } else {
      stopToggleX = stopToggleLeftEndX;
    }
  }


  void displayToggleWidget() {
    noStroke();
    colorMode(HSB);

    // トグルを右に寄せるほど赤くする
    color toggleFlameColor = color(0, round((stopToggleX-80)/320.*255), round((stopToggleX-80)/320.*64)+192);

    // set toggle config
    stopToggleFlameX = stopToggleX;
    stopToggleFlameW = 400 - stopToggleFlameX;
    stopToggleTxtCoverW = stopToggleX - stopToggleLeftEndX;

    // toggle flame background
    fill(toggleFlameColor);
    rect(stopToggleFlameX, stopToggleFlameY, stopToggleFlameW, stopToggleFlameH);

    // explain the toggles function
    fill(255);
    textAlign(CENTER, CENTER);
    text("完了したら右にスライド", 260, stopToggleY);

    // toggle txt cover
    fill(toggleFlameColor);
    rect(stopToggleTxtCoverX, stopToggleTxtCoverY, stopToggleTxtCoverW, stopToggleTxtCoverH);

    // toggle flame
    fill(toggleFlameColor);
    arc(stopToggleLeftCoverX, stopToggleY, 80, 80, PI/2, PI*3/2); // 左半円
    arc(stopToggleRightEndX, stopToggleY, 80, 80, -PI/2, PI/2); // 右半円

    // toggle
    fill(255);
    circle(stopToggleX, stopToggleY, stopToggleLeftEndDoubleRadius);

    colorMode(RGB);
  }


  void displayTimer() {
    // calc times
    if (isRunningStopwatch) {
    } else {
      currentBeginMillis = millis();
    }
    currentSessionsDurationMillis = millis() - currentBeginMillis;
    currentTotalCommittingTimeMillis = totalCommittingTimeMillis + currentSessionsDurationMillis;


    // timer animation
    fill(128, 255, 255);
    arc(240, 450, 120, 120, -PI/2, ((currentTotalCommittingTimeMillis/1000.)%60)/60*TWO_PI-PI/2);

    // display all time
    fill(0);
    textAlign(CENTER, CENTER);
    String taskCommittingTimeTxt = toMinSec(totalCommittingTimeMillis + currentSessionsDurationMillis);
    text(taskCommittingTimeTxt, 240, 450); // ここが実際の秒数
  }


  void show() {
    fill(0);

    // go back home screen btn
    if (!isRunningStopwatch) {
      textSize(16);
      textAlign(LEFT, CENTER);
      text("< 戻る", 20, 20);
    }

    // task's number
    textSize(24);
    textAlign(CENTER, CENTER);
    text("タスク" + committingChildTaskNum, width/2, 50);

    // task's image
    image(commitingTaskImg, 100, 80, 280, 280);

    displayTimer();

    // display start btn or stop toggle
    if (!isCompleteChildTask && !isRunningStopwatch) {
      // display start timer btn
      fill(0, 255, 0);
      rect(startCommittingTaskAlertX, startCommittingTaskAlertY, startCommittingTaskAlertW, startCommittingTaskAlertH);
      fill(0);
      text("Start", startCommittingTaskAlertX+startCommittingTaskAlertW/2, startCommittingTaskAlertY+startCommittingTaskAlertH/2);
    } else {
      displayToggleWidget();
      if (isCompleteChildTask) {
        // display bottom btn
        rect(bottomGoBackMandalaBtnX, bottomGoBackMandalaBtnY, bottomGoBackMandalaBtnW, bottomGoBackMandalaBtnH, 25, 25, 0, 0);
        fill(0);
        text("タップで戻る", bottomGoBackMandalaBtnX+bottomGoBackMandalaBtnW/2, bottomGoBackMandalaBtnY+bottomGoBackMandalaBtnH/2);
      }
    }
  }
}
