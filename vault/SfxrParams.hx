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

  public function new() { }

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
    startFrequency = 0.4 + Math.random() * 0.5;
    sustainTime = Math.random() * 0.1;
    decayTime = 0.1 + Math.random() * 0.4;
    sustainPunch = 0.3 + Math.random() * 0.3;
    if(Math.random() < 0.5) {
      changeSpeed = 0.5 + Math.random() * 0.2;
      changeAmount = 0.2 + Math.random() * 0.4;
    }
  }

  public function generateLaserShoot() {
    waveType = Std.int(Math.random() * 3);
    if(waveType == 2 && Math.random() < 0.5) waveType = Std.int(Math.random() * 2);
    startFrequency = 0.5 + Math.random() * 0.5;
    minFrequency = startFrequency - 0.2 - Math.random() * 0.6;
    if(minFrequency < 0.2) minFrequency = 0.2;
    slide = -0.15 - Math.random() * 0.2;
    if(Math.random() < 0.33) {
      startFrequency = 0.3 + Math.random() * 0.6;
      minFrequency = Math.random() * 0.1;
      slide = -0.35 - Math.random() * 0.3;
    }
    if(Math.random() < 0.5) {
      squareDuty = Math.random() * 0.5;
      dutySweep = Math.random() * 0.2;
    } else {
      squareDuty = 0.4 + Math.random() * 0.5;
      dutySweep =- Math.random() * 0.7;
    }
    sustainTime = 0.1 + Math.random() * 0.2;
    decayTime = Math.random() * 0.4;
    if(Math.random() < 0.5) sustainPunch = Math.random() * 0.3;
    if(Math.random() < 0.33) {
      phaserOffset = Math.random() * 0.2;
      phaserSweep = -Math.random() * 0.2;
    }
    if(Math.random() < 0.5) hpFilterCutoff = Math.random() * 0.3;
  }

  public function generateExplosion() {
    waveType = 3;
    if(Math.random() < 0.5) {
      startFrequency = 0.1 + Math.random() * 0.4;
      slide = -0.1 + Math.random() * 0.4;
    } else {
      startFrequency = 0.2 + Math.random() * 0.7;
      slide = -0.2 - Math.random() * 0.2;
    }

    startFrequency *= startFrequency;

    if(Math.random() < 0.2) slide = 0.0;
    if(Math.random() < 0.33) repeatSpeed = 0.3 + Math.random() * 0.5;

    sustainTime = 0.1 + Math.random() * 0.3;
    decayTime = Math.random() * 0.5;
    sustainPunch = 0.2 + Math.random() * 0.6;

    if(Math.random() < 0.5) {
      phaserOffset = -0.3 + Math.random() * 0.9;
      phaserSweep = -Math.random() * 0.3;
    }

    if(Math.random() < 0.33) {
      changeSpeed = 0.6 + Math.random() * 0.3;
      changeAmount = 0.8 - Math.random() * 1.6;
    }
  }

  public function generatePowerup() {
    if (Math.random() < 0.5) waveType = 1;
    else squareDuty = Math.random() * 0.6;
    if (Math.random() < 0.5) {
      startFrequency = 0.2 + Math.random() * 0.3;
      slide = 0.1 + Math.random() * 0.4;
      repeatSpeed = 0.4 + Math.random() * 0.4;
    } else {
      startFrequency = 0.2 + Math.random() * 0.3;
      slide = 0.05 + Math.random() * 0.2;
      if(Math.random() < 0.5) {
        vibratoDepth = Math.random() * 0.7;
        vibratoSpeed = Math.random() * 0.6;
      }
    }
    sustainTime = Math.random() * 0.4;
    decayTime = 0.1 + Math.random() * 0.4;
  }

  public function generateHitHurt() {
    waveType = Std.int(Math.random() * 3);
    if(waveType == 2) waveType = 3;
    else if(waveType == 0) squareDuty = Math.random() * 0.6;
    startFrequency = 0.2 + Math.random() * 0.6;
    slide = -0.3 - Math.random() * 0.4;
    sustainTime = Math.random() * 0.1;
    decayTime = 0.1 + Math.random() * 0.2;
    if(Math.random() < 0.5) hpFilterCutoff = Math.random() * 0.3;
  }

  public function generateJump() {
    waveType = 0;
    squareDuty = Math.random() * 0.6;
    startFrequency = 0.3 + Math.random() * 0.3;
    slide = 0.1 + Math.random() * 0.2;
    sustainTime = 0.1 + Math.random() * 0.3;
    decayTime = 0.1 + Math.random() * 0.2;
    if(Math.random() < 0.5) hpFilterCutoff = Math.random() * 0.3;
    if(Math.random() < 0.5) lpFilterCutoff = 1.0 - Math.random() * 0.6;
  }

  public function generateBlipSelect() {
    waveType = Std.int(Math.random() * 2);
    if(waveType == 0) squareDuty = Math.random() * 0.6;
    startFrequency = 0.2 + Math.random() * 0.4;
    sustainTime = 0.1 + Math.random() * 0.1;
    decayTime = Math.random() * 0.2;
    hpFilterCutoff = 0.1;
  }

  public function mutate(mutation: Float = 0.05) {
    if (Math.random() < 0.5) startFrequency +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) minFrequency +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) slide +=         Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) deltaSlide +=      Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) squareDuty +=      Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) dutySweep +=       Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) vibratoDepth +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) vibratoSpeed +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) attackTime +=      Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) sustainTime +=     Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) decayTime +=       Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) sustainPunch +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) lpFilterCutoff +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) lpFilterCutoffSweep += Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) lpFilterResonance +=   Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) hpFilterCutoff +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) hpFilterCutoffSweep += Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) phaserOffset +=    Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) phaserSweep +=     Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) repeatSpeed +=     Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) changeSpeed +=     Math.random() * mutation*2 - mutation;
    if (Math.random() < 0.5) changeAmount +=    Math.random() * mutation*2 - mutation;
  }

  public function randomize() {
    waveType = Std.int(Math.random() * 4);
    attackTime =     Math.pow(Math.random()*2-1, 4);
    sustainTime =    Math.pow(Math.random()*2-1, 2);
    sustainPunch =   Math.pow(Math.random()*0.8, 2);
    decayTime =      Math.random();
    startFrequency =   (Math.random() < 0.5) ? Math.pow(Math.random()*2-1, 2) : (Math.pow(Math.random() * 0.5, 3) + 0.5);
    minFrequency =   0.0;
    slide =        Math.pow(Math.random()*2-1, 5);
    deltaSlide =     Math.pow(Math.random()*2-1, 3);
    vibratoDepth =   Math.pow(Math.random()*2-1, 3);
    vibratoSpeed =   Math.random()*2-1;
    changeAmount =   Math.random()*2-1;
    changeSpeed =    Math.random()*2-1;
    squareDuty =     Math.random()*2-1;
    dutySweep =      Math.pow(Math.random()*2-1, 3);
    repeatSpeed =    Math.random()*2-1;
    phaserOffset =   Math.pow(Math.random()*2-1, 3);
    phaserSweep =    Math.pow(Math.random()*2-1, 3);
    lpFilterCutoff =     1 - Math.pow(Math.random(), 3);
    lpFilterCutoffSweep =  Math.pow(Math.random()*2-1, 3);
    lpFilterResonance =    Math.random()*2-1;
    hpFilterCutoff =     Math.pow(Math.random(), 5);
    hpFilterCutoffSweep =  Math.pow(Math.random()*2-1, 5);

    if(attackTime + sustainTime + decayTime < 0.2) {
      sustainTime = 0.2 + Math.random() * 0.3;
      decayTime = 0.2 + Math.random() * 0.3;
    }

    if((startFrequency > 0.7 && slide > 0.2) || (startFrequency < 0.2 && slide < -0.05)) {
      slide = -slide;
    }

    if(lpFilterCutoff < 0.1 && lpFilterCutoffSweep < -0.05) {
      lpFilterCutoffSweep = -lpFilterCutoffSweep;
    }
  }
}
