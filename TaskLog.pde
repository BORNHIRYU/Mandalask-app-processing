class TaskLog {
  boolean isSwipeOnLog = false;
  String[] dates;
  int[] hours, minutes, seconds;
  int rowCount;
  int tlx, tly, tlw, tlh;
  int size;
  int headerHeight, footerHeight, dataZoneMarginTop;
  String taskTimeTxt;
  int pureAllHours, pureAllMinutes, pureAllSeconds, allHours, allMinutes, allSeconds;
  int firstFingerPosX, firstFingerPosY, swipeDiffY;


  TaskLog() {
    isSwipeOnLog = false;
    rowCount = 0;
    tlx = 200;
    tly = 48;
    tlw = 10;
    tlh = 10;
    size = 24;
    headerHeight = 40;
    footerHeight = 40;
    dataZoneMarginTop = 8;
  }


  void setRowCount() {
    Table t = loadTable(taskLogTableFname);
    t.addColumn("date");
    t.addColumn("hour");
    t.addColumn("minutes");
    t.addColumn("seconds");
    t.sort(0);
    rowCount = t.getRowCount();
  }


  void detectTapActions() {
    if (mouseX<=80 && mouseY<=40) {
      app.changeMode(app.home);
    }
  }


  void swipe() {
    if (!isSwipeOnLog) {
      firstFingerPosX = mouseX;
      firstFingerPosY = mouseY;
      isSwipeOnLog = true;
    }
    swipeDiffY = mouseY - firstFingerPosY;
  }


  void release() {
    tly += swipeDiffY;
    tly = constrain(tly, headerHeight+8-(24*(rowCount+2)-height)-footerHeight, 48);
    swipeDiffY = 0;
    isSwipeOnLog = false;
  }


  void getTaskLog() {
    pureAllHours = pureAllMinutes = pureAllSeconds = 0;
    fill(0);
    textSize(size);
    Table t = loadTable(taskLogTableFname);
    rowCount = t.getRowCount();
    int[] hours = new int[rowCount];
    int[] minutes = new int[rowCount];
    int[] seconds = new int[rowCount];
    for (int i=0; i<rowCount; i++) {
      String _dates_i = t.getString(i, 0);
      int _task_hours_i = t.getInt(i, 1);
      int _task_minutes_i = t.getInt(i, 2);
      int _task_seconds_i = t.getInt(i, 3);
      hours[i] = _task_hours_i;
      minutes[i] = _task_minutes_i;
      seconds[i] = _task_seconds_i;
      pureAllHours += _task_hours_i;
      pureAllMinutes += _task_minutes_i;
      pureAllSeconds += _task_seconds_i;
      taskTimeTxt = formatTaskTimeTxt(_task_hours_i, _task_minutes_i, _task_seconds_i);
      textAlign(LEFT, TOP);

      int data_disp_y;
      if (headerHeight+footerHeight+24*(rowCount+2)<height) {
        data_disp_y = 48+i*24;
      } else {
        data_disp_y = constrain(tly+swipeDiffY, headerHeight+8-(24*(rowCount+2)-height)-footerHeight, 48) + (rowCount-i-1)*24;
      }
      text(_dates_i, 40, data_disp_y);
      text(taskTimeTxt, 320, data_disp_y);
    }
    
    // タスクに取り組んだ時間の合計を計算
    allSeconds = pureAllSeconds%60;
    pureAllMinutes += (pureAllSeconds-allSeconds)/60;
    allMinutes = pureAllMinutes%60;
    pureAllHours += (pureAllMinutes-allMinutes)/60;
    allHours = pureAllHours;
  }


  void show() {
    fill(255, 255, 255, 192);
    rect(0, 0, width, height);

    setRowCount();
    getTaskLog();

    fill(255);
    rect(0, 0, width, headerHeight);
    rect(0, height-footerHeight, width, footerHeight);
    fill(0);
    textAlign(CENTER, CENTER);
    text("タスク時間データ", width/2, headerHeight/2);
    text("がんばった時間: "+str(allHours)+"時間"+str(allMinutes)+"分"+str(allSeconds)+"秒", width/2, height-footerHeight/2);

    fill(0);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("< 戻る", 20, 20);
  }
}
