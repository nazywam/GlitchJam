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
import flash.display.BitmapData;
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
	
	var bots : FlxGroup;
	
	var platform : FlxSprite;
	
	var lvl13Glitch : FlxSprite;
	
	var glitches : FlxSprite;
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
		if (level == 11) {
			FlxG.switchState(new MenuState());
		}
		if (level == 14) {
			background.loadMap(Assets.getText("assets/data/lvl14Background.txt"), "assets/images/lvl14Background.png", 128, 128, 0, 1);
		} else if (level == 15) {
			background.loadMap(Assets.getText("assets/data/background.tmx"), "assets/images/glitches.png", 0, 0, 0, 1);
		}else {
			background.loadMap(Assets.getText("assets/data/background.tmx"), "assets/images/background_bw.png", 128, 128, 0, 1);
		}
			
		
		add(background);
		
		isStupidUpArrowPressed = false;
		
		cameraColor = 0xFFFFFF;
		
		levelEnded = false;
		
		misc = new FlxGroup();
		add(misc);
		
		bots = new FlxGroup();
		add(bots);
		
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
		
		if (level != 9 && level != 2) {
			spawnPlayer();
		}

		FlxG.camera.setBounds(0, 0, FlxG.worldBounds.x, FlxG.worldBounds.y, true);
		FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);
		
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
				spawnPlayer();
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
				glitch.x = 20;
				glitch.y = 20;
				add(glitch);
			case 8:
				for (x in 0...80) {
					player.color = Std.random(0xFFFFFF);
					var a = new Player(new Point(20+Std.random(500), 20));
					a.drag.x = 0;
					a.color = Std.random(0xFFFFFF);
					a.bot = true;
					a.velocity.x = 125 - 256 * Std.random(2);
					a.facingRight = a.velocity.x > 0; 
					bots.add(a);
				}
			case 9:
				playerSpawn = new Point(1 * 16 + 8, 2 * 16);
				start = new Doors(1 * 16, 2 * 16, true);
				add(start);
				
				platform = new FlxSprite(1 * 16, 4 * 16);
				platform.loadGraphic("assets/images/tiles.png", false, 48, 16);
				platform.immovable = true;
				add(platform);
				
				spawnPlayer();
			case 13:
				var w = FlxG.worldBounds.width;
				for (x in coins) {
					var c = cast(x, Coin);
					c.scale.x = Math.min((c.x) / 400 + 1, 2);
					c.scale.y = c.scale.x;
					c.offset.y = 4 * c.scale.x * c.scale.x;
				}
				for (x in signs) {
					var c = cast(x, Sign);
					c.scale.x = Math.min((c.x) / 400 + 1, 2);
					c.scale.y = c.scale.x;
					c.offset.y = 2 * c.scale.x * c.scale.x;
				}
				end.scale.x = Math.min((end.x) / 400 + 1, 2);
				end.scale.y = end.scale.x;
				//end.offset.y = 4 * end.scale.x * end.scale.x;
			case 12:
				//lvl13Glitch = new FlxSprite();
				//lvl13Glitch.loadGraphic("assets/images/lvl13Glitch.png", false, 300, 300);
				//add(lvl13Glitch);
				//var temp:BitmapData = lvl13Glitch.pixels;
			//	lvl13Glitch.pixels = temp;
				
				//for (x in signs) {
					//remove(cast(x, Sign).text);
					//add(cast(x, Sign).text);
					//remove(s.text);
					//add(s.text);
					
				//}
			case 14:
				start.color = 0x9d5c5f;
				end.color = 0x36647b;
		}
		
		
		catGlitch = new FlxGlitchSprite(cat);
		add(catGlitch);
		cat.visible = false;
	
		glitches = new FlxSprite();
		glitches.loadGraphic("assets/images/glitches.png", false, 320, 320);
		//glitches.pixels.fillRect(new Rectangle(10,10,20,20), 0xFFFFFFFF);
		add(glitches);
	}
	public function glitchUp() {
		var temp:BitmapData = glitches.pixels;
		var x = Std.random(Std.int(glitches.width));
		var y = Std.random(Std.int(glitches.height));
		

		var color1 = 0xF0000000 + Std.random(0xFFFFFF);
		var color2 = 0xF0000000 + Std.random(0xFFFFFF);
		//var color2 = Std.random(0xFFFFFF) * 0xFF;
		
		for (posY in 0...10) {
			if (posY % 2 == 0) {
				temp.fillRect(new Rectangle(x, y + posY * 2, 20, 2), color1);
			} else {
				temp.fillRect(new Rectangle(x, y + posY * 2, 20, 20), color2);
			}
		}
		;//Std.random(0xFF0000));
		//temp.fillRect(new Rectangle(player.x, player.y, player.width, player.height), Std.random(0xFFFFFF));

		glitches.pixels = temp;
	}
	public function collectCoin(player : Player, coin : Coin) {
		coin.animation.play("take");
		coin.solid = false;
		coins.remove(coin);
		
		if (level == 2 && player.acceleration.y == 550 && coin.bugged) {
			FlxG.sound.play("assets/sounds/coin.wav", 0.45, false, true, function() { FlxG.sound.play("assets/sounds/upgrade.wav"); } );
		} else {
			FlxG.sound.play("assets/sounds/coin.wav", 0.45);
		}
		
		if (coin.bugged) {
			if (level == 0) {
				var s = new Sign(35*16, 18*16, "PS: Coins are worthless		");
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
			new FlxTimer(1, function(Timer:FlxTimer){FlxG.switchState(new MenuState());}, 1);
		}
	}
	public function catD() {
		FlxG.camera.flash(0xFFFFFF, 0.3);
		cat.visible = false;
		//Timer.destroy();
		cat.touched = false;
		cat.exists = false;
		end.animation.play("open");
	}
	public function collectCat(player : Player, cat : Cat) {
		cat.visible = true;
		cat.touched = true;
		cat.solid = false;
		catGlitch.exists = false;
		//new FlxTimer(0, catD, 1);
		catD();
	}
	public function spawnPlayer() {
		var flickerTime = 1.0;
		if (level == 9) {
			platform.y = Math.min(platform.y+16, FlxG.worldBounds.height-32);
			playerSpawn.y = Math.min(playerSpawn.y+16, FlxG.worldBounds.height-64);
			start.y = Math.min(start.y+16, FlxG.worldBounds.height-64);

			flickerTime -= 0.7;
		}
		
		if(player!=null)remove(player);
		player = new Player(playerSpawn);
		start.animation.play("close");
		add(player);
		FlxG.camera.follow(player);
		
		if (level == 2) {
			player.acceleration.y = 250;
			for (c in coins) {
				if (cast(c, Coin).bugged) {
					player.acceleration.y = 550;
				}
			}
		}
		
		FlxFlicker.flicker(player, flickerTime, 0.1);
		
	}
	public function killPlayer(player : Player, laser : Laser) {
		if (FlxFlicker.isFlickering(player) || !laser.on) return;
		FlxG.sound.play("assets/sounds/die.wav", 0.25);
		player.dead = true;
		player.animation.play("die");
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
			FlxG.sound.play("assets/sounds/sign.wav");
		}
	}
	public function botCollide(bot : Player, map : FlxTilemap) {
		if (bot.isTouching(FlxObject.WALL)) {
			bot.velocity.x = 125 - 256 * Std.random(2);
			bot.velocity.x *= (Math.random() + 0.5);
			bot.facingRight = bot.velocity.x > 0;
		}
	}
	override public function update() {
		super.update();
		glitches.x = FlxG.camera.scroll.x;
		if((player.velocity.x != 0 || Math.abs(player.velocity.y) > 10) && level == 6) {
			glitch.strength = 15;
		} else if(level == 6) {
			glitch.strength = 0;
		} else if (level == 7) {
			var w = FlxG.worldBounds.width-20;
			if (player.x > w / 2) {
				player.flipY = true;
				player.acceleration.y = 550;
			} else {
				player.flipY = false;
				player.acceleration.y = -550;
			}
		} else if (level == 13) {
			var w = FlxG.worldBounds.width;
			player.scale.x = Math.min((player.x) / 400 + 1, 2);
			player.scale.y = player.scale.x;
			player.offset.y = 4 * player.scale.x * player.scale.x;
			player.acceleration.y = 540 / player.scale.x;
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
		FlxG.collide(bots, map, botCollide);
		//FlxG.overlap(player, misc, overlapMisc);
		FlxG.collide(player, misc);
		if (level == 9) {
			FlxG.collide(player, platform);
		}else if (level == 12) {
			var temp:BitmapData = lvl13Glitch.pixels;
			temp.fillRect(new Rectangle(player.x, player.y, player.width, player.height), Std.random(0xFFFFFF));
			for (x in signs) {
				var s = cast(x, Sign);
				if (s.tweening) {
					temp.fillRect(new Rectangle(s.text.x, s.text.y, s.text.width, s.text.height), Std.random(0xFFFFFF));
				}
			}
			lvl13Glitch.pixels = temp;
		}
		
		if (player.y > FlxG.worldBounds.height || player.x < 0 || player.x > FlxG.worldBounds.width) {
			if (level == 13 && player.x > FlxG.worldBounds.width && signs.length < 5) {
				for (x in 0...35) {
					var a = new Sign(32 + x * 16, 18 * 16, "H@ckOrz");
					signs.add(a);
					add(a.text);
				}
				for (x in signs) {
					var c = cast(x, Sign);
					c.scale.x = Math.min((c.x) / 400 + 1, 2);
					c.scale.y = c.scale.x;
					c.offset.y = 2 * c.scale.x * c.scale.x;
				}
			}
			if (level == 15 && player.y > FlxG.worldBounds.height) {
				player.y = 0;
			} else {
				spawnPlayer();
			}
			
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
		
		var level7Bug : Bool = level == 7 && player.x < FlxG.worldBounds.width / 2;
		
		if (FlxG.keys.justPressed.SPACE && (player.isTouching(FlxObject.FLOOR) || (level7Bug && player.isTouching(FlxObject.CEILING)))) {
			player.velocity.y = -250;
			if (level7Bug) {
				player.velocity.y = 250;
			}
			FlxG.sound.play("assets/sounds/jump.wav");
		}
		if (FlxG.keys.justReleased.SPACE && player.velocity.y < 0) {
			player.velocity.y  = 0;
			player.animation.frameIndex = 2;
		}

	}
	function parseMap(map:String) {
		var items = map.split("[]");
		parseTiles(items[0].split("data=")[1]);
		if (level == 12) {
			lvl13Glitch = new FlxSprite();
			lvl13Glitch.loadGraphic("assets/images/lvl13Glitch.png", false, 300, 300);
			add(lvl13Glitch);
		}
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