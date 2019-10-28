package components;


import flixel.FlxSprite;

class Lava extends FlxSprite {
  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);
    loadGraphic("assets/images/components/lava.png", true, 325, 124);

    // Animations
    animation.add("flow", [for (i in 0...11) i], 6, true);
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    animation.play("flow");
  }
}