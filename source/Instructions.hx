package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxG;

class Instructions extends FlxSubState {
  var _gameOverlay:FlxSprite;
  var _controls:Controls;
  var _page1:FlxSprite;
  var _page2:FlxSprite;

  public function new() {
    super();
    _page1 = new FlxSprite(20, 20);
    _page1.makeGraphic(1060, 1900, FlxColor.RED);
    add(_page1);

    // Opaque black background overlay
    _gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
    add(_gameOverlay);

		// Intialise controls
		_controls = new Controls();    
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Exit instructions
		if (_controls.start.check()) {
			toggleInstructionsMenu();
		}    
  }

	function toggleInstructionsMenu() {
		FlxG.sound.music.play();
		close();
	}  
}