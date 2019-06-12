package;

import flixel.FlxG;
import flixel.FlxBasic;

class Globals extends FlxBasic {
  override public function update(elapsed:Float):Void {
    public static var jump:Bool = FlxG.keys.anyJustPressed([SPACE, UP, W]);
    super.update(Elapsed);
  }
}