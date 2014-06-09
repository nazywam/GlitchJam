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
	public var id : Int; // could use ID ?
	public function new(X:Float, Y:Float, v:Bool, i:Int){
		super(X, Y);
		vertical = v;
		id = i;
		solid = true;
		immovable = true;
		loadGraphic(Assets.getBitmapData("assets/images/tiles.png"), true, 16, 16);
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
		
		animation.play("default");
	}
	
}