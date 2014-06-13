package ;

import flixel.FlxSprite;
import openfl.Assets;
/**
 * ...
 * @author Michael
 */
class Laser extends FlxSprite {
	//can blink
	public var vertical : Bool;
	public var on : Bool;
	public var id : Int;
	public function new(X:Float, Y:Float, v:Bool, i:Int, reverted : Bool){
		super(X, Y);
		on = true;
		vertical = v;
		id = i;
		solid = true;
		immovable = true;
		loadGraphic(Assets.getBitmapData("assets/images/lasers.png"), true, 16, 16);
		animation.add("off", [16], 1, false);
		if (vertical) {
			animation.add("default", [8, 9, 10, 11, 12, 13, 14, 15], 10);
			flipY = reverted;
			y -= 1;
			x += 7;
			offset.y = -1;
			offset.x = 7;		
			width = 2;
		} else {
			animation.add("default", [0, 1, 2, 3, 4, 5, 6, 7], 10);
			flipX = reverted;
			x -= 1;
			y += 7;
			offset.x = -1;
			offset.y = 7;
			height = 2;
		}
	}
	override public function update() {
		super.update();
		if (on) {
			animation.play("default");
		} else {
			animation.play("off");
		}
	}
	
}