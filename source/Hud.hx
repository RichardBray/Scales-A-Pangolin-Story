package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

interface Levelish extends FlxState {
    public function toString():String;
}

class HUD extends FlxSpriteGroup {
	var _hearts:FlxSpriteGroup;
	var _txtScore:FlxText;
	var _health:FlxSprite;
	var _score:Int = 0;
	var _parentState:Levelish;

	public function new(ParentState:Levelish) {
		super();

		_parentState = ParentState;
		// Socre text
		_txtScore = new FlxText(FlxG.width / 2, 40, 0, updateScore());
		_txtScore.setFormat(null, 24, 0xFF194869, FlxTextAlign.CENTER);
		add(_txtScore);

		// Hearts
		_hearts = new FlxSpriteGroup();
		createHearts();
		add(_hearts);

		this.forEach((_member:FlxSprite) -> _member.scrollFactor.set(0, 0));
	}

	/**
	 * Toggles alpha of members in HUD group.
	 *
	 * @param Alpha 1 is to show 0 is to hide.
	 */
	public function toggleHUD(Alpha:Int):Void {
		this.forEach((member:FlxSprite) -> {
			member.alpha = Alpha;
		});
	}

	public function incrementScore():Void {
		_score = _score + 1;
		_txtScore.text = updateScore();
	}

	public function decrementHealth() {
		var index:Int = 0;
		_hearts.forEach((s:FlxSprite) -> {
			if (index == _parentState.player.health) {
				s.alpha = 0.2;
			}
			index++;
		});
	}

	function updateScore():String {
		return "Score:" + _score;
	}

	/**
	 * Std.int converts float to int
	 * @see https://code.haxe.org/category/beginner/numbers-floats-ints.html
	 */
	function createHearts():Void {
		for (i in 0...Std.int(_parentState.player.health)) {
			_health = new FlxSprite((i * 80), 10).loadGraphic("assets/images/heart.png", false, 60, 60);
			_hearts.add(_health);
		}
	}
}
