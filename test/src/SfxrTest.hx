import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;
import vault.Sfxr;

class SfxrTest {
  static function main() {
    // new SfxrTest();
    var params = new SfxrParams();
    params.waveType = 0;
    params.squareDuty = 0.55555*0.6;
    params.startFrequency = 0.3 + 0.55555*0.3;
    params.slide = 0.1 + 0.55555*0.2;
    params.attackTime = 0.0;
    params.sustainTime = 0.1 + 0.55555*0.3;
    params.decayTime = 0.1 + 0.55555*0.2;
    // if (0.55555 < 0.5) params.hpFilterCutoff = 0.55555*0.3;
    // if (0.55555 < 0.5) params.lpFilterCutoff = 1.0 - 0.55555*0.6;

    params.masterVolume = 0.15;

    params = SfxrParams.fromString("0,,0.2193,,0.4748,0.3482,,0.0691,,,,,,0.3482,,,,,1,,,,,0.5");
    var sfxr = new Sfxr(params);
    sfxr.play();

    trace("hello");

    #if !flash
    Sys.exit(0);
    #end
  }
}

