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
import flixel.input.keyboard.FlxKey;
import openfl.Assets;

class MenuState extends FlxState {
	var selected : FlxPoint;
	
	var glitchDirection : GlitchDirection;
	var glitchStrength : Float;

	var completing : Bool;
	
	var selection : FlxSprite;
	
	var levels:Array<Level> = [];
	
	var saves : FlxSave;
	
	function complete() {
		completing = true;
		for (i in 0...levels.length) {
			var lx : Int = i % 4;
			var ly : Int = Std.int(i / 4);
			FlxTween.linearMotion(levels[i], levels[i].x, levels[i].y, 70 + lx * 45, 70 + ly * 45, 4, true,  { type : FlxTween.ONESHOT, ease:FlxEase.cubeOut } );
		}
		
	}
	
	override public function create() {
		super.create();
		FlxG.log.redirectTraces = true;
		
		saves = new FlxSave();
		saves.bind("save");
		if (saves.data.completedLevels == null) {
			saves.data.completedLevels = new Array<Int>();
			for (x in 0...16) {
				saves.data.completedLevels.push(false);
			}
		}
		
		FlxG.sound.muteKeys = ['M'];
		
		//saves.erase();
		
		if (Reg.level == -1) {
		} else {
			saves.data.completedLevels[Reg.level] = true;
			if (Reg.level < 15) {
				Reg.level++;
				if (Reg.level == 7 || Reg.level == 12 || Reg.level == 14) {
					FlxG.sound.playMusic("assets/music/GlitchParty.mp3");
				} else if (Reg.level == 8 || Reg.level == 13) {
					FlxG.sound.playMusic("assets/music/GlitchLounge.mp3");
				} else if (Reg.level == 15) {
					FlxG.sound.music.stop();
				}
				FlxG.switchState(new PlayState(Reg.level));
				FlxG.camera.color = 0x000000;
			}
		}
		if (Reg.level == 15) {
			saves.data.completedLevels[15] = true;
		}
		levels = new Array<Level>();
		
		var cWidth = FlxG.camera.width;
		var cHeight = FlxG.camera.height;
		var offset = (cWidth / 4 - 45) / 2;

		
		for (y in 0...4) {
			for (x in 0...4) {
				var t = new Level(cWidth / 4 * x + offset, cHeight / 4 * y + offset, y*4+x);
				levels.push(t);
				if (saves.data.completedLevels[y * 4 + x]) {
					levels[y * 4 + x].complete();
				}
				add(t);
				add(t.glitch);
			}
		}
		glitchDirection = HORIZONTAL;
		glitchStrength = 2;
		selected = new FlxPoint(0, 0);
		
		completing = false;
		if (Reg.level == 15) {
			for (x in levels) {
				var l = cast(x, Level);
				l.visible = true;
				l.glitch.visible = false;
			}
			complete();
		}
		
		selection = new FlxSprite(100,100);
		selection.loadGraphic(Assets.getBitmapData("assets/images/sprites.png"), true, 32, 32);
		selection.animation.add("default", [36, 37], 1);
		selection.animation.play("default");
		selection.scale.x = 1.2;
		selection.scale.y = 1.2;
		add(selection);
		
		
	}
	override public function update() {
		super.update();
		if (!completing) {
			
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP) {
				FlxG.sound.play("assets/sounds/bip.wav", 0.5);
			}
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
			
			for (i in 0...levels.length) {
				if (i != Std.int(selected.y * 4 + selected.x)) {
					levels[i].glitch.direction = glitchDirection;
					levels[i].glitch.strength = Std.int(Math.min(glitchStrength, 25));
					levels[i].glitch.alpha = 0.5;
				}
			}
			levels[s].glitch.strength = 0;
			levels[s].glitch.alpha = 1;
			
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
				if (s == 0 || levels[s - 1].completed) {
					Reg.level = s;
					//trace(Reg.level);
					if (Reg.level <= 6) {
						FlxG.sound.playMusic("assets/music/GlitchHaven.mp3");
					}else if (Reg.level == 7 || Reg.level == 12 || Reg.level == 14) {
						FlxG.sound.playMusic("assets/music/GlitchParty.mp3");
					} else if (Reg.level != 15) {
						FlxG.sound.playMusic("assets/music/GlitchLounge.mp3");
					}
					FlxG.switchState(new PlayState(s));
				} else {
					FlxG.sound.play("assets/sounds/locked.wav", 1);
				}
			}
			if (selected.x == 0 && selected.y == 0) {
				selection.visible = true;
			} else {
				selection.visible = levels[Std.int(selected.x + selected.y * 4)-1].completed;
			}
			
			selection.x = levels[Std.int(selected.x + selected.y * 4)].x + 7;
			selection.y = levels[Std.int(selected.x + selected.y * 4)].y + 40;
		} else {
			selection.visible = false;
		}
	}
}