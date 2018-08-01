/*
  Copyright (c) 2017-2018, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import java.lang.Math;

public class MakeScaleDataROM extends MakeROM
{
  private static final int SCALE_DATA_SIZE = 16;
  private static final double SAMPLING_RATE = 48000.0;
  private static final double FIXED = 256.0;
  private static final double TUNE = 523.2511306011972;

  private final int[] scaleData = new int[SCALE_DATA_SIZE];
  private final int[] chordData = {
    0,2,4,7,
    0,2,4,7,
    0,2,5,9,
    2,4,7,11,
    0,5,7,9,
    2,7,9,11,
    0,4,7,9,
    2,5,7,11
  };

  public void make()
  {
    for (int i = 0; i < SCALE_DATA_SIZE; i++)
    {
      scaleData[i] = (int)((FIXED * SAMPLING_RATE) / (Math.pow(2.0, (double)i / 12.0) * TUNE * 0.25));
    }

    writeVerilog("scaledata", scaleData, 32);
    writeJava("scaledata", "int", scaleData, 32);
    writeVerilog("chorddata", chordData, 8);
    writeJava("chorddata", "byte", chordData, 8);
  }
}
