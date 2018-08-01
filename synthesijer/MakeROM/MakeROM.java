/*
  Copyright (c) 2016, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import java.io.*;

public class MakeROM
{
  private int getArraySize(int size)
  {
    int array_size = 0;
    int num = 0;
    for (int i = 0; i < 32; i++)
    {
      int bit = size & 1;
      size >>= 1;
      if (bit == 1)
      {
        array_size = i;
        num++;
      }
    }
    if (num > 1)
    {
      array_size++;
    }
    return array_size;
  }

  public void writeVerilog(String name, int[] data, int data_bits)
  {
    int array_size = getArraySize(data.length);
    try
    {
      String hdlName = "rom_" + name;
      File file = new File("../" + hdlName + ".v");
      file.createNewFile();
      PrintWriter writer = new PrintWriter(file);
      writer.printf(
        "module %s\n" +
        "  (\n" +
        "    input clk,\n" +
        "    input reset,\n" +
        "    input [31:0] data_address,\n", hdlName);
      writer.printf(
        "    input [%d:0] data_din,\n" +
        "    output reg [%d:0] data_dout,\n", data_bits-1, data_bits-1);
      writer.printf(
        "    input data_oe,\n" +
        "    input data_we,\n" +
        "    output [31:0] data_length\n" +
        "  );\n" +
        "\n" +
        "  assign data_length = 32'h%08x;\n" +
        "\n" +
        "  always @(posedge clk)\n" +
        "    begin\n" +
        "      case (data_address[%d:0])\n",
        data.length, (array_size - 1));
      for (int i = 0; i < (1 << array_size); i++)
      {
        int d;
        if (i < data.length)
        {
          d = data[i];
        }
        else
        {
          d = 0;
        }
        writer.printf("        32'h%08x: data_dout <= 32'h%08x;\n", i, d);
      }
      writer.printf(
        "      endcase\n" +
        "    end\n" +
        "endmodule\n");
      writer.close();
    }
    catch (Exception e)
    {
    }
  }

  public void writeJava(String name, String type, int[] data, int data_bits)
  {
    int array_size = getArraySize(data.length);
    try
    {
      String hdlName = "rom_" + name;
      String javaName = "ROM" + name;
      File file = new File("../" + javaName + ".java");
      file.createNewFile();
      PrintWriter writer = new PrintWriter(file);
      writer.printf(
        "import synthesijer.hdl.HDLModule;\n" +
        "import synthesijer.hdl.HDLPort;\n" +
        "import synthesijer.hdl.HDLPort.DIR;\n" +
        "import synthesijer.hdl.HDLPrimitiveType;\n" +
        "\n" +
        "public class %s extends HDLModule\n", javaName);
      writer.printf(
        "{\n" +
        "  public %s[] data;\n", type);
      writer.printf(
        "\n" +
        "  public %s(String... args)\n", javaName);
      writer.printf(
        "  {\n" +
        "    super(\"%s\", \"clk\", \"reset\");\n", hdlName);
      writer.printf(
        "\n" +
        "    newPort(\"data_address\", DIR.IN, HDLPrimitiveType.genSignedType(32));\n");
      writer.printf(
        "    newPort(\"data_din\", DIR.IN, HDLPrimitiveType.genSignedType(%d));\n",
        data_bits);
      writer.printf(
        "    newPort(\"data_dout\", DIR.OUT, HDLPrimitiveType.genSignedType(%d));\n",
        data_bits);
      writer.printf(
        "    newPort(\"data_length\", DIR.OUT, HDLPrimitiveType.genSignedType(32));\n" +
        "    newPort(\"data_we\", DIR.IN, HDLPrimitiveType.genBitType());\n" +
        "    newPort(\"data_oe\", DIR.IN, HDLPrimitiveType.genBitType());\n" +
        "  }\n" +
        "}\n");
      writer.close();
    }
    catch (Exception e)
    {
    }
  }
}

