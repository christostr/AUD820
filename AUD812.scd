(
s.waitForBoot {
    var duration = 60;
    var numSynths = 5;

    SynthDef(\ambientSynth, {
        |out = 0, freqs = #[220, 275, 330], amp = 0.1, pan = 0, dur = 10|
        var env, osc, sig;
        env = EnvGen.kr(Env.perc(0.01, dur, amp, -4), doneAction: 2);
        osc = Mix(freqs.collect { |f| SinOsc.ar(f, 0, env) });
        sig = Pan2.ar(osc, pan);
        Out.ar(out, sig);
    }).add;

    SynthDef(\droneSynth, {
        |out = 0, freq = 110, amp = 0.4|
        var osc, sig;
        osc = Mix([SinOsc.ar(freq), SinOsc.ar(freq * 0.5)]);
        sig = Pan2.ar(osc, 0, amp);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~generateSynth = {
        var root, chordType, freqs, amp, pan, dur, delayTime, synth;
        root = [110, 165, 220, 275, 330, 440].choose;
        chordType = ["major", "minor", "diminished", "major7", "minor7"].choose;

        switch (chordType,
            "major", { freqs = [root, root * 1.25, root * 1.5] },
            "minor", { freqs = [root, root * 1.2, root * 1.5] },
            "diminished", { freqs = [root, root * 1.5, root * 1.75] },
            "major7", { freqs = [root, root * 1.25, root * 1.5, root * 1.75] },
            "minor7", { freqs = [root, root * 1.2, root * 1.5, root * 1.66] }
        );

        amp = [0.05, 0.1, 0.15, 0.2].choose;
        pan = [-1.0, -0.5, 0.0, 0.5, 1.0].choose;
        dur = [2, 4, 5, 7].choose;

        synth = Synth(\ambientSynth, [\freqs, freqs, \amp, amp, \pan, pan, \dur, dur]);

        delayTime = dur + rrand(0.5, 2);
        SystemClock.sched(delayTime, { ~generateSynth.value });
    };

    Synth(\droneSynth, [\freq, 220, \amp, 0.2]);

    numSynths.do { ~generateSynth.value };

    SystemClock.sched(duration, { s.quit; });
};
)