package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;

using Lambda;

typedef MenuData = { title:String, func:Void->Void };

class Menu extends FlxSpriteGroup {
	var _selected:Int = 0;
	var _pointer:FlxSprite;
	var _spacing:Int = 75;
	var _menuData:Array<MenuData>;
	var _preventKeyPress:Bool = false;
	var _controls:Controls;
	var _yPos:Float;

	// Sounds
	var _sndMove:FlxSound;
	var _sndSelect:FlxSound;

	/**
	 * Generic menu class
	 *
	 * @param XPos				X position of menu
	 * @param YPos				Y position of menu
	 * @param MenuWidth		Width for menu
	 * @param Data				Collectable data
	 * @param	CenterText	If text should be centered or not
	 */
	public function new(
		XPos:Float, 
		YPos:Float, 
		MenuWidth:Int = 0, 
		Data:Array<MenuData>,
		?CenterText:Bool = false
	) {
		super();
		_menuData = Data;
		_yPos = YPos;

		//Sounds
		_sndMove = FlxG.sound.load("assets/sounds/menu_move.wav");
		_sndSelect = FlxG.sound.load("assets/sounds/menu_selected.wav");
	
		// Pointer
		_pointer = new FlxSprite(XPos, YPos - 15);
		_pointer.makeGraphic(MenuWidth, _spacing, Constants.secondaryColor);
		add(_pointer);

		// Text Choices
		_menuData.mapi((idx:Int, data:MenuData) -> {
			var choice = new FlxText(XPos, YPos + (_spacing * idx), 0, data.title);
			choice.setFormat(Constants.squareFont, Constants.medFont);

			if (CenterText) choice.screenCenter(X);
			choice.scrollFactor.set(0, 0);
			add(choice);
		});

		// Intialise controls
		_controls = new Controls();	
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		var _lastOption:Int = _menuData.length - 1;
		if(!_preventKeyPress) {
			if (_controls.cross.check()) {
				_sndSelect.play();
				_menuData[_selected].func();
			}

			if (_controls.down.check()) {
				if (_selected != _lastOption) {
					_pointer.y = _pointer.y + _spacing;
					_selected++;
				} else {
					_pointer.y = _yPos - 15;
					_selected = 0;
				}
			}

			if (_controls.up.check()) {
				if (_selected != 0) {
					_pointer.y = _pointer.y - _spacing;
					_selected--;
				} else {
					_pointer.y = _pointer.y + (_spacing * _lastOption);
					_selected = _lastOption;
				}
			}

			if (_controls.up.check() || _controls.down.check()) {
				_sndMove.play(true);
			}
		}
	}

	public function hide() {
		_preventKeyPress = true;
		this.forEach((Item:FlxSprite) -> {
			Item.alpha = 0;
		});
	}

	public function show() {
		_preventKeyPress = false;
		this.forEach((Item:FlxSprite) -> {
			Item.alpha = 1;
		});
	}

	public function fadeIn() {
		FlxTween.tween(this, {alpha: 1}, 1, {ease: FlxEase.backOut});
	}	
}

class BottomLeft extends FlxText {
	/**
	 * Simple class to display text on the bottom left of the screen
	 */
	public function new() {
		super(20, FlxG.height - 75);
		// var gamepad = FlxG.gamepads.lastActive;
		// trace(gamepad.model.getName());
		// http://api.haxeflixel.com/flixel/input/gamepad/FlxGamepadModel.html

		text = "[SPACE] SELECT \n[E] BACK or Close";
		fieldWidth = 200;
		scrollFactor.set(0, 0);
		setFormat(Constants.squareFont, Constants.smlFont);
		
	}
}

class BottomRight extends FlxText {
	/**
	 * Simple class to display text on the bottom right of the screen
	 */	
	public function new() {
		super(FlxG.width - 100, FlxG.height - 50);
		text = Constants.projectVersion;
		scrollFactor.set(0, 0);
		setFormat(Constants.squareFont, Constants.smlFont);
	}
}
