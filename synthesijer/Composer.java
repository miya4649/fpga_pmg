/*
  Copyright (c) 2018, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import synthesijer.rt.*;

public class Composer
{
  public boolean led;
  private static final int CH_IN_BITS = 2;
  private static final int CH = (1 << CH_IN_BITS);
  private static final int VOLUME = 8000;
  private static final int TEMPO = 1536000;
  private static final int FIXED = 256;
  private static final int SEQ_LENGTH = 16;
  private static final int SEQ_DATA_SIZE = (SEQ_LENGTH * CH);
  private static final int CHORD_LENGTH_IN_BITS = 2;
  private static final int CHORD_SR = (32 - CHORD_LENGTH_IN_BITS);
  private static final int CHORD_LENGTH = (1 << CHORD_LENGTH_IN_BITS);
  private static final int CHORD_TYPES = 8;
  private static final int CHORD_DATA_SIZE = (CHORD_LENGTH * CHORD_TYPES);
  private static final int CHORD_CHANGE = 4;
  private int random;
  private int[] note_adder = new int[CH];
  private int[] note_next = new int[CH];
  private boolean[] sign = new boolean[CH];
  private boolean[] note_on = new boolean[CH];
  private byte[] seq = new byte[SEQ_DATA_SIZE];
  private final MiniAudioIface audio = new MiniAudioIface();
  private final ROMscaledata scale = new ROMscaledata();
  private final ROMchorddata chorddata = new ROMchorddata();

  private int rand()
  {
    int r = random;
    r = r ^ (r << 13);
    r = r ^ (r >>> 17);
    r = r ^ (r << 5);
    random = r;
    return r;
  }

  @auto
  public void main()
  {
    int addrate = 4;
    int bar = 0;
    int seq_pointer = 0;
    int tick = 0;
    int beat_next = TEMPO;
    int beat = 0;
    int chord = 0;
    random = -59634649;
    for (int i = 0; i < CH; i++)
    {
      note_adder[i] = 0;
      note_next[i] = 0;
      sign[i] = false;
      note_on[i] = false;
    }
    for (int i = 0; i < SEQ_DATA_SIZE; i++)
    {
      seq[i] = 0;
    }

    while (true)
    {
      // play
      int sample = 0;
      for (int i = 0; i < CH; i++)
      {
        if ((note_next[i] - tick) < 0)
        {
          sign[i] = !sign[i];
          note_next[i] += note_adder[i];
        }
        if (note_on[i] == true)
        {
          if (sign[i] == true)
          {
            sample += VOLUME;
          }
          else
          {
            sample -= VOLUME;
          }
        }
      }
      audio.writeData(sample, sample);

      // led
      if (sample > 7000)
      {
        led = true;
      }
      else
      {
        led = false;
      }

      // sequencer
      if (beat_next - tick < 0)
      {
        beat_next += TEMPO;
        beat++;
        if (beat == SEQ_LENGTH)
        {
          beat = 0;
          bar++;
          if (bar == CHORD_CHANGE)
          {
            bar = 0;
            chord = rand() >>> 29; // 32-CHORD_TYPES_IN_BITS
            addrate = rand() >>> 30; // 0-3
          }
        }
        seq_pointer = beat << 2; // CH_IN_BITS
        for (int i = 0; i < CH; i++)
        {
          int seq1 = seq[seq_pointer];
          if (seq1 == 0)
          {
            note_on[i] = false;
          }
          else
          {
            note_on[i] = true;
            note_adder[i] = scale.data[chorddata.data[(chord << 2) + (seq1 & 15)]] >>> (seq1 >>> 4);
            note_next[i] = tick + note_adder[i];
          }
          if ((rand() >>> 29) < 1)
          {
            seq[seq_pointer] = 0;
          }
          if ((rand() >>> 28) < addrate)
          {
            // (octave << 4) + chord_note
            seq[seq_pointer] = (byte)(((rand() >>> 30) << 4) + (rand() >>> 30)); // 30:CHORD_SR
          }
          seq_pointer++;
        }
      }
      tick += FIXED;
    }
  }
}
