package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

using Lambda;

typedef MenuData = {title:String, func:Void->Void};

class Menu extends FlxTypedGroup<FlxSprite> {
	var _selected:Int = 0;
	var _pointer:FlxSprite;
	var _spacing:Int = 75;
	var _menuData:Array<MenuData>;
	var _preventKeyPress:Bool = false;
	var _controls:Controls;

	public function new(
		XPos:Float, 
		YPos:Float, 
		MenuWidth:Int = 0, 
		Data:Array<MenuData>,
		?CenterText:Bool = false
	):Void {
		super();
		_menuData = Data;

		// Pointer
		_pointer = new FlxSprite(XPos, YPos - 5);
		_pointer.makeGraphic(MenuWidth, _spacing, 0xffdc2de4);
		add(_pointer);

		// Text Choices
		_menuData.mapi((idx:Int, data:MenuData) -> {
			var choice = new FlxText(XPos, YPos + (_spacing * idx), 0, data.title, 33);
			if(CenterText) choice.screenCenter(X);
			choice.scrollFactor.set(0, 0);
			add(choice);
		});

		// Intialise controls
		_controls = new Controls();		
	}

	override public function update(Elapsed:Float):Void {
		if(!_preventKeyPress) {
			if (_controls.cross.check()) {
				_menuData[_selected].func();
			}

			if (_controls.down.check()) {
				if (_selected != _menuData.length - 1) {
					_pointer.y = _pointer.y + _spacing;
					_selected++;
				}
			}

			if (_controls.up.check()) {
				if (_selected != 0) {
					_pointer.y = _pointer.y - _spacing;
					_selected--;
				}
			}
		}
		super.update(Elapsed);
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
}
