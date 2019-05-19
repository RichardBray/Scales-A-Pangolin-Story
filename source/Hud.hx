package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class HUD extends FlxSpriteGroup {
	var _hearts:FlxSpriteGroup;
	var _txtScore:FlxText;
	var _health:FlxSprite;

	public var gameScore:Int;

	public function new(Score:Int, Health:Float) {
		super();

		gameScore = Score;
		// Socre text
		_txtScore = new FlxText(FlxG.width / 2, 40, 0, updateScore(gameScore));
		_txtScore.setFormat(null, 24, 0xFF194869, FlxTextAlign.CENTER);
		add(_txtScore);

		// Hearts
		_hearts = new FlxSpriteGroup();
		createHearts(Health);
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
		gameScore = gameScore + 1;
		_txtScore.text = updateScore(gameScore);
	}

	public function decrementHealth(PlayerHealth:Float) {
		var index:Int = 0;
		_hearts.forEach((s:FlxSprite) -> {
			if (index == PlayerHealth) {
				s.alpha = 0.2;
			}
			index++;
		});
	}

	function updateScore(Score:Int):String {
		return "Score:" + Score;
	}

	/**
	 * Std.int converts float to int
	 * @see https://code.haxe.org/category/beginner/numbers-floats-ints.html
	 */
	function createHearts(PlayerHealth:Float):Void {
		for (i in 0...Std.int(3)) {
			_health = new FlxSprite((i * 80), 10).loadGraphic("assets/images/heart.png", false, 60, 60);
			_hearts.add(_health);
		}
		// For keeping health between states
		if(PlayerHealth < 3) {
			decrementHealth(PlayerHealth);
		}
	}
}
