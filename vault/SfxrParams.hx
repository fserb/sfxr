package vault;

class SfxrParams {
  public var waveType:UInt = 0;                // Shape of the wave (0:square, 1:saw, 2:sin or 3:noise)
  public var masterVolume:Float = 0.5;         // Overall volume of the sound (0 to 1)

  public var attackTime:Float = 0.0;           // Length of the volume envelope attack (0 to 1)
  public var sustainTime:Float = 0.3;          // Length of the volume envelope sustain (0 to 1)
  public var sustainPunch:Float = 0.0;         // Tilts the sustain envelope for more 'pop' (0 to 1)
  public var decayTime:Float = 0.4;            // Length of the volume envelope decay (yes, I know it's called release) (0 to 1)

  public var startFrequency:Float = 0.3;       // Base note of the sound (0 to 1)
  public var minFrequency:Float = 0.0;         // If sliding, the sound will stop at this frequency, to prevent really low notes (0 to 1)

  public var slide:Float = 0.0;                // Slides the note up or down (-1 to 1)
  public var deltaSlide:Float = 0.0;           // Accelerates the slide (-1 to 1)

  public var vibratoDepth:Float = 0.0;         // Strength of the vibrato effect (0 to 1)
  public var vibratoSpeed:Float = 0.0;         // Speed of the vibrato effect (i.e. frequency) (0 to 1)

  public var changeAmount:Float = 0.0;         // Shift in note, either up or down (-1 to 1)
  public var changeSpeed:Float = 0.0;          // How fast the note shift happens (only happens once) (0 to 1)

  public var squareDuty:Float = 0.0;           // Controls the ratio between the up and down states of the square wave, changing the tibre (0 to 1)
  public var dutySweep:Float = 0.0;            // Sweeps the duty up or down (-1 to 1)

  public var repeatSpeed:Float = 0.0;          // Speed of the note repeating - certain variables are reset each time (0 to 1)

  public var phaserOffset:Float = 0.0;         // Offsets a second copy of the wave by a small phase, changing the tibre (-1 to 1)
  public var phaserSweep:Float = 0.0;          // Sweeps the phase up or down (-1 to 1)

  public var lpFilterCutoff:Float = 1.0;       // Frequency at which the low-pass filter starts attenuating higher frequencies (0 to 1)
  public var lpFilterCutoffSweep:Float = 0.0;  // Sweeps the low-pass cutoff up or down (-1 to 1)
  public var lpFilterResonance:Float = 0.0;    // Changes the attenuation rate for the low-pass filter, changing the timbre (0 to 1)

  public var hpFilterCutoff:Float = 0.0;       // Frequency at which the high-pass filter starts attenuating lower frequencies (0 to 1)
  public var hpFilterCutoffSweep:Float = 0.0;  // Sweeps the high-pass cutoff up or down (-1 to 1)

  public function new(?seed: Null<Int> = null) {
    this.seed(seed);
  }

  static public function fromString(s: String): SfxrParams {
    var p = new SfxrParams();

    var values = s.split(",");

    if (values.length != 24) return null;

    var float = function(x: String): Float {
      var f = Std.parseFloat(x);
      return Math.isNaN(f) ? 0 : f;
    };

    var v = Std.parseInt(values[0]);
    p.waveType = v == null ? 0 : v;
    p.attackTime = float(values[1]);
    p.sustainTime = float(values[2]);
    p.sustainPunch = float(values[3]);
    p.decayTime = float(values[4]);
    p.startFrequency = float(values[5]);
    p.minFrequency = float(values[6]);
    p.slide = float(values[7]);
    p.deltaSlide = float(values[8]);
    p.vibratoDepth = float(values[9]);
    p.vibratoSpeed = float(values[10]);
    p.changeAmount = float(values[11]);
    p.changeSpeed = float(values[12]);
    p.squareDuty = float(values[13]);
    p.dutySweep = float(values[14]);
    p.repeatSpeed = float(values[15]);
    p.phaserOffset = float(values[16]);
    p.phaserSweep = float(values[17]);
    p.lpFilterCutoff = float(values[18]);
    p.lpFilterCutoffSweep = float(values[19]);
    p.lpFilterResonance = float(values[20]);
    p.hpFilterCutoff = float(values[21]);
    p.hpFilterCutoffSweep = float(values[22]);
    p.masterVolume = float(values[23]);

    return p;
  }

  public function generatePickupCoin() {
    startFrequency = 0.4 + random() * 0.5;
    sustainTime = random() * 0.1;
    decayTime = 0.1 + random() * 0.4;
    sustainPunch = 0.3 + random() * 0.3;
    if(random() < 0.5) {
      changeSpeed = 0.5 + random() * 0.2;
      changeAmount = 0.2 + random() * 0.4;
    }
  }

  public function generateLaserShoot() {
    waveType = Std.int(random() * 3);
    if(waveType == 2 && random() < 0.5) waveType = Std.int(random() * 2);
    startFrequency = 0.5 + random() * 0.5;
    minFrequency = startFrequency - 0.2 - random() * 0.6;
    if(minFrequency < 0.2) minFrequency = 0.2;
    slide = -0.15 - random() * 0.2;
    if(random() < 0.33) {
      startFrequency = 0.3 + random() * 0.6;
      minFrequency = random() * 0.1;
      slide = -0.35 - random() * 0.3;
    }
    if(random() < 0.5) {
      squareDuty = random() * 0.5;
      dutySweep = random() * 0.2;
    } else {
      squareDuty = 0.4 + random() * 0.5;
      dutySweep =- random() * 0.7;
    }
    sustainTime = 0.1 + random() * 0.2;
    decayTime = random() * 0.4;
    if(random() < 0.5) sustainPunch = random() * 0.3;
    if(random() < 0.33) {
      phaserOffset = random() * 0.2;
      phaserSweep = -random() * 0.2;
    }
    if(random() < 0.5) hpFilterCutoff = random() * 0.3;
  }

  public function generateExplosion() {
    waveType = 3;
    if(random() < 0.5) {
      startFrequency = 0.1 + random() * 0.4;
      slide = -0.1 + random() * 0.4;
    } else {
      startFrequency = 0.2 + random() * 0.7;
      slide = -0.2 - random() * 0.2;
    }

    startFrequency *= startFrequency;

    if(random() < 0.2) slide = 0.0;
    if(random() < 0.33) repeatSpeed = 0.3 + random() * 0.5;

    sustainTime = 0.1 + random() * 0.3;
    decayTime = random() * 0.5;
    sustainPunch = 0.2 + random() * 0.6;

    if(random() < 0.5) {
      phaserOffset = -0.3 + random() * 0.9;
      phaserSweep = -random() * 0.3;
    }

    if(random() < 0.33) {
      changeSpeed = 0.6 + random() * 0.3;
      changeAmount = 0.8 - random() * 1.6;
    }
  }

  public function generatePowerup() {
    if (random() < 0.5) waveType = 1;
    else squareDuty = random() * 0.6;
    if (random() < 0.5) {
      startFrequency = 0.2 + random() * 0.3;
      slide = 0.1 + random() * 0.4;
      repeatSpeed = 0.4 + random() * 0.4;
    } else {
      startFrequency = 0.2 + random() * 0.3;
      slide = 0.05 + random() * 0.2;
      if(random() < 0.5) {
        vibratoDepth = random() * 0.7;
        vibratoSpeed = random() * 0.6;
      }
    }
    sustainTime = random() * 0.4;
    decayTime = 0.1 + random() * 0.4;
  }

  public function generateHitHurt() {
    waveType = Std.int(random() * 3);
    if(waveType == 2) waveType = 3;
    else if(waveType == 0) squareDuty = random() * 0.6;
    startFrequency = 0.2 + random() * 0.6;
    slide = -0.3 - random() * 0.4;
    sustainTime = random() * 0.1;
    decayTime = 0.1 + random() * 0.2;
    if(random() < 0.5) hpFilterCutoff = random() * 0.3;
  }

  public function generateJump() {
    waveType = 0;
    squareDuty = random() * 0.6;
    startFrequency = 0.3 + random() * 0.3;
    slide = 0.1 + random() * 0.2;
    sustainTime = 0.1 + random() * 0.3;
    decayTime = 0.1 + random() * 0.2;
    if(random() < 0.5) hpFilterCutoff = random() * 0.3;
    if(random() < 0.5) lpFilterCutoff = 1.0 - random() * 0.6;
  }

  public function generateBlipSelect() {
    waveType = Std.int(random() * 2);
    if(waveType == 0) squareDuty = random() * 0.6;
    startFrequency = 0.2 + random() * 0.4;
    sustainTime = 0.1 + random() * 0.1;
    decayTime = random() * 0.2;
    hpFilterCutoff = 0.1;
  }

  public function mutate(mutation: Float = 0.05) {
    if (random() < 0.5) startFrequency +=    random() * mutation*2 - mutation;
    if (random() < 0.5) minFrequency +=    random() * mutation*2 - mutation;
    if (random() < 0.5) slide +=         random() * mutation*2 - mutation;
    if (random() < 0.5) deltaSlide +=      random() * mutation*2 - mutation;
    if (random() < 0.5) squareDuty +=      random() * mutation*2 - mutation;
    if (random() < 0.5) dutySweep +=       random() * mutation*2 - mutation;
    if (random() < 0.5) vibratoDepth +=    random() * mutation*2 - mutation;
    if (random() < 0.5) vibratoSpeed +=    random() * mutation*2 - mutation;
    if (random() < 0.5) attackTime +=      random() * mutation*2 - mutation;
    if (random() < 0.5) sustainTime +=     random() * mutation*2 - mutation;
    if (random() < 0.5) decayTime +=       random() * mutation*2 - mutation;
    if (random() < 0.5) sustainPunch +=    random() * mutation*2 - mutation;
    if (random() < 0.5) lpFilterCutoff +=    random() * mutation*2 - mutation;
    if (random() < 0.5) lpFilterCutoffSweep += random() * mutation*2 - mutation;
    if (random() < 0.5) lpFilterResonance +=   random() * mutation*2 - mutation;
    if (random() < 0.5) hpFilterCutoff +=    random() * mutation*2 - mutation;
    if (random() < 0.5) hpFilterCutoffSweep += random() * mutation*2 - mutation;
    if (random() < 0.5) phaserOffset +=    random() * mutation*2 - mutation;
    if (random() < 0.5) phaserSweep +=     random() * mutation*2 - mutation;
    if (random() < 0.5) repeatSpeed +=     random() * mutation*2 - mutation;
    if (random() < 0.5) changeSpeed +=     random() * mutation*2 - mutation;
    if (random() < 0.5) changeAmount +=    random() * mutation*2 - mutation;
  }

  public function randomize() {
    waveType = Std.int(random() * 4);
    attackTime =     Math.pow(random()*2-1, 4);
    sustainTime =    Math.pow(random()*2-1, 2);
    sustainPunch =   Math.pow(random()*0.8, 2);
    decayTime =      random();
    startFrequency =   (random() < 0.5) ? Math.pow(random()*2-1, 2) : (Math.pow(random() * 0.5, 3) + 0.5);
    minFrequency =   0.0;
    slide =        Math.pow(random()*2-1, 5);
    deltaSlide =     Math.pow(random()*2-1, 3);
    vibratoDepth =   Math.pow(random()*2-1, 3);
    vibratoSpeed =   random()*2-1;
    changeAmount =   random()*2-1;
    changeSpeed =    random()*2-1;
    squareDuty =     random()*2-1;
    dutySweep =      Math.pow(random()*2-1, 3);
    repeatSpeed =    random()*2-1;
    phaserOffset =   Math.pow(random()*2-1, 3);
    phaserSweep =    Math.pow(random()*2-1, 3);
    lpFilterCutoff =     1 - Math.pow(random(), 3);
    lpFilterCutoffSweep =  Math.pow(random()*2-1, 3);
    lpFilterResonance =    random()*2-1;
    hpFilterCutoff =     Math.pow(random(), 5);
    hpFilterCutoffSweep =  Math.pow(random()*2-1, 5);

    if(attackTime + sustainTime + decayTime < 0.2) {
      sustainTime = 0.2 + random() * 0.3;
      decayTime = 0.2 + random() * 0.3;
    }

    if((startFrequency > 0.7 && slide > 0.2) || (startFrequency < 0.2 && slide < -0.05)) {
      slide = -slide;
    }

    if(lpFilterCutoff < 0.1 && lpFilterCutoffSweep < -0.05) {
      lpFilterCutoffSweep = -lpFilterCutoffSweep;
    }
  }


  var _randomstate: Int;
  var MAX_INT: Int = 2147483647;

  public function seed(seed: Null<Int>) {
    _randomstate = (seed != null) ? seed : Math.floor(Math.random() * MAX_INT);
  }

  function randint(): Int {
    _randomstate = cast ((1103515245.0*_randomstate + 12345) % MAX_INT);
    return _randomstate;
  }

  public function random(): Float {
    return randint() / MAX_INT;
  }
}
