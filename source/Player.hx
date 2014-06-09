package ;
import openfl.Assets;
import flixel.FlxObject;
import flixel.FlxG;
/**
 * ...
 * @author Michael
 */
class Player extends Actor {
	//http://opengameart.org/content/dutone-tileset-objects-and-character
	
	public function new(x : Float, y : Float) {
		super(x, y);
		loadGraphic(Assets.getBitmapData("assets/images/sprites.png"), true, 32, 32);
		animation.add("run", [0, 1, 2, 3, 4, 5], 10);
		animation.add("stand", [6, 7, 8, 9, 10, 11], 3);
		animation.add("jump", [12, 13, 14, 15, 16, 17], 4);
		acceleration.y = 550;
		solid = true;
		drag.x = 750;
		width = 16;
		height = 28;
		offset.x = 8;
		offset.y = 4;
	}
	override public function update() {
		//FlxG.watch.add(velocity, "y", "y:");
		flipX = !facingRight;
		if (isTouching(FlxObject.FLOOR)) {
			if (Math.abs(velocity.x ) > 10) {
				animation.play("run");
			}
			else {
				animation.play("stand");
			}
		} else {
			animation.play("jump");
		}
		super.update();
		
	}
	
}