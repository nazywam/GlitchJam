package ;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import flixel.addons.effects.FlxGlitchSprite;

import com.newgrounds.*;
import com.newgrounds.components.*;
//import flixel.addons.effects.FlxGlitchSprite;

class MenuState extends FlxState {
	var selected : FlxPoint;
	var glitchDirection : FlxGlitchDirection;
	
	var glitchStrength : Float;

	var completing : Bool;
	
	var selection : FlxSprite;
	var selectionCoin : FlxSprite;
	
	var levels:Array<Level> = [];
	
	var saves : FlxSave;
	
	var tween : FlxTween;
	
	var gameOver : FlxText;
	
	var credits : FlxText;
	function complete() {
		completing = true;
		API.unlockMedal("Game Over");
		for (i in 0...levels.length) {
			var lx : Int = i % 4;
			var ly : Int = Std.int(i / 4);
			tween = FlxTween.linearMotion(levels[i], levels[i].x, levels[i].y, 70 + lx * 45, 70 + ly * 45, 4, true,  { type : FlxTween.ONESHOT, ease:FlxEase.cubeOut } );
		}
		
	}
	function onAPIConnected(event:APIEvent)
	{
		if(event.success)
		{
			trace("The API is connected and ready to use!");
		}
		else
		{
			trace("Error connecting to the API: " + event.error);
		}
	}
	override public function create() {
		super.create();
		FlxG.log.redirectTraces = true;
		
		API.addEventListener(APIEvent.API_CONNECTED, onAPIConnected);
		API.connect(flash.Lib.current.root, "SECRET", "SUPERSECRET");
		
		
		saves = new FlxSave();
		saves.bind("save");
		if (saves.data.completedLevels == null) {
			saves.data.completedLevels = new Array<Bool>();
			for (x in 0...16) {
				saves.data.completedLevels.push(false);
			}
		}
		if (saves.data.collectedCoins == null) {
			saves.data.collectedCoins = new Array<Bool>();
			for (x in 0...16) {
				saves.data.collectedCoins.push(false);
			}
		}
		
		FlxG.sound.muteKeys = ['M'];
		
		//saves.erase();
		if (Reg.level == -1) {
		} else {
			if (Reg.coinsCollected >= Reg.coinsNeeded[Reg.level]) {
				saves.data.collectedCoins[Reg.level] = true;
				Reg.coinsCollected = 0;
				var allCoinsColleced = true;
				for (x in 0...16) {
					if (!saves.data.collectedCoins[x]) {
						allCoinsColleced = false;
					}
				}
				if (allCoinsColleced) {
					API.unlockMedal("Collect all coins");
				}
			}
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
				var t = new Level(cWidth / 4 * x + offset, cHeight / 4 * y + offset, y * 4 + x);
				t.collectedAllCoins = saves.data.collectedCoins[y * 4 + x];
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
		selection.animation.add("default", [37, 36], 1);
		selection.animation.play("default");
		selection.scale.x = 1.2;
		selection.scale.y = 1.2;
		add(selection);
		
		selectionCoin = new FlxSprite();
		selectionCoin.loadGraphic(Assets.getBitmapData("assets/images/coins.png"), true, 12, 12);
		selectionCoin.animation.add("gray", [1, 0], 1);
		selectionCoin.animation.add("color", [2, 0], 1);
		add(selectionCoin);
	
		gameOver = new FlxText(0, 0, 0, "Game Over", 32);
		gameOver.visible = false;
		add(gameOver);
		
		credits = new FlxText(0, 0, 0, "By nazywam :3", 32);
		credits.visible = false;
		credits.flipY = true;
		credits.flipX = true;
		credits.angle = 180;
		add(credits);
		
		
	}
	override public function update() {
		super.update();
		if (!completing) {
			
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
			
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP) {
				FlxG.sound.play("assets/sounds/bip.wav", 0.5);
				
				selectionCoin.animation.play(selectionCoin.animation.name, true, 0);
				selection.animation.play(selection.animation.name, true, 0);
				
				FlxG.watch.add(selection.animation, "frameIndex", "text");
				FlxG.watch.add(selectionCoin.animation, "frameIndex", "coin");
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
					Reg.coinsCollected = 0;
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
			
			var i : Int = Std.int(selected.x + selected.y * 4);
			
			selection.x = levels[i].x + 7;
			selection.y = levels[i].y + 40;
			selectionCoin.x = levels[i].x + levels[i].width/2 - selectionCoin.width/2;
			selectionCoin.y = levels[i].y + levels[i].height + 3;
			if (levels[Std.int(selected.x + selected.y * 4)].collectedAllCoins) {
				selectionCoin.animation.play("color");
			} else {
				selectionCoin.animation.play("gray");
			}
		} else {
			selection.visible = false;
			selectionCoin.visible = false;
			if (tween.finished) {
				gameOver.x = levels[12].x + 180 / 2 - gameOver.width / 2;
				gameOver.y = levels[12].y + levels[12].height + 10;
				gameOver.visible = true;
				
				credits.x = levels[0].x + 180 / 2 - credits.width / 2;
				credits.y = levels[0].y - credits.height;
				credits.visible = true;
				
				var rotation = Math.abs(FlxG.camera.angle);
				if (rotation > 180) {
					rotation = 180 + (180 - rotation);
				}
				rotation = Math.abs(rotation);
				
				
				gameOver.alpha = (1 - (rotation/180)) * 1.0;
				credits.alpha = (rotation / 180) * 1.0;
				
				if (credits.alpha > 0.8) {
					API.unlockMedal("Credits");
				}
				
				if (FlxG.keys.justPressed.LEFT) {
					FlxG.camera.angle += 18;
				} else if (FlxG.keys.justPressed.RIGHT) {
					FlxG.camera.angle -= 18;
				}
			}
		}
	}
}