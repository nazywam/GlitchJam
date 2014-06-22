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
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSave;

class MenuState extends FlxState {
	//var levels : Array<Level>;
	var selected : FlxPoint;
	
	var glitchDirection : GlitchDirection;
	var glitchStrength : Float;
	var solved : Bool;
	
	var completing : Bool;
	
	var saves : FlxSave;
	
	override public function create() {
		super.create();
		FlxG.log.redirectTraces = true;
		FlxG.sound.muted = false;

		saves = new FlxSave();
		saves.bind("save");
		if (saves.data.completedLevels == null) {
			saves.data.completedLevels = new Array<Int>();
		}
		//saves.erase();

		if (Reg.level == -1) {
			Reg.levels = new Array<Level>();
		} else {
			saves.data.completedLevels.push(Reg.level);
			Reg.level = Reg.level+1;
			if (Reg.level < 16) {
				FlxG.switchState(new PlayState(Reg.level));
			}
		}
		glitchDirection = HORIZONTAL;
		glitchStrength = 2;
		selected = new FlxPoint(0,0);
		
		var cWidth = FlxG.camera.width;
		var cHeight = FlxG.camera.height;
		
		var offset = (cWidth / 4 - 45) / 2;
		
		solved = false;
		completing = false;
		for (y in 0...4) {
			for (x in 0...4) {
				var t = new Level(cWidth / 4 * x + offset, cHeight / 4 * y + offset, y*4+x);
				Reg.levels.push(t);
				add(t);
				add(t.glitch);
			}
		}
		
		for (x in 0...saves.data.completedLevels.length) {
			remove(Reg.levels[saves.data.completedLevels[x]].glitch);
			Reg.levels[saves.data.completedLevels[x]].complete();
			add(Reg.levels[saves.data.completedLevels[x]].glitch);
			
		}
		/*
		for (x in 0...16) {
			remove(Reg.levels[x].glitch);
			Reg.levels[x].complete();
			add(Reg.levels[x].glitch);
			
		}*/
	}
	override public function update() {
		super.update();
		if (!solved) {
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
				glitchStrength = 3;
			}
			
			var s = Std.int(selected.y * 4 + selected.x);
			
			for (i in 0...Reg.levels.length) {
				if (i != Std.int(selected.y * 4 + selected.x)) {
					Reg.levels[i].glitch.direction = glitchDirection;
					Reg.levels[i].glitch.strength = Std.int(Math.min(glitchStrength, 25));
				}
			}
			Reg.levels[s].glitch.strength = 0;
			
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
				if (s == 0 || Reg.levels[s - 1].completed) {
					Reg.level = s;
					FlxG.switchState(new PlayState(s));
				} else {
					FlxG.sound.play("assets/sounds/locked.wav", 0.5);
				}
			}
			
			solved = true;
			for (i in 0...Reg.levels.length) {
				if (!Reg.levels[i].completed) solved = false;
			}
			if (solved) {
				for (i in 0...Reg.levels.length) {
					Reg.levels[i].glitch.visible = false;
					Reg.levels[i].visible = true;
				}
			}
		} else if(!completing){
			completing = true;
			
			for (i in 0...Reg.levels.length) {
				var lx : Int = i % 4;
				var ly : Int = Std.int(i / 4);
				FlxTween.linearMotion(Reg.levels[i], Reg.levels[i].x, Reg.levels[i].y, 70 + lx * 45, 70 + ly * 45, 5, true,  { type : FlxTween.ONESHOT, ease:FlxEase.cubeOut } );
			}
		}
	}
}