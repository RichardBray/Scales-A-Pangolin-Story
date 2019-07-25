package;

import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

using Lambda;

typedef GoalData = { goal:String, func:Void->Bool };

class HUD extends FlxSpriteGroup {
	var _hearts:FlxSpriteGroup;
	var _scoreTxt:FlxText;
	var _health:FlxSprite;
	var _gradientBg:FlxSprite;
	var _leftPush:Int = 15; // Distance away from left side of the screen
	// Goals
	var _goals:FlxSpriteGroup;
	var _goalData:Null<Array<GoalData>>;
	var _goalsArr:Array<Bool> = [];

	public var gameScore:Int;

	public function new(Score:Int, Health:Float, ?Goals:Null<Array<GoalData>>) {
		super();

		gameScore = Score;

		_goalData = Goals;
		// Garidnet for top of HUD
		_gradientBg = FlxGradient.createGradientFlxSprite(FlxG.width, 150, [FlxColor.BLACK, FlxColor.TRANSPARENT]);
		_gradientBg.alpha = 0.15;
		add(_gradientBg);
	
		// Socre text
		_scoreTxt = new FlxText(_leftPush, 70, 0, updateScore(gameScore));
		_scoreTxt.setFormat(null, 24, FlxColor.WHITE, FlxTextAlign.LEFT);
		add(_scoreTxt);

		// Goals Text
		_goals = new FlxSpriteGroup();
		createGoals(Goals);
		add(_goals);

		// Hearts
		_hearts = new FlxSpriteGroup();
		createHearts(Health);
		add(_hearts);

		this.forEach((_member:FlxSprite) -> _member.scrollFactor.set(0, 0));
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		checkGoalsArray(_goalData);
		if(compareGoalArrays([false], _goalsArr)) updateGoals();
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
		_scoreTxt.text = updateScore(gameScore);
	}

	public function decrementHealth(PlayerHealth:Float) {
		var index:Int = 0;
		_hearts.forEach((s:FlxSprite) -> {
			if (index >= PlayerHealth) s.alpha = 0.2;
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

	// Methods for GOALS!!!!

	/**
	 * This methodm creates a group of goal strings.
	 */
	function createGoals(Goals:Array<GoalData>) {
		Goals.mapi((idx:Int, data:GoalData) -> {
			var goal = new FlxText(FlxG.width - 300, 20 + (idx * 10), 0, data.goal);	
			goal.setFormat(null, Constants.smlFont, FlxColor.WHITE, FlxTextAlign.RIGHT);
			_goals.add(goal);
		});
	}
	
	function updateGoals() {
		var index:Int = 0;
		_goals.forEach((goal:FlxSprite) -> {
			if (_goalsArr[index] == true) goal.alpha = 0.2;
			index++;
		});		
	}

	function checkGoalsArray(Goals:Array<GoalData>) {
		Goals.mapi((idx:Int, data:GoalData) -> {
			if (data.func() == true) _goalsArr[idx] = true;
		});
		trace(_goalsArr);
	}

	function compareGoalArrays(Arr1:Array<Bool>, Arr2:Array<Bool>):Bool {
		var arrLength:Int = Arr1.length;
		var equalValues:Int = 0;

		for (a in 0...arrLength) {
			if(Arr1[a] == Arr2[a]) equalValues++;
		}

		return arrLength == equalValues;
	}
}
