package ;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flixel.addons.effects.FlxGlitchSprite;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import openfl.Assets;
import flixel.FlxCamera;
import flixel.addons.display.FlxZoomCamera;
class PlayState extends FlxState
{
	
	var map : FlxTilemap;
	var background : FlxTilemap;
	var coins : FlxGroup;
	var lasers : FlxGroup;
	var levers : FlxGroup;
	var signs : FlxGroup;
	
	var player : Player;
	var playerSpawn : Point;
	
	var cat : Cat;
	var catGlitch : FlxGlitchSprite;
	
	var start : Doors;
	var end : Doors;
	
	var levelEnded : Bool;
	
	var cameraColor : Int;
	
	var misc : FlxGroup;
	
	var glitch : FlxGlitchSprite;
	
	var level : Int;
	
	var isStupidUpArrowPressed : Bool; 
	
	override public function new(i : Int) {
		level = i;
		super();
	}
	override public function create() { //should use different classes for each level?
		super.create();
		FlxG.worldBounds.set(640, 320);
		FlxG.log.redirectTraces = true;
		FlxG.mouse.visible = false;
		background = new FlxTilemap();
		background.loadMap(Assets.getText("assets/data/background.tmx"), "assets/images/background_bw.png", 128, 128, 0, 1);
		add(background);
		
		isStupidUpArrowPressed = false;
		
		cameraColor = 0xFFFFFF;
		
		levelEnded = false;
		
		misc = new FlxGroup();
		add(misc);
		
		coins = new FlxGroup();
		add(coins);
		
		lasers = new FlxGroup();
		add(lasers);
		
		levers = new FlxGroup();
		add(levers);
		
		signs = new FlxGroup();
		add(signs);
		parseMap(Assets.getText("assets/data/level" +level + ".txt"));
		//parseMap(Assets.getText("assets/data/level0.txt"));
		
		switch(level) {
			case 0:
				var c = new Coin(36 * 16, 14 * 16);
				c.bugged = true;
				coins.add(c);
				
			case 1:
				var a = new Sign(30 * 16, 18 * 16, "Which you have to use to get to the next level");
				signs.add(a);
				a.glitched = true;
				misc.add(a.text);
			case 2:
				var c = new Coin(35*16, 16*16);
				c.bugged = true;
				coins.add(c);
			case 3:
				for (y in 0...11) {
					var l = new Laser(16 * 11, 16 * (y + 7), true , 0, false);
					l.solid = false;
					lasers.add(l);
				}
			case 6:
				var a = new FlxSprite();
				a.loadGraphic(Assets.getBitmapData("assets/images/lvl6Glitch.png"), false, 464, 320);
				//add(a);
				glitch = new FlxGlitchSprite(a, 15, 1);
				add(glitch);
			default:
				
		}
		
		
		spawnPlayer();


		
		catGlitch = new FlxGlitchSprite(cat);
		add(catGlitch);
		cat.visible = false;
		
		FlxG.camera.setBounds(0, 0, FlxG.worldBounds.x, FlxG.worldBounds.y, true);
		FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);
		
		
	}
	
	public function collectCoin(player : Player, coin : Coin) {
		coin.animation.play("take");
		coin.solid = false;
		coins.remove(coin);
		if (coin.bugged) {
			if (level == 0) {
				var s = new Sign(35*16, 18*16, "That feeling though");
				signs.add(s);
				add(s.text);
			} else if (level == 2 && player.acceleration.y == 550) {
				player.acceleration.y -= 300;
				player.animation.add("jump", [12, 13, 14, 15, 16, 17], 2);
			}
		}
	}
	public function nextLevel(player : Player, end : Doors) {
		if (FlxG.keys.justPressed.UP && end.open) {
			levelEnded = true;
			/*
			var head = new FlxObject(player.x + player.width / 2, player.y + 5, 1, 1);
			
			FlxG.camera.follow(head, FlxCamera.STYLE_LOCKON);
			trace(FlxG.camera.target.x);
			*/
			//FlxG.camera.flash(0, 100);
			//FlxG.camera.shake(0.001, 1);
			new FlxTimer(1.5, function(Timer:FlxTimer){FlxG.switchState(new MenuState());}, 1);
		}
	}
	public function catD(Timer:FlxTimer) {
		FlxG.camera.flash(0xFFFFFF, 0.3);
		cat.visible = false;
		Timer.destroy();
		cat.touched = false;
		cat.exists = false;
		end.animation.play("open");
	}
	public function collectCat(player : Player, cat : Cat) {
		cat.visible = true;
		cat.touched = true;
		cat.solid = false;
		catGlitch.exists = false;
		new FlxTimer(1.5, catD, 1);
	}
	public function spawnPlayer() {
		if(player!=null)remove(player);
		player = new Player(playerSpawn);
		start.animation.play("close");
		add(player);
		FlxG.camera.follow(player);
		FlxFlicker.flicker(player, 1, 0.1);
		
		if (level == 2) {
			player.acceleration.y = 250;
			for (c in coins) {
				//trace(cast(c, Coin).bugged);
				if (cast(c, Coin).bugged) {
					player.acceleration.y = 550;
				}
			}
		}
	}
	public function killPlayer(player : Player, laser : Laser) {
		if (FlxFlicker.isFlickering(player) || !laser.on) return;
		player.animation.play("die");
		player.dead = true;
		player.acceleration.y = 0;
		player.velocity.y = 0;
		player.solid = false;
		player.facingRight = true;
		if (level == 5) {
			player.solid = true; 
			player.acceleration.y = 550;
			player.velocity.y = -66.6;
		}
		if (!laser.vertical) player.y -= 5;
		new FlxTimer(2, function(Timer:FlxTimer) {player.animation.play("restart");}, 1);
	}
	public function nearLever(player : Player, lever : Lever) {
		if (FlxG.keys.justPressed.UP && !isStupidUpArrowPressed) {
			isStupidUpArrowPressed = true;
			lever.state = !lever.state;	
			for (l in lasers) { //runs twice? TODO
				if (cast(l, Laser).id == lever.opens) {
					cast(l, Laser).on = !cast(l, Laser).on;
				}
			}
		}
	}
	public function showSign(player : Player, sign : Sign) { 
		if (!sign.text.visible) {
			sign.shouldBeVisible = true;
		}
	}

	override public function update() {
		super.update();
		if ((player.velocity.x != 0 || Math.abs(player.velocity.y) > 10) && level == 6) {
			glitch.strength = 15;
		} else {
			glitch.strength = 0;
		}
		if (FlxG.keys.justReleased.UP) isStupidUpArrowPressed = false;
		
		var distance = FlxMath.distanceBetween(cat, player);
		if (distance < 100 && !cat.touched && catGlitch.exists) {
			cat.visible = false;
			catGlitch.visible = true;
			var strength = Std.int(Math.max(10 - distance / 20, 0));
			if (distance < 50) {
				strength *= 5;
			}
			catGlitch.strength = strength;
		//FlxG.camera.shake(0.001*strength, 0.1);
		} else {
			//catGlitch.strength = 0;
			catGlitch.visible = false;
			cat.visible = true;
		}
		
		background.scrollFactor.x = FlxG.camera.scroll.x/background.width*0.9;
		FlxG.collide(player, map);
		FlxG.overlap(player, coins, collectCoin);
		FlxG.collide(player, cat, collectCat);
		FlxG.overlap(player, lasers, killPlayer);
		FlxG.overlap(player, levers, nearLever);
		FlxG.overlap(player, signs, showSign);
		FlxG.overlap(player, end, nextLevel);
		//FlxG.overlap(player, misc, overlapMisc);
		FlxG.collide(player, misc);
		
		if (player.y > FlxG.worldBounds.height || player.x < 0 || player.x > FlxG.worldBounds.width) {
			spawnPlayer();
		}
		
		for (s in signs) {
			if (!FlxG.overlap(player, s) && cast(s, Sign).visible) {
				cast(s, Sign).shouldBeVisible = false;
			}
		}
		
		if (FlxG.keys.justPressed.SPACE && player.dead && level!=5) {
			spawnPlayer();
		}
		if (levelEnded) {
			cameraColor = Std.int(cameraColor/1.2);
			//FlxG.camera.angle += 1;
			//FlxG.camera.zoom += 0.1;
			//FlxG.camera.alpha = cameraColor;
			FlxG.camera.alpha -= 0.015;
			//FlxG.camera.zoom -= 0.02;
			//FlxG.camera.x += 1.7;
			//FlxG.camera.y += 1.7;
		}
		if (cat.touched || ( player.dead && level != 5) || levelEnded) return;
		
		if (FlxG.keys.pressed.RIGHT) {
			player.velocity.x = 125;
			player.facingRight = true;
		} else if (FlxG.keys.pressed.LEFT) {
			player.velocity.x = -125;
			player.facingRight = false;
		}
		
		if (FlxG.keys.justPressed.SPACE && player.isTouching(FlxObject.FLOOR)) {
			player.velocity.y = -250;
		}
		if (FlxG.keys.justReleased.SPACE && player.velocity.y < 0) {
			player.velocity.y  = 0;
			player.animation.frameIndex = 2;
		}
	}
	function parseMap(map:String) {
		var items = map.split("[]");
		parseTiles(items[0].split("data=")[1]);
		for (x in 1...items.length) {
			//trace(x + " " + items[x]);
			var ids = items[x].substring(2, items[x].length - 3).split("\n");
			
			var entry = ids[0].split("=");
			var pos4 = ids[1].split("=")[1].substring(0, ids[1].split("=")[1].length - 3);
			var pos2 = pos4.split(",");
			
			var posX = Std.parseInt(pos2[0]);
			var posY = Std.parseInt(pos2[1]) -1;
			var type = entry[1].substring(0, entry[1].length - 1);
			//trace (entry[0] + "X" + entry[1]);
			//trace( + " " + posX + " " + posY);
			switch(type) {
				case "Coin":
					coins.add(new Coin(posX*16, posY*16));
				case "Lever":
					var opens = ids[2].split("=")[1].substr(0, ids[2].split("=")[1].length-1);
					levers.add(new Lever(posX * 16, posY * 16, Std.parseInt(opens)));
				case "Laser":
					var ID = ids[2].split("=")[1].substr(0, ids[2].split("=")[1].length - 1);
					var vertical = ids[3].split("=")[1].substr(0, ids[3].split("=")[1].length - 1);
					var reverted = ids[4].split("=")[1].substr(0, ids[4].split("=")[1].length - 1);
					lasers.add(new Laser(posX * 16, posY * 16, Std.parseInt(vertical) == 1, Std.parseInt(ID), Std.parseInt(reverted) == 1));
					
				case "Start":
					playerSpawn = new Point(posX * 16+8, posY * 16);
					start = new Doors(posX * 16, posY * 16, true);
					add(start);
				case "End":
					end = new Doors(posX * 16, posY * 16, false);
					add(end);

				case "Cat":
					cat = new Cat(posX * 16, posY * 16);
					add(cat);
				case "Sign":
					var text = ids[2].split("=")[1].substr(0, ids[2].split("=")[1].length - 1);
					var sign = new Sign(posX * 16, posY * 16, text);
					signs.add(sign);
					add(sign.text);
					
			}
		}
	}
	function parseTiles(tiles:String) {
		map = new FlxTilemap();
		map.loadMap(tiles, "assets/images/tiles.png", 16, 16, 0, 1);
		add(map);
	}
}