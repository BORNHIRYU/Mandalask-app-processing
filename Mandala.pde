class Mandala {
  final String parentImgFname = "tasks/parentTask.png";
  final String tasksProgressJsonFname = "data/tasks_progress.json";
  final int[][] taskElmPositions = {
    {20, 40}, {170, 40}, {320, 40},
    {20, 190}, {170, 190}, {320, 190},
    {20, 340}, {170, 340}, {320, 340},
  };
  final int imgWidth = 140;
  final int imgHeight = 140;
  final int childTaskMenuBtnW = 40;
  final int childTaskMenuBtnH = 30;
  final int bottomAlertleftBtnX = 40;
  final int bottomAlertleftBtnY = 565;
  final int bottomAlertleftBtnW = 190;
  final int bottomAlertleftBtnH = 50;
  final int bottomAlertRightBtnX = 250;
  final int bottomAlertRightBtnY = 565;
  final int bottomAlertRightBtnW = 190;
  final int bottomAlertRightBtnH = 50;
  final int bottomAlertSoloBtnX = 40;
  final int bottomAlertSoloBtnY = 565;
  final int bottomAlertSoloBtnW = 400;
  final int bottomAlertSoloBtnH = 50;
  final int checkConfirmLowerRightBtnX = 320;
  final int checkConfirmLowerRightBtnY = 580;
  final int checkConfirmLowerRightBtnW = 140;
  final int checkConfirmLowerRightBtnH = 40;
  int showDelChildTaskAlertBtnX, showDelChildTaskAlertBtnY, modifyChildTaskBtnX, modifyChildTaskBtnY;
  JSONObject tasksProgress;
  PImage parentTaskImg;
  boolean[] childrenTasksProgresses;
  boolean alreadyConfirmedChildrenTasks;
  boolean isExistParentTaskImg;
  int focusedTaskElmIndex;
  int focusedChildTaskNum;
  boolean isExistChildrenTask;
  boolean isConfirmedAllChildrenTasks;
  boolean isCompletedAllChildrenTasks;
  boolean isDisplayDelChildTaskAlert;
  boolean isDisplayConfirmTaskAlert;
  boolean isDisplayCommitTaskAlert;


  Mandala() {
    isExistChildrenTask = false;
    isConfirmedAllChildrenTasks = false;
    isCompletedAllChildrenTasks = false;
    isDisplayDelChildTaskAlert = false;
    isDisplayConfirmTaskAlert = false;
    isDisplayCommitTaskAlert = false;
  }


  void init() {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    alreadyConfirmedChildrenTasks = progress.pggetChildrenTaskIsConfirmedfromJSON();
    isDisplayDelChildTaskAlert = false;
    isDisplayConfirmTaskAlert = false;
    isDisplayCommitTaskAlert = false;
    focusedTaskElmIndex = -1;
  }


  void detectDataDiffFromJSON() {
    int childTaskIndex = 0;
    boolean isMatchDataFromJSON = true;
    for (int taskIndex=0; taskIndex<9; taskIndex++) {
      if (taskIndex==4) {
        // 親タスクの処理
        isExistParentTaskImg = Files.exists(Paths.get(dataPath(parentImgFname)));
        boolean isExistParentTaskImgfromJSON = progress.pggetParentTaskIsExist();
        if (isExistParentTaskImgfromJSON!=isExistParentTaskImg) {
          progress.pgsetParentTaskIsExist();
          isMatchDataFromJSON = false;
        }
      } else {
        // 子タスクの処理
        boolean[] childrenTasksProgressfromJSON = progress.pggetExistChildrenTask();
        boolean isMatchChildTaskDataFromJSON = childrenTasksProgresses[childTaskIndex]==childrenTasksProgressfromJSON[childTaskIndex];
        isMatchDataFromJSON = isMatchDataFromJSON && isMatchChildTaskDataFromJSON;
        childTaskIndex++;
      }
    }
    if (!isMatchDataFromJSON) {
      // JSONファイルに記録
      JSONArray jsonChildrenTasksProgresses = new JSONArray();
      for (int j=0; j<childrenTasksProgresses.length; j++) {
        jsonChildrenTasksProgresses.setBoolean(j, childrenTasksProgresses[j]);
      }
      progress.pgsetExistChildrenTask(jsonChildrenTasksProgresses);
    }
  }


  void resetTasksProgress() {
    JSONArray completedChildrenTasksArray = new JSONArray();
    String childTaskImgFname;
    for (int i=0; i<8; i++) {
      int childTaskNum = i+1;
      childTaskImgFname = dataPath("tasks/childrenTask" + childTaskNum +".png");
      completedChildrenTasksArray.append(!isExistTheFile(childTaskImgFname));
      println(childTaskNum, isExistTheFile(childTaskImgFname));
    }
    tasksProgress.setJSONArray("isCompletedChildrenTasks", completedChildrenTasksArray);
    saveJSONObject(tasksProgress, tasksProgressJsonFname);
  }


  void setMandalaData() {
    alreadyConfirmedChildrenTasks = progress.pggetChildrenTaskIsConfirmedfromJSON();
    focusedTaskElmIndex = -1;
    detectDataDiffFromJSON();
  }


  void displayParentTaskElm() {
    final int parentImgPosX = taskElmPositions[4][0];
    final int parentImgPosY = taskElmPositions[4][1];
    childrenTasksProgresses = progress.pggetExistChildrenTask();
    isExistParentTaskImg = isExistTheFile(dataPath(parentImgFname));
    if (isExistParentTaskImg) {
      parentTaskImg = loadImage(dataPath(parentImgFname));
      image(parentTaskImg, parentImgPosX, parentImgPosY, imgWidth, imgHeight);
    } else {
      fill(160);
      strokeWeight(0);
      rect(parentImgPosX, parentImgPosY, imgWidth, imgHeight);
      fill(255);
      textSize(16);
      textAlign(CENTER, CENTER);
      text("最終的な\n目標を作成", parentImgPosX+imgWidth/2, parentImgPosY+imgHeight/2);
    }
  }


  void displayChildrenTaskElm() {
    int childTaskIndex = 0;
    int childTaskNum = 1;
    isExistChildrenTask = false;
    boolean tmp_isCompletedAllChildrenTasks = true;
    boolean[] isCompletedChildrenTasksArray = progress.pggetArrayChildrenTaskIsCompleted();
    for (int taskIndex=0; taskIndex<9; taskIndex++) {
      if (taskIndex==4) {
        // 親タスクを除外
        continue;
      }
      int[] childTaskImgPos = taskElmPositions[taskIndex];
      int childTaskImgX = childTaskImgPos[0];
      int childTaskImgY = childTaskImgPos[1];
      String childTaskImgFname = "tasks/childrenTask" + childTaskNum +".png";
      String childTaskImgPath = dataPath(childTaskImgFname);
      boolean isExistChildImg = isExistTheFile(childTaskImgPath);
      childrenTasksProgresses[childTaskIndex] = isExistChildImg;
      boolean isCompletedChildTask = isCompletedChildrenTasksArray[childTaskIndex];

      // 子タスクの完了判定
      if (isExistChildImg && !isCompletedChildTask) {
        tmp_isCompletedAllChildrenTasks = false;
      }
      if (isExistParentTaskImg && isExistChildImg) {
        isExistChildrenTask = true;
      }

      // 子タスクの表示
      if (isExistParentTaskImg && isExistChildImg) {
        // 親タスクと子タスクの画像が存在するときの表示
        PImage childTaskImg = loadImage(childTaskImgPath);
        image(childTaskImg, childTaskImgX, childTaskImgY, imgWidth, imgHeight);
        if (alreadyConfirmedChildrenTasks && isCompletedChildTask) {
          strokeWeight(0);
          fill(0, 0, 0, 128);
          rect(childTaskImgX, childTaskImgY, imgWidth, imgHeight);
        }
      } else if (isExistParentTaskImg && !isExistChildImg && !alreadyConfirmedChildrenTasks) {
        // 子タスクの画像がない&タスク未確定のときの表示
        fill(160);
        strokeWeight(0);
        rect(childTaskImgX, childTaskImgY, imgWidth, imgHeight);
        fill(255);
        textSize(16);
        textAlign(CENTER, CENTER);
        text("タスク"+(childTaskNum)+"\n作成", childTaskImgX+imgWidth/2, childTaskImgY+imgHeight/2);
      }

      // タスク確定後で選択した子タスクを強調する
      if (alreadyConfirmedChildrenTasks && taskIndex==focusedTaskElmIndex && isExistChildImg) {
        fill(0, 0, 0, 0);
        stroke(255, 0, 0);
        strokeWeight(2);
        rect(childTaskImgX, childTaskImgY, imgWidth, imgHeight);
      }

      childTaskIndex++;
      childTaskNum++;
    }

    isCompletedAllChildrenTasks = tmp_isCompletedAllChildrenTasks;
  }


  void displayChildTaskMenu() {
    int focusedTaskElmPosX, focusedTaskElmPosY;
    if (focusedTaskElmIndex>=0 && !alreadyConfirmedChildrenTasks) {
      focusedTaskElmPosX = taskElmPositions[focusedTaskElmIndex][0];
      focusedTaskElmPosY = taskElmPositions[focusedTaskElmIndex][1];
      showDelChildTaskAlertBtnX = focusedTaskElmPosX;
      showDelChildTaskAlertBtnY = focusedTaskElmPosY+imgHeight-childTaskMenuBtnH;
      modifyChildTaskBtnX = focusedTaskElmPosX+imgWidth-childTaskMenuBtnW;
      modifyChildTaskBtnY = focusedTaskElmPosY+imgHeight-childTaskMenuBtnH;
      fill(255, 0, 0, 128);
      rect(showDelChildTaskAlertBtnX, showDelChildTaskAlertBtnY, childTaskMenuBtnW, childTaskMenuBtnH);
      fill(255, 255, 0, 128);
      rect(modifyChildTaskBtnX, modifyChildTaskBtnY, childTaskMenuBtnW, childTaskMenuBtnH);
      fill(0);
      textSize(16);
      text("削除", showDelChildTaskAlertBtnX+childTaskMenuBtnW/2, showDelChildTaskAlertBtnY+childTaskMenuBtnH/2);
      text("変更", modifyChildTaskBtnX+childTaskMenuBtnW/2, modifyChildTaskBtnY+childTaskMenuBtnH/2);
    }
  }


  void displayTaskImg() {
    displayParentTaskElm();
    displayChildrenTaskElm();
    displayChildTaskMenu();
  }


  // alert
  void displayDelChildTaskAlert() {
    if (isDisplayDelChildTaskAlert) {
      // alert flame
      fill(255, 255, 255);
      rect(20, 490, 440, 150);
      // delete small task btn
      fill(255, 0, 0);
      rect(bottomAlertleftBtnX, bottomAlertleftBtnY, bottomAlertleftBtnW, bottomAlertleftBtnH);
      // don't delete small task btn
      fill(239);
      rect(bottomAlertRightBtnX, bottomAlertRightBtnY, bottomAlertRightBtnW, bottomAlertRightBtnH);
      fill(0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("タスク" + focusedChildTaskNum + "を削除しますか？", width/2, 490+40);
      fill(255);
      text("削除する", bottomAlertleftBtnX+bottomAlertleftBtnW/2, bottomAlertleftBtnY+bottomAlertleftBtnH/2);
      fill(0);
      text("削除しない", bottomAlertRightBtnX+bottomAlertRightBtnW/2, bottomAlertRightBtnY+bottomAlertRightBtnH/2);
    }
  }


  void displayCheckConfirmTaskAlert() {
    if (isDisplayConfirmTaskAlert) {
      fill(255, 255, 255);
      rect(20, 490, 440, 150);
      // confirm the tasks btn
      fill(255, 255, 128);
      rect(bottomAlertleftBtnX, bottomAlertleftBtnY, bottomAlertleftBtnW, bottomAlertleftBtnH);
      // don't confirm the tasks btn
      fill(224);
      rect(bottomAlertRightBtnX, bottomAlertRightBtnY, bottomAlertRightBtnW, bottomAlertRightBtnH);
      fill(0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("タスク入力を完了しますか？", width/2, 530);
      fill(0);
      text("完了する", bottomAlertleftBtnX+bottomAlertleftBtnW/2, bottomAlertleftBtnY+bottomAlertleftBtnH/2);
      text("まだしない", bottomAlertRightBtnX+bottomAlertRightBtnW/2, bottomAlertRightBtnY+bottomAlertRightBtnH/2);
    }
  }


  void displayCheckCommitTaskAlert() {
    if (isDisplayCommitTaskAlert) {
      stroke(255);
      strokeWeight(0);
      fill(255, 255, 255);
      rect(20, 490, 440, 150);
      // confirm the tasks btn
      fill(255, 255, 128);
      rect(bottomAlertleftBtnX, bottomAlertleftBtnY, bottomAlertleftBtnW, bottomAlertleftBtnH);
      // don't confirm the tasks btn
      fill(223);
      rect(bottomAlertRightBtnX, bottomAlertRightBtnY, bottomAlertRightBtnW, bottomAlertRightBtnH);
      fill(0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("タスク" + focusedChildTaskNum + "に取り組む？", width/2, 530);
      fill(0);
      text("取り組む", bottomAlertleftBtnX+bottomAlertleftBtnW/2, bottomAlertleftBtnY+bottomAlertleftBtnH/2);
      text("まだ", bottomAlertRightBtnX+bottomAlertRightBtnW/2, bottomAlertRightBtnY+bottomAlertRightBtnH/2);
    }
  }


  void selectParentTask() {
    isDisplayDelChildTaskAlert = false;
    int parentTaskImgPosX = taskElmPositions[4][0];
    int parentTaskImgPosY = taskElmPositions[4][1];
    if (!isExistParentTaskImg && parentTaskImgPosX<=mouseX&&mouseX<=parentTaskImgPosX+imgWidth && parentTaskImgPosY<=mouseY&&mouseY<=parentTaskImgPosY+imgHeight) {
      // 親タスクが未設定のとき作成画面に移動
      canvas.setTargetTaskByIndex(4);
      app.changeMode(app.mandalaEditorState);
    } else if (!isCompletedAllChildrenTasks && isExistParentTaskImg && parentTaskImgPosX<=mouseX&&mouseX<=parentTaskImgPosX+imgWidth && parentTaskImgPosY<=mouseY&&mouseY<=parentTaskImgPosY+imgHeight) {
      // タスクに取り組むアラートを非表示
      focusedTaskElmIndex = -1;
      isDisplayCommitTaskAlert = false;
    } else if (alreadyConfirmedChildrenTasks && isCompletedAllChildrenTasks && parentTaskImgPosX<=mouseX&&mouseX<=parentTaskImgPosX+imgWidth && parentTaskImgPosY<=mouseY&&mouseY<=parentTaskImgPosY+imgHeight) {
      // 子タスクをすべて完了したとき親タスクを完了する
      app.changeMode(app.completeParentTask);
    }
  }


  void selectChildrensTask() {
    int childrenTaskIndex = 0;
    for (int taskIndex=0; taskIndex<9; taskIndex++) {
      int[] taskImgPos = taskElmPositions[taskIndex];
      int taskImgPosX = taskImgPos[0];
      int taskImgPosY = taskImgPos[1];
      if (taskIndex==4) {
        // 親タスクを除外
        continue;
      } else if (isExistParentTaskImg) {
        if (taskIndex==focusedTaskElmIndex && showDelChildTaskAlertBtnX<=mouseX&&mouseX<=showDelChildTaskAlertBtnX+childTaskMenuBtnW && showDelChildTaskAlertBtnY<=mouseY&&mouseY<=showDelChildTaskAlertBtnY+childTaskMenuBtnH) {
          // タスク編集でタスク左下の角に出る削除ボタンを押すとき
          isDisplayDelChildTaskAlert = true;
        } else if (taskIndex==focusedTaskElmIndex && modifyChildTaskBtnX<=mouseX&&mouseX<=modifyChildTaskBtnX+childTaskMenuBtnW && modifyChildTaskBtnY<=mouseY&&mouseY<=modifyChildTaskBtnY+childTaskMenuBtnH) {
          // タスク編集でタスク左下の角に出る編集ボタンを押すとき
          String targetCreateTaskPath = dataPath("tasks/childrenTask" + (childrenTaskIndex+1) +".png");
          println(targetCreateTaskPath);
          canvas.targetSaveImgFname = targetCreateTaskPath;
          app.changeMode(app.mandalaEditorState);
          focusedTaskElmIndex = -1;
        } else if (taskImgPosX<=mouseX&&mouseX<=taskImgPosX+imgWidth && taskImgPosY<=mouseY&&mouseY<=taskImgPosY+imgHeight) {
          isDisplayDelChildTaskAlert = false;
          focusedTaskElmIndex = taskIndex;
          focusedChildTaskNum = childrenTaskIndex+1;
          boolean targetTaskIsExist = childrenTasksProgresses[childrenTaskIndex];
          boolean targetTaskIsCompleted = progress.pggetArrayChildrenTaskIsCompleted()[childrenTaskIndex];
          if (targetTaskIsExist && !alreadyConfirmedChildrenTasks) {
            // 目標の子タスクが存在する&タスク登録が未完了のときフォーカス
            focusedTaskElmIndex = taskIndex;
          } else if (!targetTaskIsExist && !alreadyConfirmedChildrenTasks) {
            // 目標の子タスクが空&タスク登録が未完了のとき作成画面へ
            String targetCreateTaskPath = dataPath("tasks/childrenTask" + (childrenTaskIndex+1) +".png");
            canvas.targetSaveImgFname = targetCreateTaskPath;
            app.changeMode(app.mandalaEditorState);
            focusedTaskElmIndex = -1;
          } else if (targetTaskIsExist && !targetTaskIsCompleted && alreadyConfirmedChildrenTasks) {
            // タスク登録が完了&タスクが未完了&目標の子タスクが存在するとき取り組むか訊く
            isDisplayCommitTaskAlert = true;
            focusedTaskElmIndex = taskIndex;
          } else {
            isDisplayCommitTaskAlert = false;
            focusedTaskElmIndex = -1;
          }
        }
        childrenTaskIndex++;
      }
    }
  }


  // type of tap action
  void detectDeleteChildTaskAlertOperation() {
    // タスク登録を確認するアラートの操作
    if (bottomAlertleftBtnX<=mouseX&&mouseX<=bottomAlertleftBtnX+bottomAlertleftBtnW && bottomAlertleftBtnY<=mouseY&&mouseY<=bottomAlertleftBtnY+bottomAlertleftBtnH) {
      String targetCreateTaskPath = dataPath("tasks/childrenTask" + focusedChildTaskNum +".png");
      File targetDelChildTaskImg = new File(targetCreateTaskPath);
      targetDelChildTaskImg.delete();
      isDisplayDelChildTaskAlert = false;
      focusedTaskElmIndex = -1;
    } else if (bottomAlertRightBtnX<=mouseX&&mouseX<=bottomAlertRightBtnX+bottomAlertRightBtnW && bottomAlertRightBtnY<=mouseY&&mouseY<=bottomAlertRightBtnY+bottomAlertRightBtnH) {
      isDisplayDelChildTaskAlert = false;
    }
  }

  void detectConfirmTaskAlertOperation() {
    // タスク登録を確認するアラートの操作
    if (bottomAlertleftBtnX<=mouseX&&mouseX<=bottomAlertleftBtnX+bottomAlertleftBtnW && bottomAlertleftBtnY<=mouseY&&mouseY<=bottomAlertleftBtnY+bottomAlertleftBtnH) {
      alreadyConfirmedChildrenTasks = true;
      isDisplayConfirmTaskAlert = false;
      tasksProgress.setBoolean("isConfirmedTasks", true);
      focusedTaskElmIndex = -1;
      resetTasksProgress();
      saveJSONObject(tasksProgress, tasksProgressJsonFname);
    } else if (bottomAlertRightBtnX<=mouseX&&mouseX<=bottomAlertRightBtnX+bottomAlertRightBtnW && bottomAlertRightBtnY<=mouseY&&mouseY<=bottomAlertRightBtnY+bottomAlertRightBtnH) {
      isDisplayConfirmTaskAlert = false;
    }
  }


  void detectCommitTaskAlertOperation() {
    if (bottomAlertleftBtnX<=mouseX&&mouseX<=bottomAlertleftBtnX+bottomAlertleftBtnW && bottomAlertleftBtnY<=mouseY&&mouseY<=bottomAlertleftBtnY+bottomAlertleftBtnH) {
      focusedTaskElmIndex = -1;
      isDisplayCommitTaskAlert = false;
      tclock.setChildTask(focusedChildTaskNum);
      app.changeMode(app.taskCommiting);
    } else if (bottomAlertRightBtnX<=mouseX&&mouseX<=bottomAlertRightBtnX+bottomAlertRightBtnW && bottomAlertRightBtnY<=mouseY&&mouseY<=bottomAlertRightBtnY+bottomAlertRightBtnH) {
      focusedTaskElmIndex = -1;
      isDisplayCommitTaskAlert = false;
    }
  }


  void detectTapActions() {
    if (mouseX<=80 && mouseY<=40) {
      app.changeMode(app.home);
    } else if (isDisplayDelChildTaskAlert) {
      detectDeleteChildTaskAlertOperation();
      println("a");
    } else if (isExistParentTaskImg && isDisplayConfirmTaskAlert) {
      println("b");
      detectConfirmTaskAlertOperation();
    } else if (isDisplayCommitTaskAlert) {
      println("c");
      detectCommitTaskAlertOperation();
    } else if (isExistChildrenTask && checkConfirmLowerRightBtnX<=mouseX&&mouseX<=checkConfirmLowerRightBtnX+checkConfirmLowerRightBtnW && checkConfirmLowerRightBtnY<=mouseY&&mouseY<=checkConfirmLowerRightBtnY+checkConfirmLowerRightBtnH) {
      println("d");
      isDisplayConfirmTaskAlert = true;
    }
    selectParentTask();
    selectChildrensTask();
  }


  void displayOtherUIs() {
    // go back home screen
    fill(0);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("< 戻る", 20, 20);
    if (!isDisplayDelChildTaskAlert && !isDisplayConfirmTaskAlert && !alreadyConfirmedChildrenTasks && isExistParentTaskImg && isExistChildrenTask) {
      fill(128, 255, 128);
      strokeWeight(0);
      rect(checkConfirmLowerRightBtnX, checkConfirmLowerRightBtnY, checkConfirmLowerRightBtnW, checkConfirmLowerRightBtnH);
      fill(0);
      textAlign(CENTER, CENTER);
      text("確定する", 390, 600);
    }

    if (!alreadyConfirmedChildrenTasks) {
      displayDelChildTaskAlert();
      if (isExistParentTaskImg) {
        displayCheckConfirmTaskAlert();
      }
    } else {
      displayCheckCommitTaskAlert();
    }
  }


  void show() {
    //background(255, 255, 128);
    displayTaskImg();
    detectDataDiffFromJSON();
    displayOtherUIs();
  }
}
