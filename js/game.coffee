w = 800
h = 600

rand = (num) ->
  Math.floor(Math.random() * num)


class Boot
  preload: ->
    @game.stage.backgroundColor = '#a3b9ff'
    @game.load.image 'loading', 'images/loading.png'

  create: ->
    if not @game.device.desktop
      document.body.style.backgroundColor = "#a3b9ff"
      @game.stage.scale.forceOrientation false, true
      @game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL
      @game.stage.scale.pageAlignHorizontally = true
      @game.stage.scale.pageAlignVeritcally = true
      @game.stage.scale.setShowAll()
      @game.stage.scale.refresh()

    @game.state.start 'load'


class Load
  preload: ->
    label2 = @game.add.text(Math.floor(w / 2) + 0.5, Math.floor(h / 2) - 15 + 0.5, 'loading...',
      { font: '30px Arial', fill: '#fff' });
    label2.anchor.setTo(0.5, 0.5);

    preloading = @game.add.sprite w / 2, h / 2 + 19, 'loading'
    preloading.x -= preloading.width / 2;
    @game.load.setPreloadSprite preloading

#    game.load.image('heart', 'images/heart.png');
#    game.load.image('spike', 'images/spike.png');
#    game.load.image('cloud', 'images/cloud.png');
#    game.load.image('ground', 'images/ground.png');
#    game.load.image('platform', 'images/platform.png');
#    game.load.image('princess_zoom', 'images/princess_zoom.png');
#    game.load.spritesheet('princess', 'images/princess.png', 52, 72);
#    game.load.image('line', 'images/line.png');
#
#    game.load.spritesheet('mute', 'images/mute.png', 28, 18);
#
#    game.load.audio('dead', 'sounds/dead.wav');
#    game.load.audio('jump', 'sounds/jump.wav');
#    game.load.audio('heart', 'sounds/heart.wav');
#    game.load.audio('music', 'sounds/music.wav');
#    game.load.audio('hit', 'sounds/hit.wav');

  create: ->
    @game.state.start('play')


class Menu
  create: ->
    space_key = @game.input.keyboard.addKey Phaser.Keyboard.SPACEBAR
    space_key.onDown.add @start, @

    style = { font: "30px Arial", fill: "#fff" }
    x = @game.world.width / 2
    y = @game.world.height / 2

    text = @game.add.text x, y - 50, "Press space to start", style
    text.anchor.setTo 0.5, 0.5

  start: ->
    @game.state.start 'play'

class Play
  create: ->

window.ready = (->
  game = new Phaser.Game(w, h, Phaser.AUTO, 'game_div')

  game.state.add 'boot', Boot
  game.state.add 'load', Load
  game.state.add 'menu', Menu
  game.state.add 'play', Play

  game.state.start 'boot'
)()