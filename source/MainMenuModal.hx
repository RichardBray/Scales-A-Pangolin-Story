package;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.addons.display.shapes.FlxShapeBox;

class MainMenuModal extends FlxSubState {
	var _displayText:FlxText;
	var _boundingBox:FlxShapeBox;
	var _gameOverlay:FlxSprite;
	var _menuWidth:Int = 800;
	var _menuHeight:Int = 450;
	var _optionsText:FlxText;
	var _confirmCallback:Null<Void->Void>;
	var _controls:Controls;

	var _sndClose:FlxSound; 

	/**
	 * @param Text						Text that goes in modal
	 * @param ConfirmCallback	What function to run when the player hits confirm
	 * @param ShowOptions			Whether the modal has `press button for yes` text
	 * @param OptionsText			Text for `press button for yes` if something different is desired
	 */
	public function new(
		Text:String, 
		?ConfirmCallback:Void->Void, 
		ShowOptions:Bool = false, 
		?OptionsText:String = "Press SPACE for yes"
	):Void {
		super();
		_confirmCallback = ConfirmCallback;

		_gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x75000000);
		add(_gameOverlay);

		_boundingBox = new FlxShapeBox(
			(FlxG.width / 2) - (_menuWidth / 2), 
			(FlxG.height / 2) - (_menuHeight / 2),
			_menuWidth,
			_menuHeight,
			{ thickness:8, color:Constants.primaryColorLight }, 
			Constants.primaryColor
		);
		add(_boundingBox);

		_displayText = new FlxText(0, 350, _menuWidth - 40, Text);
		_displayText.setFormat(Constants.squareFont, Constants.medFont);
		_displayText.screenCenter(X);
		add(_displayText);

		if (ShowOptions) {
			_optionsText = new FlxText(0, _displayText.y + 350, _menuWidth - 40, OptionsText);
			_optionsText.setFormat(Constants.squareFont, Constants.hudFont);
			_optionsText.screenCenter(X);
			add(_optionsText);
		}

		// Intialise controls
		_controls = new Controls();	

		_sndClose = FlxG.sound.load(Constants.sndMenuClose);				
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);

		if (_controls.triangle.check()) {
			_sndClose.play();
			close();
		}

		if (_controls.cross.check()) {
			if (_confirmCallback != null)
				_confirmCallback();
		}
	}
}
