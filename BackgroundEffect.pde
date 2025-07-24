class BackgroundEffect {
  final int rectW = 40;
  final int rectH = 40;
  final int rectOffset = 12;
  final int upperLeftRectX = 12;
  final int upperLeftRectY = 92;
  int rectX, rectY;
  final float baseRectSaturation = 0;
  final float baseRectBrightness = 239;
  float rectHue, rectSaturation, rectBrightness;
  int rectSaturationVelocity;
  int focusedRectIndex;
  color gradations;


  BackgroundEffect() {
    rectHue = random(255);
    rectSaturation = 0;
    rectSaturationVelocity = 2;
    focusedRectIndex = int(random(81));
  }


  void displayGradation() {
    noStroke();
    for (int i=0; i<240; i++) {
      for (int j=0; j<320; j++) {
        gradations = lerpColor(color(255, 192, 192), color(192, 192, 255), (i+j)/(560.));
        fill(gradations);
        rect(i*2, j*2, 2, 2);
      }
    }
  }


  void show() {
    displayGradation();

    noStroke();
    colorMode(HSB);

    for (int i=0; i<9; i++) {
      for (int j=0; j<9; j++) {
        int rectIndex = i*9+j;
        if (rectIndex==focusedRectIndex) {
          // 色が変わる矩形を表示
          fill(rectHue, rectSaturation, rectBrightness);
        } else {
          // 灰色の矩形を表示
          fill(rectHue, baseRectSaturation, baseRectBrightness);
        }
        rectX = upperLeftRectX + j*(rectW+rectOffset);
        rectY = upperLeftRectY + i*(rectH+rectOffset);
        rect(rectX, rectY, rectW, rectH);
      }
    }
    rectSaturation += rectSaturationVelocity;
    rectBrightness = map(rectSaturation, baseRectSaturation, 64, baseRectBrightness, 255);

    if (rectSaturation>=96) {
      rectSaturationVelocity = -abs(rectSaturationVelocity);
    } else if (rectSaturation<=0) {
      focusedRectIndex = int(random(81));
      rectSaturationVelocity = abs(rectSaturationVelocity);
      rectHue = random(255);
    }

    colorMode(RGB);
  }
}
