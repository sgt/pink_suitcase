WIDTH = 800
HEIGHT = 600
LEVELS = ['moscow', 'spb', 'tbilisi', 'bangkok', 'vietnam', 'istanbul', 'kiev']
FIRE_RATE = 300
BULLET_VELOCITY = 2000

class Boot
  preload: ->
    @game.stage.backgroundColor = '#a3b9ff'
    @game.load.image 'loading', 'assets/loading.png'

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
    label_x = Math.floor(WIDTH / 2) + 0.5
    label_y = Math.floor(HEIGHT / 2) - 30 + 0.5
    label = 'Загружается...\nНе можешь потерпеть две минуты?!'
    label2 = @game.add.text label_x, label_y, label, { font: '30px Arial', fill: '#fff' }
    label2.anchor.setTo 0.5, 0.5

    preloading = @game.add.sprite WIDTH / 2, HEIGHT / 2 + 19, 'loading'
    preloading.x -= preloading.width / 2
    @game.load.setPreloadSprite preloading

    @game.load.audio 'shot-sound', 'assets/shot.wav'
    @game.load.audio 'boss-hit-sound', 'assets/boss-hit.wav'

    @game.load.image 'title', 'assets/title.png'
    @game.load.image 'start-button', 'assets/start-button.png'

    @game.load.image 'suitcase', 'assets/suitcase.gif'
    @game.load.image 'bullet', 'assets/bullet.png'

    for city in LEVELS
      @game.load.image "backdrop-#{city}", "assets/#{city}.jpg"
      @game.load.image "boss-#{city}", "assets/boss_#{city}.gif"

    @game.load.image 'backdrop-happy-birthday', 'assets/happy-birthday.png'
    @game.load.image 'all-bosses', 'assets/all-bosses.png'


  create: ->
    @game.state.start "title"


class Title
  create: ->
    @game.add.sprite 0, 0, 'title'
    button = @game.add.button WIDTH / 2, HEIGHT - 120, 'start-button', @start, @
    button.anchor.setTo 0.5

  start: ->
    @game.state.start "stage-#{LEVELS[0]}"


class Stage
  constructor: (@city, @bossHitpoints=5) ->

  create: ->
    @shot = @game.add.audio 'shot-sound'
    @bossHit = @game.add.audio 'boss-hit-sound'

    @game.add.sprite 0, 0, "backdrop-#{@city}"
    @suitcase = @game.add.sprite 10, 200, 'suitcase'
    @game.add.tween(@suitcase).to {y: 180}, 100, Phaser.Easing.Linear.None, true, 0, Number.MAX_VALUE, true

    boss_img = @game.cache.getImage "boss-#{@city}"
    boss_x = WIDTH - (boss_img.width / 2) - 50
    boss_y = boss_img.height + 50
    @boss = @game.add.sprite boss_x, boss_y, "boss-#{@city}"
    @boss.anchor.setTo 0.5, 1
    @game.physics.enable @boss, Phaser.Physics.ARCADE
    @game.add.tween(@boss).to {y : HEIGHT - 50}, 2000, Phaser.Easing.Sinusoidal.InOut, true, 0, Number.MAX_VALUE, true

    @nextFire = 0

    @bullets = @game.add.group()
    @bullets.enableBody = true
    @bullets.physicsBodyType = Phaser.Physics.ARCADE;
    @bullets.createMultiple 30, 'bullet'
    @bullets.setAll 'checkWorldBounds', true
    @bullets.setAll 'outOfBoundsKill', true

  update: ->
    if @game.input.activePointer.isDown
      @fire()

    @game.physics.arcade.overlap(@bullets, @boss, @onBossHit, null, @)

  fire: ->
    if @game.time.now > @nextFire and @bullets.countDead() > 0
      @nextFire = @game.time.now + FIRE_RATE
      bullet = @bullets.getFirstExists false
      if bullet
        bullet_origin_x = @suitcase.x + (@suitcase.width / 2)
        bullet_origin_y = @suitcase.y + (@suitcase.height / 2)
        bullet.reset bullet_origin_x, bullet_origin_y
        #bullet.body.velocity.x = BULLET_VELOCITY
        @game.physics.arcade.moveToPointer bullet, BULLET_VELOCITY
        @shot.play()

  onBossHit: (boss, bullet) ->
    bullet.kill()
    @bossHit.play()
    @game.add.tween(boss).to {tint: 0xff0000}, 50, Phaser.Easing.Linear.None, true, 0, 3, true
    if --@bossHitpoints is 0
      boss.kill()
      @game.state.start @nextStage()

  nextStage: ->
    idx = LEVELS.indexOf @city
    if idx is LEVELS.length - 1
      'happy-birthday'
    else
      "stage-#{LEVELS[idx + 1]}"

  render: ->
    #@game.debug.body @boss


class HappyBirthday
  create: ->
    @game.add.sprite 0, 0, 'backdrop-happy-birthday'
    @bosses = @game.add.sprite 0, HEIGHT, 'all-bosses'
    @bosses.anchor.set 0, 1
    @game.add.tween(@bosses).to {y: HEIGHT + 10}, 500, Phaser.Easing.Linear.None, true, 0, Number.MAX_VALUE, true


window.ready = (->
  game = new Phaser.Game(WIDTH, HEIGHT, Phaser.AUTO, 'game_div')

  game.state.add 'boot', Boot
  game.state.add 'load', Load
  game.state.add 'title', Title
  for city in LEVELS
    game.state.add "stage-#{city}", new Stage(city)
  game.state.add 'happy-birthday', HappyBirthday

  game.state.start 'boot')()
