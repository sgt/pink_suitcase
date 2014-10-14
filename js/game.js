// Generated by CoffeeScript 1.8.0
(function() {
  var BULLET_VELOCITY, Boot, FIRE_RATE, HEIGHT, HappyBirthday, LEVELS, Load, Stage, Title, WIDTH;

  WIDTH = 800;

  HEIGHT = 600;

  LEVELS = ['moscow', 'spb', 'tbilisi', 'bangkok', 'vietnam', 'istanbul', 'kiev'];

  FIRE_RATE = 300;

  BULLET_VELOCITY = 2000;

  Boot = (function() {
    function Boot() {}

    Boot.prototype.preload = function() {
      this.game.stage.backgroundColor = '#a3b9ff';
      return this.game.load.image('loading', 'assets/loading.png');
    };

    Boot.prototype.create = function() {
      if (!this.game.device.desktop) {
        document.body.style.backgroundColor = "#a3b9ff";
        this.game.stage.scale.forceOrientation(false, true);
        this.game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL;
        this.game.stage.scale.pageAlignHorizontally = true;
        this.game.stage.scale.pageAlignVeritcally = true;
        this.game.stage.scale.setShowAll();
        this.game.stage.scale.refresh();
      }
      return this.game.state.start('load');
    };

    return Boot;

  })();

  Load = (function() {
    function Load() {}

    Load.prototype.preload = function() {
      var city, label, label2, label_x, label_y, preloading, _i, _len;
      label_x = Math.floor(WIDTH / 2) + 0.5;
      label_y = Math.floor(HEIGHT / 2) - 30 + 0.5;
      label = 'Загружается...\nНе можешь потерпеть две минуты?!';
      label2 = this.game.add.text(label_x, label_y, label, {
        font: '30px Arial',
        fill: '#fff'
      });
      label2.anchor.setTo(0.5, 0.5);
      preloading = this.game.add.sprite(WIDTH / 2, HEIGHT / 2 + 19, 'loading');
      preloading.x -= preloading.width / 2;
      this.game.load.setPreloadSprite(preloading);
      this.game.load.audio('shot-sound', 'assets/shot.wav');
      this.game.load.audio('boss-hit-sound', 'assets/boss-hit.wav');
      this.game.load.image('title', 'assets/title.png');
      this.game.load.image('start-button', 'assets/start-button.png');
      this.game.load.image('suitcase', 'assets/suitcase.gif');
      this.game.load.image('bullet', 'assets/bullet.png');
      for (_i = 0, _len = LEVELS.length; _i < _len; _i++) {
        city = LEVELS[_i];
        this.game.load.image("backdrop-" + city, "assets/" + city + ".jpg");
        this.game.load.image("boss-" + city, "assets/boss_" + city + ".gif");
      }
      this.game.load.image('backdrop-happy-birthday', 'assets/happy-birthday.png');
      return this.game.load.image('all-bosses', 'assets/all-bosses.png');
    };

    Load.prototype.create = function() {
      return this.game.state.start("title");
    };

    return Load;

  })();

  Title = (function() {
    function Title() {}

    Title.prototype.create = function() {
      var button;
      this.game.add.sprite(0, 0, 'title');
      button = this.game.add.button(WIDTH / 2, HEIGHT - 120, 'start-button', this.start, this);
      return button.anchor.setTo(0.5);
    };

    Title.prototype.start = function() {
      return this.game.state.start("stage-" + LEVELS[0]);
    };

    return Title;

  })();

  Stage = (function() {
    function Stage(city, bossHitpoints) {
      this.city = city;
      this.bossHitpoints = bossHitpoints != null ? bossHitpoints : 5;
    }

    Stage.prototype.create = function() {
      var boss_img, boss_x, boss_y;
      this.shot = this.game.add.audio('shot-sound');
      this.bossHit = this.game.add.audio('boss-hit-sound');
      this.game.add.sprite(0, 0, "backdrop-" + this.city);
      this.suitcase = this.game.add.sprite(10, 200, 'suitcase');
      this.game.add.tween(this.suitcase).to({
        y: 180
      }, 100, Phaser.Easing.Linear.None, true, 0, Number.MAX_VALUE, true);
      boss_img = this.game.cache.getImage("boss-" + this.city);
      boss_x = WIDTH - (boss_img.width / 2) - 50;
      boss_y = boss_img.height + 50;
      this.boss = this.game.add.sprite(boss_x, boss_y, "boss-" + this.city);
      this.boss.anchor.setTo(0.5, 1);
      this.game.physics.enable(this.boss, Phaser.Physics.ARCADE);
      this.game.add.tween(this.boss).to({
        y: HEIGHT - 50
      }, 2000, Phaser.Easing.Sinusoidal.InOut, true, 0, Number.MAX_VALUE, true);
      this.nextFire = 0;
      this.bullets = this.game.add.group();
      this.bullets.enableBody = true;
      this.bullets.physicsBodyType = Phaser.Physics.ARCADE;
      this.bullets.createMultiple(30, 'bullet');
      this.bullets.setAll('checkWorldBounds', true);
      return this.bullets.setAll('outOfBoundsKill', true);
    };

    Stage.prototype.update = function() {
      if (this.game.input.activePointer.isDown) {
        this.fire();
      }
      return this.game.physics.arcade.overlap(this.bullets, this.boss, this.onBossHit, null, this);
    };

    Stage.prototype.fire = function() {
      var bullet, bullet_origin_x, bullet_origin_y;
      if (this.game.time.now > this.nextFire && this.bullets.countDead() > 0) {
        this.nextFire = this.game.time.now + FIRE_RATE;
        bullet = this.bullets.getFirstExists(false);
        if (bullet) {
          bullet_origin_x = this.suitcase.x + (this.suitcase.width / 2);
          bullet_origin_y = this.suitcase.y + (this.suitcase.height / 2);
          bullet.reset(bullet_origin_x, bullet_origin_y);
          this.game.physics.arcade.moveToPointer(bullet, BULLET_VELOCITY);
          return this.shot.play();
        }
      }
    };

    Stage.prototype.onBossHit = function(boss, bullet) {
      bullet.kill();
      this.bossHit.play();
      this.game.add.tween(boss).to({
        tint: 0xff0000
      }, 50, Phaser.Easing.Linear.None, true, 0, 3, true);
      if (--this.bossHitpoints === 0) {
        boss.kill();
        return this.game.state.start(this.nextStage());
      }
    };

    Stage.prototype.nextStage = function() {
      var idx;
      idx = LEVELS.indexOf(this.city);
      if (idx === LEVELS.length - 1) {
        return 'happy-birthday';
      } else {
        return "stage-" + LEVELS[idx + 1];
      }
    };

    Stage.prototype.render = function() {};

    return Stage;

  })();

  HappyBirthday = (function() {
    function HappyBirthday() {}

    HappyBirthday.prototype.create = function() {
      this.game.add.sprite(0, 0, 'backdrop-happy-birthday');
      this.bosses = this.game.add.sprite(0, HEIGHT, 'all-bosses');
      this.bosses.anchor.set(0, 1);
      return this.game.add.tween(this.bosses).to({
        y: HEIGHT + 10
      }, 500, Phaser.Easing.Linear.None, true, 0, Number.MAX_VALUE, true);
    };

    return HappyBirthday;

  })();

  window.ready = (function() {
    var city, game, _i, _len;
    game = new Phaser.Game(WIDTH, HEIGHT, Phaser.AUTO, 'game_div');
    game.state.add('boot', Boot);
    game.state.add('load', Load);
    game.state.add('title', Title);
    for (_i = 0, _len = LEVELS.length; _i < _len; _i++) {
      city = LEVELS[_i];
      game.state.add("stage-" + city, new Stage(city));
    }
    game.state.add('happy-birthday', HappyBirthday);
    return game.state.start('boot');
  })();

}).call(this);

//# sourceMappingURL=game.js.map
