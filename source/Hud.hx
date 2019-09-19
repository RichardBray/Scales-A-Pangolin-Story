package;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.shapes.FlxShapeBox; // Used for goals not completed message

using Lambda;

typedef GoalData = { goal:String, func:Null<Dynamic>->Bool };

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
	var _comparisonGoalArray:Array<Bool> = []; // Used to compare against for updating goals
	var _goalsNotCompleted:FlxText;
	var _goalsNotCompletedBox:FlxShapeBox;
	
	public var gameScore:Int; // Send game score to level end menu
	public var goalsCompleted:Bool = false; // Tells level class i.e. LevelOne when to allow exit

	public function new(Score:Int, Health:Float, ?Goals:Null<Array<GoalData>>) {
		super();

		gameScore = Score;
		_goalData = Goals;

		for (_ in Goals) {
			_comparisonGoalArray.push(false);
		}
		// Garidnet for top of HUD
		_gradientBg = FlxGradient.createGradientFlxSprite(FlxG.width, 150, [FlxColor.BLACK, FlxColor.TRANSPARENT]);
		_gradientBg.alpha = 0.2;
		add(_gradientBg);
	
		// Socre text
		_scoreTxt = new FlxText(_leftPush, 70, 0, updateScore(gameScore));
		_scoreTxt.setFormat(Constants.squareFont, Constants.hudFont, FlxColor.WHITE, FlxTextAlign.LEFT);
		add(_scoreTxt);

		// Goals Text
		_goals = new FlxSpriteGroup();
		createGoals(Goals);
		add(_goals);

		// Hearts
		_hearts = new FlxSpriteGroup();
		createHearts(Health);
		add(_hearts);

		// Goals not completed box
		var boxWidth:Int = 100;
		var goalsYPos:Float = (FlxG.height / 2) - (boxWidth / 2); // Almost middle of the screen
		_goalsNotCompletedBox = new FlxShapeBox(
			-10, goalsYPos, 
			FlxG.width + 20, boxWidth, 
			{ thickness:8, color:Constants.primaryColorLight }, 
			Constants.primaryColor
		);
		_goalsNotCompletedBox.alpha = 0;
		add(_goalsNotCompletedBox);

		// Goals not completed text
		_goalsNotCompleted = new FlxText(
			0, 
			goalsYPos + 32, // Yes 32 is a magic number 
			0, 
			"You haven't completed all the goals"
		);
		_goalsNotCompleted.setFormat(Constants.squareFont, Constants.medFont);
		_goalsNotCompleted.alpha = 0;
		_goalsNotCompleted.screenCenter(X);
		add(_goalsNotCompleted);

		this.forEach((_member:FlxSprite) -> _member.scrollFactor.set(0, 0));
	}

	/**
	 * Toggles alpha of members in HUD group.
	 *
	 * @param Alpha 1 is to show 0 is to hide.
	 */
	public function toggleHUD(Alpha:Int) {
		var hudObjects:Array<FlxSprite> = [_gradientBg, _scoreTxt, _goals, _hearts];
		var objectAlpha:Array<Float> = [0.2, 1, 1, 1];
		hudObjects.mapi((idx:Int, member:FlxSprite) -> {
			member.alpha = objectAlpha[idx];
		});
	}

	public function incrementScore() {
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

	/**
	 * Method to say goals haven't been completed. 
	 * Only to be used as collide callback, hence the two arguments.
	 */
	public function goalsNotComplete(_, _) {
		var _timer:FlxTimer = new FlxTimer();
		_goalsNotCompleted.alpha = 1;
		_goalsNotCompletedBox.alpha = 0.7; // Not fully visible so that tbe player can be seen behind it
		// Hide message after two seconds
		_timer.start(2, (_) -> {
			_goalsNotCompleted.alpha = 0;
			_goalsNotCompletedBox.alpha = 0;
		});
	}	

	function updateScore(Score:Int):String {
		return "Bugs: " + Score;
	}

	/**
	 * Std.int converts float to int
	 * @see https://code.haxe.org/category/beginner/numbers-floats-ints.html
	 */
	function createHearts(PlayerHealth:Float) {
		for (i in 0...Std.int(3)) { // 3 is maxiumum player health, this might change in the future
			_health = new FlxSprite(((i * 60) + _leftPush), 20).loadGraphic("assets/images/heart.png", false, 40, 33);
			_hearts.add(_health);
		}
		// For keeping health between states
		if (PlayerHealth < 3) {
			decrementHealth(PlayerHealth);
		}
	}

	// *** Methods for GOALS!!!! ***

	/**
	 * This method creates a group of goal strings.
	 */
	function createGoals(Goals:Array<GoalData>) {
		Goals.mapi((idx:Int, data:GoalData) -> {
			var goalsTextLineHeight:Int = 40;
			var distanceFromScreenTop:Int = 20;
			var goal = new FlxText(FlxG.width - 300, distanceFromScreenTop + (idx * goalsTextLineHeight), 0, data.goal);	
			goal.setFormat(Constants.squareFont, Constants.hudFont, FlxColor.WHITE, FlxTextAlign.RIGHT);
			_goals.add(goal);
		});
	}
	
	/**
	 * This meathod updates goal strings to make them opaque if goal is completed.
	 * It checks a goal is completed if `_goalsArr` is true for the string index.
	 */
	function updateGoals() {
		var index:Int = 0;
		_goals.forEach((goal:FlxSprite) -> {
			if (_goalsArr[index] == true) goal.alpha = 0.2;
			index++;
		});		
	}

	/**
	 * For loop instead of mapi because `Cannot use Void as value` error.
	 * This method checks if a goal has been completed or not by running the specific goal function.
	 */
	function checkGoalsArray(Goals:Array<GoalData>) {
		var index:Int = 0;
		var trueGoals:Int = 0; // Number of goals that have been completed

		for (goal in Goals) {
			if (goal.func(gameScore)) {
				_goalsArr[index] = true;
				trueGoals++;
			}
			index++;
		}

		// If all goals are true then toggle goalsCompleted public variable
		// @todo add goals completed chime
		if (trueGoals == _goalData.length) goalsCompleted = true;
	}

	/**
	 * A simple helper method to compare two arrays. Returns true if they both match.
	 * Created specifically for the goals functionality.
	 *
	 * @param Arr1 First array to compare
	 * @param Arr2 Second array to compare
	 */
	function compareGoalArrays(Arr1:Array<Bool>, Arr2:Array<Bool>):Bool {
		var arrLength:Int = Arr1.length;
		var equalValues:Int = 0;

		for (a in 0...arrLength) if (Arr1[a] == Arr2[a]) equalValues++;
		return arrLength == equalValues;
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);

		checkGoalsArray(_goalData);
		// This compares the oringinal plan array of falses to the goals array and if anything has changed 
		// it will run `updateGoals()`
		if (!compareGoalArrays(_comparisonGoalArray, _goalsArr)) updateGoals();
	}	
}
