package ;

import flixel.FlxSprite;
import openfl.Assets;
import flixel.tweens.FlxTween;
/**
 * ...
 * @author Michael
 */
class Coin extends FlxSprite {

	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic("assets/images/stuff.png", true, 16, 16);
		
		var r = Std.random(6);
		animation.add("default", [r, (r+1)%6, (r+2)%6, (r+3)%6, (r+4)%6, (r+5)%6], 10);
		
		animation.add("take", [6, 7, 8, 9, 10, 11], 25, false);
		animation.play("default");
		
		
		immovable = true;
		
		//y -= height / 2;
		/*
		y -= height;
		x -= width / 2;
		width = 28;
		height = 28;
		offset.x = 2;
		offset.y = 2;
		*/
		//var tween = new FlxTween();
		
		
	}
	override public function update() {
		super.update();
		if (animation.name == "take" && animation.frameIndex == 11) {
			alpha = 0;
		}
	}
}