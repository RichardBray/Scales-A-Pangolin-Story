package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;

class MainMenuModal extends FlxSubState {
	var _displayText:FlxText;
	var _boundingBox:FlxSprite;
	var _gameOverlay:FlxSprite;
	var _menuWidth:Int = 750;
	var _menuHeight:Int = 422;
	var _optionsText:FlxText;
	var _confirmCallback:Void->Void;
	var _controls:Controls;

	/**
	 * @param Text						Text that goes in modal
	 * @param ConfirmCallback	What function to run when the player hits confirm
	 * @param ShowOptions			Whether the modal has options or not
	 */
	public function new(Text:String, ?ConfirmCallback:Void->Void, ShowOptions:Bool = false):Void {
		super();
		_confirmCallback = ConfirmCallback;

		_gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
		add(_gameOverlay);

		_boundingBox = new FlxSprite((FlxG.width / 2) - (_menuWidth / 2), (FlxG.height / 2) - (_menuHeight / 2));
		_boundingBox.makeGraphic(_menuWidth, _menuHeight, 0xff205ab7);
		add(_boundingBox);

		_displayText = new FlxText(20, 250, 675, Text, 30);
		_displayText.screenCenter(X);
		add(_displayText);

		if (ShowOptions) {
			_optionsText = new FlxText(20, 350, 675, "Press SPACE for yes", 30);
			_optionsText.screenCenter(X);
			add(_optionsText);
		}

		// Intialise controls
		_controls = new Controls();		
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		if (_controls.start.check() || _controls.triangle.check()) {
			close();
		}

		if (_controls.cross.check()) {
			if (_confirmCallback != null)
				_confirmCallback();
		}
	}
}
