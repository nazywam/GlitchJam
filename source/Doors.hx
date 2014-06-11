package ;
import openfl.Assets;
import flixel.FlxSprite;
/**
 * ...
 * @author Michael
 */
class Doors extends FlxSprite {

	var start : Bool;
	var open : Bool;
	public function new(X : Float, Y : Float, s : Bool) {
		super(X, Y);
		
		open = false;
		start = s;
		loadGraphic("assets/images/doors.png", true, 32, 32);
		this.animation.add("start", [0]);
		this.animation.add("end", [8]);
		
		this.animation.add("close", [0, 1, 2, 3, 4, 5, 6, 7], 6, false);
		this.animation.add("open", [8, 9, 10, 11, 12, 13, 14, 15], 6, false);
		
		if (start) {
			animation.play("close");
		} else {
			animation.play("end");
		}
		
		width = 15;
		x += 7;
		offset.x = 7;
	}
	override public function update() {
		super.update();
		if (animation.name == "open" && animation.finished) open = true;
	}
}