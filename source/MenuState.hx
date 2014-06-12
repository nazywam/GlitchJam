package ;

import flixel.addons.effects.FlxGlitchSprite;
import flixel.addons.effects.FlxGlitchSprite.GlitchDirection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxPoint;

class MenuState extends FlxState {
	var levels : Array<Level>;
	var selected : FlxPoint;
	
	var glitchDirection : GlitchDirection;
	var glitchStrength : Float;
	override public function create():Void
	{
		FlxG.log.redirectTraces = true;
		super.create();
		levels = new Array<Level>();
		
		glitchDirection = HORIZONTAL;
		glitchStrength = 2;
		selected = new FlxPoint(0,0);
		
		var cWidth = FlxG.camera.width;
		var cHeight = FlxG.camera.height;
		
		var offset = (cWidth / 4 - 45) / 2;
		
		
		
		for (y in 0...4) {
			for (x in 0...4) {
				var t = new Level(cWidth / 4 * x + offset, cHeight / 4 * y + offset, y*4+x);
				levels.push(t);
				add(t);
				add(t.glitch);
			}
		}
	}
	
	override public function update():Void
	{
		super.update();
		
		if (FlxG.keys.justPressed.RIGHT) {
			selected.x = Math.min(selected.x+1, 3);
			glitchDirection = HORIZONTAL;
		} else if (FlxG.keys.justPressed.LEFT) {
			selected.x = Math.max(selected.x-1, 0);
			glitchDirection = HORIZONTAL;
		}
		
		if (FlxG.keys.justPressed.UP) {
			glitchDirection = VERTICAL;
			selected.y = Math.max(selected.y-1, 0);
		} else if (FlxG.keys.justPressed.DOWN) {
			glitchDirection = VERTICAL;
			selected.y = Math.min(selected.y+1, 3);
		}
		
		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN || FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT) {
			glitchStrength += 0.03;
		}
		if (FlxG.keys.justReleased.UP || FlxG.keys.justReleased.DOWN || FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.RIGHT) {
			glitchStrength = 2;
		}
		
		for (i in 0...levels.length) {
			if (i != Std.int(selected.y * 4 + selected.x)) {
				if (!levels[i].completed) {
					levels[i].glitch.direction = glitchDirection;
					levels[i].glitch.strength = Std.int(Math.min(glitchStrength, 25));
				}
			}
		}
		levels[Std.int(selected.y*4 + selected.x)].glitch.strength = 0;
		if (FlxG.keys.justPressed.S) {
			levels[Std.int(selected.y * 4 + selected.x)].complete();
		}
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
			FlxG.switchState(new PlayState());
		}
	}
}