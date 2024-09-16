class Vasm < Formula
  desc "A portable and retargetable assembler"
  homepage "http://sun.hasenbraten.de/vasm/"
  url "http://sun.hasenbraten.de/vasm/release/vasm.tar.gz"
  version "1.9f"
  sha256 "a09d4ff3b5ec50bb7538fb97b9539141376580b590586463569783c36438ebe8"
  license "Non-Commercial License (NC)"

  depends_on "make" => :build
  depends_on "llvm" => :optional

  option "with-makefile", "Specify Makefile type (default: Makefile). Available options:\n
    Makefile - standard Unix/Clang Makefile\n
    Makefile.68k - makes AmigaOS 68020 executable with vbcc\n
    Makefile.Cygwin - makes Windows executable with Cygwin/MinGW-clang\n
    Makefile.Haiku - Clang Makefile which doesn't link libm\n
    Makefile.MiNT - makes Atari MiNT 68020 executable with vbcc\n
    Makefile.MOS - makes MorphOS executable with vbcc\n
    Makefile.OS4 - makes AmigaOS4 executable with vbcc\n
    Makefile.PUp - makes PowerUp executable with vbcc\n
    Makefile.TOS - makes Atari TOS 68000 executable with vbcc\n
    Makefile.Win32 - makes Windows executable with MS-VSC++\n
    Makefile.Win32FromLinux - makes Windows executable on Linux\n
    Makefile.WOS - makes WarpOS executable with vbcc"
  option "with-cpu", "Specify CPU type (default: m68k). Available options:\n
    6502\n
    6800\n
    6809\n
    arm\n
    c16x\n
    jagrisc\n
    m68k\n
    pdp11\n
    ppc\n
    qnice\n
    test\n
    tr3200\n
    vidcore\n
    x86\n
    z80"
  option "with-syntax", "Specify syntax type (default: mot). Available options:\n
    std\n
    madmac\n
    mot\n
    oldstyle\n
    test"

  def install
    cpu = build.with?("cpu") ? build.options["cpu"] : "m68k"
    syntax = build.with?("syntax") ? build.options["syntax"] : "mot"
    makefile = build.with?("makefile") ? build.options["makefile"] : "Makefile"

    if MacOS::Xcode.version >= "4.3"
      ENV["CC"] = "/usr/bin/clang"
      ENV["CXX"] = "/usr/bin/clang++"
    else
      opoo "System Clang not available. Using LLVM Clang."
      depends_on "llvm" => :build
      ENV["CC"] = Formula["llvm"].opt_bin/"clang"
      ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"
    end

    # Pass CC and CXX variables directly to make
    system "make", "-f", makefile, "CPU=#{cpu}", "SYNTAX=#{syntax}", "CC=#{ENV['CC']}", "CXX=#{ENV['CXX']}"
    bin.install "vasm#{cpu}_#{syntax}"
  end

  test do
    # Create a test assembly file
    (testpath/"hello.asm").write <<~EOS
      ; Simple Motorola 68000 assembly program
      ; Assembled with vasm for Amiga-style systems
  
              section text
  
      start:  move.l  #4,d0           ; Write() function
              lea     message,a1      ; address of message
              move.l  #13,d1          ; length of message
              jsr     -552(a6)        ; Call Write()
              
              moveq   #0,d0           ; No error
              rts                     ; Return
  
              section data
      message:
              dc.b    'Hello, World!',0
    EOS
  
    system "#{bin}/vasmm68k_mot", "-Fhunk", "-o", "hello", "hello.asm"
    assert_predicate testpath/"hello", :exist?, "Failed to create output file"
  end
end