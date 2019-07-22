package;

import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class HUD extends FlxSpriteGroup {
	var _hearts:FlxSpriteGroup;
	var _txtScore:FlxText;
	var _txtGoals:FlxText;
	var _health:FlxSprite;
	var _gradientBg:FlxSprite;
	var _leftPush:Int = 15; // Distance away from left side of the screen

	public var gameScore:Int;

	public function new(Score:Int, Health:Float, ?Goals:Array<String>) {
		super();

		gameScore = Score;
		_gradientBg = FlxGradient.createGradientFlxSprite(FlxG.width, 200, [FlxColor.BLACK, FlxColor.TRANSPARENT]);
		_gradientBg.alpha = 0.4;
		add(_gradientBg);
	
		// Socre text
		_txtScore = new FlxText(_leftPush, 80, 0, updateScore(gameScore));
		_txtScore.setFormat(null, 24, FlxColor.WHITE, FlxTextAlign.LEFT);
		add(_txtScore);

		// Goals Text
		_txtGoals = new FlxText(FlxG.width - 300, 20, 0, "Collect 20 bugs.");
		_txtGoals.setFormat(null, 24, FlxColor.WHITE, FlxTextAlign.RIGHT);
		add(_txtGoals);

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
			if (index >= PlayerHealth) {
				s.alpha = 0.2;
			}
			index++;
		});
	}

	function updateScore(Score:Int):String {
		return "Bugs: " + Score;
	}

	/**
	 * Std.int converts float to int
	 * @see https://code.haxe.org/category/beginner/numbers-floats-ints.html
	 */
	function createHearts(PlayerHealth:Float):Void {
		for (i in 0...Std.int(3)) { // 3 is maxiumum player health, this might change in the future
			_health = new FlxSprite(((i * 60) + _leftPush), 20).loadGraphic("assets/images/heart.png", false, 40, 33);
			_hearts.add(_health);
		}
		// For keeping health between states
		if (PlayerHealth < 3) {
			decrementHealth(PlayerHealth);
		}
	}
}
