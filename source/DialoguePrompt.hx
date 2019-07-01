package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class DialoguePrompt extends FlxTypedGroup<FlxSprite> {
	var _dialogueBubble:FlxSprite;
	var _dialogueText:FlxText;
	var _dialogueXPos:Float;
	var _dialogueYPos:Float;
	var _dialogueYPosLow:Float;
	var _vertices:Array<FlxPoint>;
	var _w:Float;
	var _h:Float;

	/**
	 * Created the box and text elements for a dialogue prompt.
	 *
	 * @param		DialogueWidth		Width of the whole dialogue box.
	 * @param		X								X positions.
	 * @param		Y								Y position.
	 * @param		DialogueText 		Text that will go in the box, this will change to string for image.
	 */
	public function new(?DialogueWidth:Null<Int> = 120, ?X:Float = 0, ?Y:Float = 0, DialogueText:String):Void {
		super();

		_dialogueXPos = X - (DialogueWidth / 2);
		_dialogueYPos = Y;
		_dialogueYPosLow = Y - 10;

		// Create the speech bubble
		_dialogueBubble = new FlxSprite(_dialogueXPos, Y);
		_dialogueBubble.makeGraphic(DialogueWidth, Std.int(DialogueWidth / 4 * 3), FlxColor.TRANSPARENT);

		_w = _dialogueBubble.width;
		_h = _dialogueBubble.height;

		_vertices = new Array<FlxPoint>();
		_vertices = [
			new FlxPoint(0, 0),
			new FlxPoint(_w, 0),
			new FlxPoint(_w, _w / 2),
			new FlxPoint(_h, _w / 2),
			new FlxPoint(_w / 2, _h),
			new FlxPoint(_w / 4, _w / 2),
			new FlxPoint(0, _w / 2)
		];
		FlxSpriteUtil.drawPolygon(_dialogueBubble, _vertices, 0xff205ab7);
		add(_dialogueBubble);

		// Create dialogue text
		_dialogueText = new FlxText(_dialogueXPos, 510, DialogueWidth);
		_dialogueText.text = DialogueText;
		_dialogueText.setFormat(null, 20, FlxColor.WHITE, CENTER);
		add(_dialogueText);

		// Hide the members
		this.forEach((_member:FlxSprite) -> _member.alpha = 0);
	}

	public function showPrompt():Void {
		this.forEach((_member:FlxSprite) -> {
			FlxTween.tween(_member, {alpha: 1, y: _dialogueYPosLow}, .1);
		});
	}

	/**
	 * @param UseOnComplete Detemines if members should use tween onComplete option.
	 */
	public function hidePrompt(UseOnComplete:Bool = false):Void {
		this.forEach((_member:FlxSprite) -> {
			FlxTween.tween(_member, {alpha: 0, y: _dialogueYPos}, .1, UseOnComplete ? {onComplete: (_) -> _member.alpha = 0} : null);
		});
	}
}
