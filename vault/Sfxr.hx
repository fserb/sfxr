// based on:
// sfxr Copyright 2007 Tomas Pettersson
// Haxe sfxr Copyright 2009 Mike Wiering
// as3fxr Copyright 2010 Thomas Vian

package vault;

import flash.utils.ByteArray;

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


class Sfxr {
  var _params: SfxrParams;

  public function new(?params: SfxrParams = null) {
    if (params != null) {
      _params = params;
    } else {
      _params = new SfxrParams();
    }
  }

  public function play() {
    var buffer = new ByteArray();
    reset(true);
    synthWave(buffer);
    #if flash
      playSWF(buffer);
    #else
      playWave(buffer);
    #end
  }

  var _masterVolume:Float;           // masterVolume * masterVolume (for quick calculations)

  var _waveType:UInt;                // The type of wave to generate

  var _envelopeVolume:Float;         // Current volume of the envelope
  var _envelopeStage:Int;            // Current stage of the envelope (attack, sustain, decay, end)
  var _envelopeTime:Float;           // Current time through current enelope stage
  var _envelopeLength:Float;         // Length of the current envelope stage
  var _envelopeLength0:Float;        // Length of the attack stage
  var _envelopeLength1:Float;        // Length of the sustain stage
  var _envelopeLength2:Float;        // Length of the decay stage
  var _envelopeFullLength:Float;     // Full length of the volume envelop (and therefore sound)

  var _sustainPunch:Float;           // The punch factor (louder at begining of sustain)

  var _phase:Int;                    // Phase through the wave
  var _pos:Float;                    // Phase expresed as a Float from 0-1, used for fast sin approx
  var _period:Float;                 // Period of the wave
  var _maxPeriod:Float;              // Maximum period before sound stops (from minFrequency)

  var _slide:Float;                  // Note slide
  var _deltaSlide:Float;             // Change in slide
  var _minFreqency:Float;            // Minimum frequency before stopping

  var _vibratoPhase:Float;           // Phase through the vibrato sine wave
  var _vibratoSpeed:Float;           // Speed at which the vibrato phase moves
  var _vibratoAmplitude:Float;       // Amount to change the period of the wave by at the peak of the vibrato wave

  var _changeAmount:Float;           // Amount to change the note by
  var _changeTime:Int;               // Counter for the note change
  var _changeLimit:Int;              // Once the time reaches this limit, the note changes

  var _squareDuty:Float;             // Offset of center switching point in the square wave
  var _dutySweep:Float;              // Amount to change the duty by

  var _repeatTime:Int;               // Counter for the repeats
  var _repeatLimit:Int;              // Once the time reaches this limit, some of the variables are reset

  var _phaser:Bool;               // If the phaser is active
  var _phaserOffset:Float;           // Phase offset for phaser effect
  var _phaserDeltaOffset:Float;      // Change in phase offset
  var _phaserInt:Int;                // Integer phaser offset, for bit maths
  var _phaserPos:Int;                // Position through the phaser buffer
  var _phaserBuffer:Array<Float>;    // Buffer of wave values used to create the out of phase second wave

  var _filters:Bool;              // If the filters are active
  var _lpFilterPos:Float;            // Adjusted wave position after low-pass filter
  var _lpFilterOldPos:Float;         // Previous low-pass wave position
  var _lpFilterDeltaPos:Float;       // Change in low-pass wave position, as allowed by the cutoff and damping
  var _lpFilterCutoff:Float;         // Cutoff multiplier which adjusts the amount the wave position can move
  var _lpFilterDeltaCutoff:Float;    // Speed of the low-pass cutoff multiplier
  var _lpFilterDamping:Float;        // Damping muliplier which restricts how fast the wave position can move
  var _lpFilterOn:Bool;           // If the low pass filter is active

  var _hpFilterPos:Float;            // Adjusted wave position after high-pass filter
  var _hpFilterCutoff:Float;         // Cutoff multiplier which adjusts the amount the wave position can move
  var _hpFilterDeltaCutoff:Float;    // Speed of the high-pass cutoff multiplier

  var _noiseBuffer:Array<Float>;     // Buffer of random values used to generate noise

  var _superSample:Float;            // Actual sample writen to the wave
  var _sampleCount:UInt;             // Number of samples added to the buffer sample
  var _bufferSample:Float;           // Another supersample used to create a 22050Hz wave

  /**
   * Resets the runing variables from the params
   * Used once at the start (total reset) and for the repeat effect (partial reset)
   * @param totalReset If the reset is total
   */
  function reset(totalReset:Bool) {
    // Shorter reference
    var p:SfxrParams = _params;

    // diff 0.001 -> 0.000001
    _period = 100.0 / (p.startFrequency * p.startFrequency + 0.001);
    _maxPeriod = 100.0 / (p.minFrequency * p.minFrequency + 0.001);

    _slide = 1.0 - p.slide * p.slide * p.slide * 0.01;
    _deltaSlide = -p.deltaSlide * p.deltaSlide * p.deltaSlide * 0.000001;

    if (p.waveType == 0) {
      _squareDuty = 0.5 - p.squareDuty * 0.5;
      _dutySweep = -p.dutySweep * 0.00005;
    }

    if (p.changeAmount > 0.0) {
      _changeAmount = 1.0 - p.changeAmount * p.changeAmount * 0.9;
    } else {
      _changeAmount = 1.0 + p.changeAmount * p.changeAmount * 10.0;
    }

    _changeTime = 0;

    if(p.changeSpeed == 1.0) {
      _changeLimit = 0;
    } else {
      _changeLimit = Std.int((1.0 - p.changeSpeed) * (1.0 - p.changeSpeed) * 20000 + 32);
    }

    if(totalReset) {
      _masterVolume = p.masterVolume * p.masterVolume;

      _waveType = p.waveType;

      if (p.sustainTime < 0.01) {
        p.sustainTime = 0.01;
      }

      var totalTime = p.attackTime + p.sustainTime + p.decayTime;
      if (totalTime < 0.18) {
        var multiplier = 0.18 / totalTime;
        p.attackTime *= multiplier;
        p.sustainTime *= multiplier;
        p.decayTime *= multiplier;
      }

      _sustainPunch = p.sustainPunch;

      _phase = 0;

      _minFreqency = p.minFrequency;

      _filters = p.lpFilterCutoff != 1.0 || p.hpFilterCutoff != 0.0;

      _lpFilterPos = 0.0;
      _lpFilterDeltaPos = 0.0;
      _lpFilterCutoff = p.lpFilterCutoff * p.lpFilterCutoff * p.lpFilterCutoff * 0.1;
      _lpFilterDeltaCutoff = 1.0 + p.lpFilterCutoffSweep * 0.0001;
      _lpFilterDamping = 5.0 / (1.0 + p.lpFilterResonance * p.lpFilterResonance * 20.0) * (0.01 + _lpFilterCutoff);
      if (_lpFilterDamping > 0.8) _lpFilterDamping = 0.8;
      _lpFilterDamping = 1.0 - _lpFilterDamping;
      _lpFilterOn = p.lpFilterCutoff != 1.0;

      _hpFilterPos = 0.0;
      _hpFilterCutoff = p.hpFilterCutoff * p.hpFilterCutoff * 0.1;
      _hpFilterDeltaCutoff = 1.0 + p.hpFilterCutoffSweep * 0.0003;

      _vibratoPhase = 0.0;
      _vibratoSpeed = p.vibratoSpeed * p.vibratoSpeed * 0.01;
      _vibratoAmplitude = p.vibratoDepth * 0.5;

      _envelopeVolume = 0.0;
      _envelopeStage = 0;
      _envelopeTime = 0;
      _envelopeLength0 = p.attackTime * p.attackTime * 100000.0;
      _envelopeLength1 = p.sustainTime * p.sustainTime * 100000.0;
      _envelopeLength2 = p.decayTime * p.decayTime * 100000.0 + 10;
      _envelopeLength = _envelopeLength0;
      _envelopeFullLength = _envelopeLength0 + _envelopeLength1 + _envelopeLength2;

      _phaser = p.phaserOffset != 0.0 || p.phaserSweep != 0.0;

      _phaserOffset = p.phaserOffset * p.phaserOffset * 1020.0;
      if (p.phaserOffset < 0.0) {
        _phaserOffset = -_phaserOffset;
      }
      _phaserDeltaOffset = p.phaserSweep * p.phaserSweep * p.phaserSweep * 0.2;
      _phaserPos = 0;

      _phaserBuffer = new Array<Float>();
      for (i in 0...1024) _phaserBuffer.push(0.0);
      _noiseBuffer = new Array<Float>();
      for (i in 0...32) _noiseBuffer.push(Math.random() * 2.0 - 1.0);

      _repeatTime = 0;

      if (p.repeatSpeed == 0.0) {
        _repeatLimit = 0;
      } else {
        _repeatLimit = Std.int((1.0-p.repeatSpeed) * (1.0-p.repeatSpeed) * 20000) + 32;
      }
    }
  }

  /**
   * Writes the wave to the supplied buffer ByteArray
   * @param buffer    A ByteArray to write the wave to
   * @param waveData  If the wave should be written for the waveData
   */
  function synthWave(buffer:ByteArray) {
    var sampleRate = 44100;
    var bitDepth = 16;
    var finished = false;

    _sampleCount = 0;
    _bufferSample = 0.0;

    while (!finished) {
      // Repeats every _repeatLimit times, partially resetting the sound parameters
      if(_repeatLimit != 0) {
        if(++_repeatTime >= _repeatLimit) {
          _repeatTime = 0;
          reset(false);
        }
      }

      // If _changeLimit is reached, shifts the pitch
      if(_changeLimit != 0) {
        if(++_changeTime >= _changeLimit) {
          _changeLimit = 0;
          _period *= _changeAmount;
        }
      }

      // Acccelerate and apply slide
      _slide += _deltaSlide;
      _period *= _slide;

      // Checks for frequency getting too low, and stops the sound if a minFrequency was set
      if(_period > _maxPeriod) {
        _period = _maxPeriod;
        if(_minFreqency > 0.0) {
          finished = true;
        }
      }

      var periodTemp:Float = _period;

      // Applies the vibrato effect
      if(_vibratoAmplitude > 0.0) {
        _vibratoPhase += _vibratoSpeed;
        periodTemp = _period * (1.0 + Math.sin(_vibratoPhase) * _vibratoAmplitude);
      }

      periodTemp = Std.int(periodTemp);
      if(periodTemp < 8) periodTemp = 8;

      // Sweeps the square duty
      if (_waveType == 0) {
        _squareDuty += _dutySweep;
        if(_squareDuty < 0.0) _squareDuty = 0.0;
        else if (_squareDuty > 0.5) _squareDuty = 0.5;
      }

      // Moves through the different stages of the volume envelope
      if(++_envelopeTime > _envelopeLength) {
        _envelopeTime = 0;
        switch(++_envelopeStage) {
          case 1: _envelopeLength = _envelopeLength1;
          case 2: _envelopeLength = _envelopeLength2;
        }
      }

      // Sets the volume based on the position in the envelope
      switch(_envelopeStage) {
        case 0: _envelopeVolume = _envelopeTime / _envelopeLength0;
        case 1: _envelopeVolume = 1.0 + (1.0 - _envelopeTime / _envelopeLength1) * 2.0 * _sustainPunch;
        case 2: _envelopeVolume = 1.0 - _envelopeTime / _envelopeLength2;
        case 3: _envelopeVolume = 0.0; finished = true;
      }

      // Moves the phaser offset
      if (_phaser) {
        _phaserOffset += _phaserDeltaOffset;
        _phaserInt = Std.int(_phaserOffset);
        if (_phaserInt < 0)  _phaserInt = -_phaserInt;
        else if (_phaserInt > 1023) _phaserInt = 1023;
      }

      // Moves the high-pass filter cutoff
      if(_filters && _hpFilterDeltaCutoff != 0.0) {
        _hpFilterCutoff *= _hpFilterDeltaCutoff;
        if(_hpFilterCutoff < 0.00001) _hpFilterCutoff = 0.00001;
        else if(_hpFilterCutoff > 0.1) _hpFilterCutoff = 0.1;
      }

      _superSample = 0.0;
      for (j in 0...8) {
        var sample: Float = 0.0;
        // Cycles through the period
        _phase++;
        if(_phase >= periodTemp) {
          _phase = _phase - Std.int(periodTemp);
          // Generates new random noise for this period
          if(_waveType == 3) {
            for (n in 0...32) _noiseBuffer[n] = Math.random() * 2.0 - 1.0;
          }
        }
        // Gets the sample from the oscillator
        switch(_waveType) {
          case 0: // Square wave
            sample = ((_phase / periodTemp) < _squareDuty) ? 0.5 : -0.5;
          case 1: // Saw wave
            sample = 1.0 - (_phase / periodTemp) * 2.0;
          case 2: // Sine wave (fast and accurate approx)
            _pos = _phase / periodTemp;
            _pos = _pos > 0.5 ? (_pos - 1.0) * 6.28318531 : _pos * 6.28318531;
            sample = _pos < 0 ? 1.27323954 * _pos + .405284735 * _pos * _pos : 1.27323954 * _pos - 0.405284735 * _pos * _pos;
            sample = sample < 0 ? .225 * (sample *-sample - sample) + sample : .225 * (sample * sample - sample) + sample;
          case 3: // Noise
            sample = _noiseBuffer[Std.int(_phase * 32 / Std.int(periodTemp))];
        }

        // Applies the low and high pass filters
        if (_filters) {
          _lpFilterOldPos = _lpFilterPos;
          _lpFilterCutoff *= _lpFilterDeltaCutoff;
          if(_lpFilterCutoff < 0.0) _lpFilterCutoff = 0.0;
          else if(_lpFilterCutoff > 0.1) _lpFilterCutoff = 0.1;

          if(_lpFilterOn) {
            _lpFilterDeltaPos += (sample - _lpFilterPos) * _lpFilterCutoff;
            _lpFilterDeltaPos *= _lpFilterDamping;
          } else {
            _lpFilterPos = sample;
            _lpFilterDeltaPos = 0.0;
          }

          _lpFilterPos += _lpFilterDeltaPos;

          _hpFilterPos += _lpFilterPos - _lpFilterOldPos;
          _hpFilterPos *= 1.0 - _hpFilterCutoff;

          sample = _hpFilterPos;
        }

        // Applies the phaser effect
        if (_phaser) {
          _phaserBuffer[_phaserPos&1023] = sample;
          sample += _phaserBuffer[(_phaserPos - _phaserInt + 1024) & 1023];
          _phaserPos = (_phaserPos + 1) & 1023;
        }

        _superSample += sample;
      }
      // Averages out the super samples and applies volumes
      _superSample = _masterVolume * _envelopeVolume * _superSample / 8.0;

      // for some reason, our samples are way louder than as3sfxr.
      // and I can't find the problem. :(
      _superSample /= 256.0;

      if (buffer.length % 1000 == 0) trace(_superSample);

      // Clipping if too loud
      if(_superSample > 1.0) _superSample = 1.0;
      else if(_superSample < -1.0)  _superSample = -1.0;
      buffer.writeShort(Std.int(32767.0 * _superSample));
    }
  }

  // tested with native Mac
  function playWave(wave: ByteArray) {
    var wav_freq = 44100;
    var wav_bits = 16;
    var stereo = false;
    var file = new ByteArray();
    file.endian = flash.utils.Endian.LITTLE_ENDIAN;
    file.writeUTFBytes("RIFF");
    file.writeInt(0);
    file.writeUTFBytes("WAVE");

    file.writeUTFBytes("fmt ");
    file.writeInt(16); // chunk size
    file.writeShort(1); // compression code = PCM
    var channels = stereo ? 2 : 1;
    file.writeShort(channels); // channels (mono/stereo)
    file.writeInt(wav_freq); // sample rate
    var bps  = wav_freq * channels * Std.int(wav_bits/8);
    file.writeInt(bps); // bytes/sec
    var align = channels * Std.int(wav_bits/8);
    file.writeShort(align); // block align
    file.writeShort(wav_bits); // bits per sample

    file.writeUTFBytes("data");
    var size = 0;
    file.writeInt(wave.length); // chunk size
    file.writeBytes(wave, 0, wave.length);

    file.position = 0;

    var s = new flash.media.Sound();
    s.loadCompressedDataFromByteArray(file, file.length);
    s.play();

    // write data
    #if !flash
    var f = sys.io.File.write("test.wav", true);
    f.writeBytes(file, 0, file.length);
    f.close();
    trace("saved... " + file.length);
    #end
  }

  // based on BadSector's DynSound.hx
  function playSWF(wave: ByteArray) {
    var rate = 3;
    var is16bits = 1;
    var stereo = 0;

    var swf: ByteArray = new ByteArray();
    swf.endian = flash.utils.Endian.LITTLE_ENDIAN;

    var writeTagInfo = function(code: Int, len: Int) {
      if (len >= 63) {
        swf.writeShort ((code << 6) | 0x3F);
        swf.writeInt (len);
      } else {
        swf.writeShort ((code << 6) | len);
      }
    };

    swf.writeByte(0x46);  // 'SWF' signature
    swf.writeByte(0x57);
    swf.writeByte(0x53);
    swf.writeByte(0x07);  // version
    swf.writeUnsignedInt(0);  // filesize (will be set later)
    swf.writeByte(0x78);  // area size
    swf.writeByte(0x00);
    swf.writeByte(0x05);
    swf.writeByte(0x5F);
    swf.writeByte(0x00);
    swf.writeByte(0x00);
    swf.writeByte(0x0F);
    swf.writeByte(0xA0);
    swf.writeByte(0x00);
    swf.writeByte(0x00);  // framerate (12fps)
    swf.writeByte(0x0C);

    swf.writeShort(1);  // one frame
    // DefineSound tag
    writeTagInfo(14, 2 + 1 + 4 + wave.length);
    swf.writeShort(1);  // sound (character) ID

    swf.writeByte((3 << 4) + (rate << 2) + (is16bits << 1) + stereo);
    // sound format bits:
    //  7654   32    1      0
    // format rate 16bit stereo
    swf.writeUnsignedInt(wave.length >> (is16bits + stereo)); // sample count
    swf.writeBytes(wave);  // data

    // StartSound tag
    writeTagInfo(15, 2 + 1);
    swf.writeShort(1);  // character id of the sound
    swf.writeByte(0);  // SOUNDINFO flags (all 0)

    // End tag
    writeTagInfo(0, 0);

    // Set size
    swf.position = 4;
    swf.writeUnsignedInt(swf.length);
    swf.position = 0;

    // load it
    var ldr = new flash.display.Loader();
    ldr.loadBytes (swf);
  }
}
