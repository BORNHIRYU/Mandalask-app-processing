class Progress {
  final String tasksProgressJsonFname = "data/tasks_progress.json";
  final String parentImgFname = "tasks/parentTask.png";
  JSONObject tasksProgress;


  boolean pggetParentTaskIsExist() {
    boolean isExistParentTaskImg = Files.exists(Paths.get(dataPath(parentImgFname)));
    return isExistParentTaskImg;
  }


  void pgsetParentTaskIsExist() {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    tasksProgress.setBoolean("isExistParentTask", pggetParentTaskIsExist());
    saveJSONObject(tasksProgress, tasksProgressJsonFname);
  }


  boolean[] pggetExistChildrenTask() {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    return tasksProgress.getJSONArray("isExistChildrenTasks").getBooleanArray();
  }


  boolean pggetChildrenTaskIsConfirmedfromJSON() {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    boolean alreadyConfirmedChildrenTasks = tasksProgress.getBoolean("isConfirmedTasks");
    return alreadyConfirmedChildrenTasks;
  }


  void pgsetExistChildrenTask(JSONArray jsonChildrenTasksProgresses) {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    tasksProgress.setJSONArray("isExistChildrenTasks", jsonChildrenTasksProgresses);
    saveJSONObject(tasksProgress, tasksProgressJsonFname);
  }


  void pgsetCompletedChildTask(int completedChildTaskIndex) {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    boolean[] prevCompletedChildrenTasks = tasksProgress.getJSONArray("isCompletedChildrenTasks").toBooleanArray();
    JSONArray currentCompletedChildrenTasks = new JSONArray();
    for (int i=0; i<8; i++) {
      if (i==completedChildTaskIndex) {
        currentCompletedChildrenTasks.append(true);
      } else {
        currentCompletedChildrenTasks.append(prevCompletedChildrenTasks[i]);
      }
    }
    tasksProgress.setJSONArray("isCompletedChildrenTasks", currentCompletedChildrenTasks);
    saveJSONObject(tasksProgress, tasksProgressJsonFname);
  }


  boolean[] pggetArrayChildrenTaskIsCompleted() {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    boolean[] childrenTaskIsCompleted = tasksProgress.getJSONArray("isCompletedChildrenTasks").toBooleanArray();
    return childrenTaskIsCompleted;
  }


  void pgresetCommittedTaskState() {
    tasksProgress = loadJSONObject(tasksProgressJsonFname);
    tasksProgress.setBoolean("isConfirmedTasks", false);
    JSONArray resetedCommittedTaskState = new JSONArray();
    for (int i=0; i<8; i++) {
      resetedCommittedTaskState.append(false);
    }
    tasksProgress.setJSONArray("isCompletedChildrenTasks", resetedCommittedTaskState);
    saveJSONObject(tasksProgress, tasksProgressJsonFname);
    mandala.isConfirmedAllChildrenTasks = false;
  }


  void addTaskCommitData(int startYear, int startMonth, int startDay, int startHour, int startMin, int startSec, int commitHour, int commitMin, int commitSec) {
    Table t = loadTable(taskLogTableFname);
    TableRow trow = t.addRow();
    final String START_DAY = startYear +"/"+ nf(startMonth, 2) +"/"+ nf(startDay, 2);
    final String START_TIME = nf(startHour, 2) + ":" + nf(startMin, 2) + ":" + nf(startSec, 2);
    final String START_DATE = START_DAY + " " + START_TIME;
    println(t.getRowCount(), t.getColumnCount(), START_DATE);
    trow.setString(0, START_DATE);
    trow.setString(1, str(commitHour));
    trow.setString(2, str(commitMin));
    trow.setString(3, str(commitSec));
    saveTable(t, taskLogTableFname);
  }


  void resetAllTasks() {
    File parentImg = new File(dataPath(parentImgFname));
    parentImg.delete();
    JSONObject tasksProgress = loadJSONObject(tasksProgressJsonFname);
    tasksProgress.setBoolean("isExistParentTask", false);
    JSONArray isExistChildrenTasks = new JSONArray();
    for (int i=1; i<9; i++) {
      File childImg = new File(dataPath("tasks/childrenTask" + i +".png"));
      isExistChildrenTasks.append(false);
      childImg.delete();
    }
    tasksProgress.setJSONArray("isExistChildrenTasks", isExistChildrenTasks);
    tasksProgress.setBoolean("isConfirmedTasks", false);

    saveJSONObject(tasksProgress, tasksProgressJsonFname);
    mandala.init();
    println("already reset!!!");
  }
}
