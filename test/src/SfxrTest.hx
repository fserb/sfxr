import vault.Sfxr;
import vault.SfxrParams;

class SfxrTest {
  static function main() {
    // new SfxrTest();
    var params = new SfxrParams();

    // params.waveType = 0;
    // params.squareDuty = 0.55555*0.6;
    // params.startFrequency = 0.3 + 0.55555*0.3;
    // params.slide = 0.1 + 0.55555*0.2;
    // params.attackTime = 0.0;
    // params.sustainTime = 0.1 + 0.55555*0.3;
    // params.decayTime = 0.1 + 0.55555*0.2;
    // params.masterVolume = 0.15;

    // taken from as3sfxr:
    params = SfxrParams.fromString("0,,0.2193,,0.4748,0.3482,,0.0691,,,,,,0.3482,,,,,1,,,,,0.5");
    var sfxr = new Sfxr(params);
    sfxr.play();

    haxe.Timer.delay(function() {
      trace(1);
      sfxr.play();
    }, 2000);

    haxe.Timer.delay(function() {
      trace(2);
      sfxr.play();
    }, 4000);
  }
}

