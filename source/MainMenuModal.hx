package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;

class MainMenuModal extends FlxSubState {
	var _displayText:FlxText;
	var _boundingBox:FlxSprite;
	var _gameOverlay:FlxSprite;
	var _menuWidth:Int = 800;
	var _menuHeight:Int = 450;
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
		// add(_gameOverlay);

		_boundingBox = new FlxSprite((FlxG.width / 2) - (_menuWidth / 2), (FlxG.height / 2) - (_menuHeight / 2));
		_boundingBox.makeGraphic(_menuWidth, _menuHeight, Constants.primaryColor);
		add(_boundingBox);

		_displayText = new FlxText(0, 400, _menuWidth - 40, Text, Constants.medFont);
		_displayText.screenCenter(X);
		add(_displayText);

		if (ShowOptions) {
			_optionsText = new FlxText(0, _displayText.y + 250, _menuWidth - 40, "Press SPACE for yes", Constants.medFont);
			_optionsText.setFormat(Constants.squareFont, Constants.medFont);
			_optionsText.screenCenter(X);
			add(_optionsText);
		}

		// Intialise controls
		_controls = new Controls();		
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);

		if (_controls.triangle.check()) {
			close();
		}

		if (_controls.cross.check()) {
			if (_confirmCallback != null)
				_confirmCallback();
		}
	}
}
