class Canvas {
  final String parentImgFname = "tasks/parentTask.png";
  PImage canvasImg;
  String targetSaveImgFname;
  ArrayList<float[]> drawedLine = new ArrayList<float[]>();
  ArrayList<ArrayList<float[]>> allLines = new ArrayList<ArrayList<float[]>>();
  ArrayList<ArrayList<ArrayList<float[]>>> allLinesHistory = new ArrayList<ArrayList<ArrayList<float[]>>>();
  int currentHistoryIndex, lastHistoryIndex;
  int x, y, w, h;
  int currentEditingTaskIndex;
  int refreshBtnX, refreshBtnY, undoBtnX, undoBtnY, redoBtnX, redoBtnY, saveBtnX, saveBtnY, exitBtnX, exitBtnY;
  int canvasFuncBtnW, canvasFuncBtnH;
  int alertLeftBtnX, alertLeftBtnY, alertLeftBtnW, alertLeftBtnH;
  int alertRightBtnX, alertRightBtnY, alertRightBtnW, alertRightBtnH;
  int alertCenterLargeBtnX, alertCenterLargeBtnY, alertCenterLargeBtnW, alertCenterLargeBtnH;
  boolean isRunningNow = false;
  boolean isShowingSaveAlert = false;
  boolean isShowingNoLineAlert = false;
  boolean isShowingDeleteAlert = false;

  Canvas() {
    x = 30;
    y = 30;
    w = 420;
    h = 420;
    refreshBtnX = 260;
    refreshBtnY = 470;
    undoBtnX = 330;
    undoBtnY = 470;
    redoBtnX = 400;
    redoBtnY = 470;
    saveBtnX = 30;
    saveBtnY = 470;
    exitBtnX = 100;
    exitBtnY = 470;
    canvasFuncBtnW = 50;
    canvasFuncBtnH = 50;
    alertLeftBtnX = 60;
    alertLeftBtnY = 550;
    alertLeftBtnW = 160;
    alertLeftBtnH = 40;
    alertRightBtnX = 260;
    alertRightBtnY = 550;
    alertRightBtnW = 160;
    alertRightBtnH = 40;
    alertCenterLargeBtnX = 60;
    alertCenterLargeBtnY = 550;
    alertCenterLargeBtnW = 360;
    alertCenterLargeBtnH = 40;
  }

  void on() {
    isRunningNow = true;
  }

  void off() {
    isRunningNow = false;
  }


  void setTargetTaskByIndex(int targetTaskIndex) {
    currentEditingTaskIndex = targetTaskIndex;
    if (targetTaskIndex==4) {
      targetSaveImgFname = dataPath(parentImgFname);
    } else {
      int targetChildTaskNum;
      if (targetTaskIndex<4) {
        targetChildTaskNum = targetTaskIndex+1;
      } else {
        targetChildTaskNum = targetTaskIndex;
      }
      targetSaveImgFname = dataPath("tasks/childrenTask" + targetChildTaskNum +".png");
    }
    println(targetSaveImgFname);
  }


  void removeAlert() {
    isShowingSaveAlert = false;
    isShowingNoLineAlert = false;
    isShowingDeleteAlert = false;
  }


  void init() {
    currentHistoryIndex = 0;
    lastHistoryIndex = 0;
    allLines = new ArrayList<ArrayList<float[]>>();
    allLinesHistory = new ArrayList<ArrayList<ArrayList<float[]>>>();
    allLinesHistory.add(new ArrayList<ArrayList<float[]>>());
    isShowingDeleteAlert = false;
    removeAlert();
  }

  // 現時点の描画を複製する(同じオブジェクトを参照させないための対策)
  ArrayList<ArrayList<float[]>> cloneAllLines(ArrayList<ArrayList<float[]>> targetAllLines) {
    ArrayList<ArrayList<float[]>> originalAllLines = new ArrayList<ArrayList<float[]>>(); // すべての線の軌跡を格納
    for (int i=0; i<targetAllLines.size(); i++) {
      ArrayList<float[]> originalDrawedLine = new ArrayList<float[]>(); // 1本の線の軌跡を記録
      for (int j=0; j<targetAllLines.get(i).size(); j++) {
        originalDrawedLine.add(targetAllLines.get(i).get(j).clone()); // 描画する点の軌跡を格納({x, y}形式)
      }
      originalAllLines.add(originalDrawedLine);
    }
    return originalAllLines;
  }


  void deleteFuturesHistory() {
    // 履歴の途中から上書きしたとき，その時点より後の履歴を消しておく
    for (int i=lastHistoryIndex; i>currentHistoryIndex; i--) {
      allLinesHistory.remove(i);
    }
    lastHistoryIndex = allLinesHistory.size()-1;
  }


  void drawLine(ArrayList<float[]> line) {
    noFill();
    beginShape();
    for (int i=0; i<line.size(); i++) {
      float _penX = constrain(line.get(i)[0], x-10, x+w+10);
      float _penY = constrain(line.get(i)[1], y-10, y+w+10);
      vertex(_penX, _penY);
    }
    endShape();
  }


  void writeCurrentHistory() {
    strokeWeight(0);
    fill(255);
    rect(x, y, w, h);
    // 履歴のなかで現在注目している世代のものを描く
    ArrayList<ArrayList<float[]>> currentLines = allLinesHistory.get(currentHistoryIndex);
    strokeWeight(4);
    for (int i=0; i<currentLines.size(); i++) {
      ArrayList<float[]> tmpLine = currentLines.get(i);
      drawLine(tmpLine);
    }
  }


  void recordCurrentCanvas(String fname) {
    if (isRunningNow && app.state==app.mandalaEditorState) {
      writeCurrentHistory();
      canvasImg = get(x, y, w, h);
      canvasImg.save(fname);
    }
  }


  void refreshCanvas() {
    if (allLines.size()>0) {
      deleteFuturesHistory();
      currentHistoryIndex++;
      lastHistoryIndex++;
      allLines = new ArrayList<ArrayList<float[]>>();
      allLinesHistory.add(cloneAllLines(allLines));
    }
  }


  void undoWriting() {
    println("undo");
    if (currentHistoryIndex>0) {
      // 注目する世代を1つ前に戻す
      currentHistoryIndex--;
      allLines = cloneAllLines(allLinesHistory.get(currentHistoryIndex));
    }
  }


  void redoWriting() {
    println("redo");
    if (currentHistoryIndex<lastHistoryIndex) {
      // 注目する世代を1つ次に進める
      currentHistoryIndex++;
      allLines = cloneAllLines(allLinesHistory.get(currentHistoryIndex));
    }
  }


  void clickFuncBtn() {
    if (isRunningNow&& !isShowingSaveAlert && !isShowingNoLineAlert && !isShowingDeleteAlert) {
      // 描画中の処理
      if (refreshBtnX<=mouseX && mouseX<=refreshBtnX+canvasFuncBtnW && refreshBtnY<=mouseY && mouseY<=refreshBtnY+canvasFuncBtnH) {
        canvas.refreshCanvas();
      } else if (undoBtnX<=mouseX && mouseX<=undoBtnX+canvasFuncBtnW && undoBtnY<=mouseY && mouseY<=undoBtnY+canvasFuncBtnH) {
        canvas.undoWriting();
      } else if (redoBtnX<=mouseX && mouseX<=redoBtnX+canvasFuncBtnW && redoBtnY<=mouseY && mouseY<=redoBtnY+canvasFuncBtnH) {
        canvas.redoWriting();
      } else if (saveBtnX<=mouseX && mouseX<=saveBtnX+canvasFuncBtnW && saveBtnY<=mouseY && mouseY<=saveBtnY+canvasFuncBtnH) {
        if (allLines.size()>0) {
          isShowingSaveAlert = true;
        } else {
          isShowingNoLineAlert = true;
        }
      } else if (exitBtnX<=mouseX && mouseX<=exitBtnX+canvasFuncBtnW && exitBtnY<=mouseY && mouseY<=exitBtnY+canvasFuncBtnH) {
        isShowingDeleteAlert = true;
      }
      canvas.writeCurrentHistory();
    } else if (isShowingSaveAlert || isShowingNoLineAlert || isShowingDeleteAlert) {
      // アラートを表示している時の処理
      if (isShowingSaveAlert && alertLeftBtnX<=mouseX && mouseX<=alertLeftBtnX+alertLeftBtnW && alertLeftBtnY<=mouseY && mouseY<=alertLeftBtnY+alertLeftBtnH) {
        // 保存するか訊くアラートで保存する選択をしたときの処理
        recordCurrentCanvas(targetSaveImgFname);
        app.changeMode(app.mandalaHome);
        if (currentEditingTaskIndex==4) {
          println("parent!!!!!");
          progress.pgresetCommittedTaskState();
        }
        // タスクのインデックスで保存する種類を判断するように変更
      } else if (isShowingSaveAlert && alertRightBtnX<=mouseX && mouseX<=alertRightBtnX+alertRightBtnW && alertRightBtnY<=mouseY && mouseY<=alertRightBtnY+alertRightBtnH) {
        // 保存するか訊くアラートで保存しないときの処理
        removeAlert();
      } else if (isShowingNoLineAlert && alertCenterLargeBtnX<=mouseX && mouseX<=alertCenterLargeBtnX+alertCenterLargeBtnW && alertCenterLargeBtnY<=mouseY && mouseY<=alertCenterLargeBtnY+alertCenterLargeBtnH) {
        // 描画がないアラートが出たときの処理
        removeAlert();
      } else if (isShowingDeleteAlert && alertLeftBtnX<=mouseX && mouseX<=alertLeftBtnX+alertLeftBtnW && alertLeftBtnY<=mouseY && mouseY<=alertLeftBtnY+alertLeftBtnH) {
        // 描画を保存しないときの処理
        init();
        app.changeMode(app.mandalaHome);
      } else if (isShowingDeleteAlert && alertRightBtnX<=mouseX && mouseX<=alertRightBtnX+alertRightBtnW && alertRightBtnY<=mouseY && mouseY<=alertRightBtnY+alertRightBtnH) {
        // 描画をまだ書き続ける時の処理
        removeAlert();
      }
    }
  }


  void drawingOnCanvas() {
    if (isRunningNow  && !isShowingDeleteAlert && x<=mouseX && mouseX<=x+w && y<=mouseY && mouseY<=y+h) {
      float[] mousePositions = new float[2];
      mousePositions[0] = mouseX;
      mousePositions[1] = mouseY;
      drawedLine.add(mousePositions);
    }
    drawLine(drawedLine);
  }


  void releaseFromCanvas() {
    if (drawedLine.size()>0) {
      deleteFuturesHistory();
      allLines.add(drawedLine);
      allLinesHistory.add(cloneAllLines(allLines));
      currentHistoryIndex++;
    }
    lastHistoryIndex = allLinesHistory.size()-1;
    drawedLine = new ArrayList<float[]>();
  }


  void showSaveAlert() {
    strokeWeight(0);

    // alert flame
    fill(255, 255, 255, 220);
    rect(30, 470, 420, 140);

    // go back home btn
    fill(255, 255, 64);
    rect(alertLeftBtnX, alertLeftBtnY, alertLeftBtnW, alertLeftBtnH);

    // not go back home btn
    fill(210);
    rect(alertRightBtnX, alertRightBtnY, alertRightBtnW, alertRightBtnH);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("タスクを保存する？", 240, 510);
    text("保存する", 140, 570);
    text("保存しない", 340, 570);
  }


  void showNoLineAlert() {
    strokeWeight(0);

    // alert flame
    fill(255, 255, 255, 220);
    rect(30, 470, 420, 140);

    // go back home btn
    fill(255, 64, 64);
    rect(alertCenterLargeBtnX, alertCenterLargeBtnY, alertCenterLargeBtnW, alertCenterLargeBtnH);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("何も描いてないよ？舐めてる？？", 240, 510);
    text("戻る", 240, 570);
  }


  void showDeleteAlert() {
    strokeWeight(0);
    // alert flame
    fill(255, 255, 255, 220);
    rect(30, 470, 420, 140);

    // go back home btn
    fill(255, 64, 64);
    rect(alertLeftBtnX, alertLeftBtnY, alertLeftBtnW, alertLeftBtnH);

    // not go back home btn
    fill(210);
    rect(alertRightBtnX, alertRightBtnY, alertRightBtnW, alertRightBtnH);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("保存せず戻りますか？", 240, 510);
    text("戻る", 140, 570);
    text("戻らない", 340, 570);
  }


  void show() {
    //background(192, 255, 192);
    stroke(0);
    if (isRunningNow) {
      if (!isShowingSaveAlert && !isShowingNoLineAlert && !isShowingDeleteAlert) {
        strokeWeight(2);

        // display save button
        fill(255, 192, 255);
        rect(saveBtnX, saveBtnY, canvasFuncBtnW, canvasFuncBtnH, 5);
        image(loadImage(dataPath("imgs/save.png")), saveBtnX, saveBtnY);

        // exit canvas button
        fill(255, 64, 64);
        rect(exitBtnX, exitBtnY, canvasFuncBtnW, canvasFuncBtnH, 5);
        image(loadImage(dataPath("imgs/exit.png")), exitBtnX, exitBtnY);

        // display refresh button
        fill(255, 192, 192);
        rect(refreshBtnX, refreshBtnY, canvasFuncBtnW, canvasFuncBtnH, 5);
        image(loadImage(dataPath("imgs/refresh.png")), refreshBtnX, refreshBtnY);

        // display undo button
        fill(192, 192, 255);
        rect(undoBtnX, undoBtnY, canvasFuncBtnW, canvasFuncBtnH, 5);
        image(loadImage(dataPath("imgs/undo.png")), undoBtnX, undoBtnY);

        // display redo button
        fill(255, 255, 192);
        rect(redoBtnX, redoBtnY, canvasFuncBtnW, canvasFuncBtnH, 5);
        image(loadImage(dataPath("imgs/redo.png")), redoBtnX, redoBtnY);
      }
      writeCurrentHistory();

      if (isShowingSaveAlert) {
        showSaveAlert();
      } else if (isShowingNoLineAlert) {
        showNoLineAlert();
      } else if (isShowingDeleteAlert) {
        showDeleteAlert();
      }
    }
  }
}
