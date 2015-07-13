// based on:
// sfxr Copyright 2007 Tomas Pettersson
// Haxe sfxr Copyright 2009 Mike Wiering
// as3fxr Copyright 2010 Thomas Vian

package vault;

#if flash
typedef ByteArray = haxe.io.BytesData
#end

#if cpp
import flash.utils.ByteArray;
#end

#if (html || html5)
import js.html.ArrayBuffer;
import js.html.Uint8Array;
typedef ByteArray = haxe.io.BytesData;
#end

class Sfxr {
  var _params: SfxrParams;
  var buffer: ByteArray;
  var player: Array<Void -> Void>;

  public function new(?params: SfxrParams = null, ?numMutations:Int = 1, ?mutationAmount:Float = 0.05) {
    if (params != null) {
      _params = params;
    } else {
      _params = new SfxrParams();
    }
	
	var originalParams:SfxrParams = _params.duplicate();
	
	if (numMutations == 1)
		mutationAmount = 0;
	
	player = new Array<Void -> Void>();
	
	for (i in 0...numMutations)
	{
		buffer = new ByteArray();
		#if !(html || html5)
		buffer.endian = flash.utils.Endian.LITTLE_ENDIAN;
		#end
		
		_params = originalParams.duplicate();
		
		if (mutationAmount > 0)
			_params.mutate(mutationAmount);

		reset(true);
		synthWave(buffer);
		player.push(makePlayer(buffer));
	}
  }

  inline public function play() {
	if (player.length > 1)
		player[_params.randint() % player.length]();
	else
		player[0]();
  }

  var _masterVolume:Float;           // masterVolume * masterVolume (for quick calculations)

  var _waveType:Int;                // The type of wave to generate

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
  var _sampleCount:Int;             // Number of samples added to the buffer sample
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

      // Clipping if too loud
      if(_superSample > 1.0) _superSample = 1.0;
      else if(_superSample < -1.0)  _superSample = -1.0;

      var val: Int = Std.int(32767.0 * _superSample);

      #if (html || html5)
        buffer.push(val & 0xFF);
        buffer.push((val >> 8) & 0xFF);
      #else
        buffer.writeShort(val);
      #end
    }
  }

#if cpp
  function makePlayer(wave: ByteArray): Void -> Void {
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
    return function() {
      s.play();
    };

    // write data
    // var f = sys.io.File.write("test.wav", true);
    // f.writeBytes(file, 0, file.length);
    // f.close();
  }
#end

#if (html || html5)
  static var html5AudioContext = null;
  function makePlayer(wave: ByteArray): Void -> Void {
    var wav_freq = 44100;
    var wav_bits = 16;
    var stereo = false;

    // All WAVE headers have 44 bytes up to the data.
    var buffer = new ArrayBuffer(44 + wave.length);
    var bv = new Uint8Array(buffer);
    var p = 0;

    var writeString = function(s: String) {
      for (i in 0...s.length) {
        bv[p++] = StringTools.fastCodeAt(s, i);
      }
    };

    var writeShort = function(s: Int) {
      bv[p++] = s & 0xFF;
      bv[p++] = (s >> 8) & 0xFF;
    }

    var writeLong = function(s: Int) {
      bv[p++] = s & 0xFF;
      bv[p++] = (s >> 8) & 0xFF;
      bv[p++] = (s >> 16) & 0xFF;
      bv[p++] = (s >> 24) & 0xFF;
    }

    writeString("RIFF");
    writeLong(0);
    writeString("WAVE");
    writeString("fmt ");
    writeLong(16);
    writeShort(1); // compression code = PCM

    var channels = stereo ? 2 : 1;
    writeShort(channels); // channels (mono/stereo)
    writeLong(wav_freq); // sample rate
    var bps  = wav_freq * channels * Std.int(wav_bits/8);
    writeLong(bps); // bytes/sec
    var align = channels * Std.int(wav_bits/8);
    writeShort(align); // block align
    writeShort(wav_bits); // bits per sample

    writeString("data");
    writeLong(wave.length); // chunk size
    bv.set(wave, p);

    // Data is all set. Time to call AudioContext.

    var audioBuffer = null;
    var wantsToPlay = false;
    if (html5AudioContext == null) {
      var creator = untyped __js__("window.webkitAudioContext || window.AudioContext || null");
      if (creator == null) return function() {};
      html5AudioContext = untyped __js__("new creator();");
    }
    var play = function() {
      if (audioBuffer == null) {
        wantsToPlay = true;
        return;
      }
      var srcAudio = html5AudioContext.createBufferSource();
      srcAudio.buffer = audioBuffer;
      srcAudio.connect(html5AudioContext.destination);
      srcAudio.loop = false;
      srcAudio.start(0);
    };
    untyped html5AudioContext.decodeAudioData(buffer, function(b) {
      audioBuffer = b;
      if (wantsToPlay) {
        play();
      }
    });
    return play;
  }
#end


#if flash
  // based on BadSector's DynSound.hx
  function makePlayer(wave: ByteArray): Void -> Void {
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
    return function() {
      var ldr = new flash.display.Loader();
      ldr.loadBytes (swf);
    };
  }
#end
}
