package ;

import flixel.FlxSprite;
import openfl.Assets;
/**
 * ...
 * @author Michael
 */
class Laser extends FlxSprite {
	//can blink
	var vertical : Bool;
	public var on : Bool;
	
	public function new(X:Float, Y:Float, v:Bool, i:Int){
		super(X, Y);
		on = true;
		vertical = v;
		ID = i;
		solid = true;
		immovable = true;
		loadGraphic(Assets.getBitmapData("assets/images/tiles.png"), true, 16, 16);
		animation.add("off", [3], 1, false);
		if (vertical) {
			animation.add("default", [40, 41, 42, 43, 44, 45, 46, 47], 10);
		} else {
			animation.add("default", [48, 49, 50, 51, 52, 53, 54, 55], 10);
		}
		//height = 18;
		y -= 1;
		offset.y = -1;
		
		width = 2;
		x += 7;
		offset.x = 7;
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