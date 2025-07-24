// ファイルの存在などを扱える便利機能
// 画像が存在するかどうかの判定に使用
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;

AppController app;
Mandala mandala;
Canvas canvas;
TaskClock tclock;
TaskLog tlog;
Progress progress;
BackgroundEffect bgEffect;
CompleteParentTaskEffect cpt;
final String notoSansJpFname = "NotoSansJP-Medium.otf";
final String taskLogTableFname = "data/committed_tasks_log.csv";
PFont NotoSansJP;


void setup() {
  size(480, 640);
  NotoSansJP = createFont(notoSansJpFname, 36);
  textFont(NotoSansJP);

  app = new AppController();
  mandala = new Mandala();
  canvas = new Canvas();
  tclock = new TaskClock();
  tlog = new TaskLog();
  progress = new Progress();
  bgEffect = new BackgroundEffect();
  cpt = new CompleteParentTaskEffect();
  canvas.init();
}


void draw() {
  app.run();
}


void keyPressed() {
  if (key=='h') {
    app.changeMode(app.home);
  } else if (key=='e') {
    app.changeMode(app.mandalaEditorState);
  }
}


void mouseClicked() {
  if (app.state==app.taskCommiting) {
    tclock.detectTapActions();
  } else if (app.state==app.taskLogViewer) {
    tlog.detectTapActions();
  } else if (app.state==app.completeParentTask) {
    cpt.detectTapOperation();
  } else if (app.state==app.home) {
    app.detectTapActions();
  }
}


void mousePressed() {
  if (app.state==app.mandalaHome) {
    mandala.detectTapActions();
  } else if (app.state==app.mandalaEditorState) {
    canvas.clickFuncBtn();
  }
}


void mouseDragged() {
  if (app.state==app.mandalaEditorState) {
    canvas.drawingOnCanvas();
  } else if (app.state==app.taskCommiting) {
    tclock.detectSwipeActions();
  } else if (app.state==app.taskLogViewer) {
    tlog.swipe();
  }
}


void mouseReleased() {
  if (app.state==app.mandalaEditorState) {
    canvas.releaseFromCanvas();
  } else if (app.state==app.taskCommiting) {
    tclock.detectReleaseAction();
  } else if (app.state==app.taskLogViewer) {
    tlog.release();
  }
}


String formatTaskTimeTxt(int hour, int minute, int second) {
  return nf(hour, 2)+":"+nf(minute, 2)+":"+nf(second, 2);
}


boolean isExistTheFile(String fname) {
  return Files.exists(Paths.get(fname));
}
