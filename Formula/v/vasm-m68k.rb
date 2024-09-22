class VasmM68k < Formula
  desc "Portable and retargetable assembler"
  homepage "http://sun.hasenbraten.de/vasm/"
  url "http://sun.hasenbraten.de/vasm/release/vasm.tar.gz"
  version "1.9f"
  sha256 "a09d4ff3b5ec50bb7538fb97b9539141376580b590586463569783c36438ebe8"
  license "MIT"

  depends_on "gcc@13" => :build
  depends_on "make" => :build

  def install
    cpu = "m68k"
    syntax = "mot"
    makefile = OS.windows? ? "Makefile.Win32" : "Makefile"

    if OS.mac?
      if MacOS::Xcode.version >= "4.3"
        ENV["CC"] = ENV.cc
        ENV["CXX"] = ENV.cxx
      else
        opoo "System Clang not available. Using GCC."
        ENV["CC"] = Formula["gcc@13"].opt_bin/"gcc-13"
        ENV["CXX"] = Formula["gcc@13"].opt_bin/"g++-13"
      end
    elsif OS.linux?
      ENV["CC"] = Formula["gcc@13"].opt_bin/"gcc-13"
      ENV["CXX"] = Formula["gcc@13"].opt_bin/"g++-13"
    end
    # Windows will use the default compiler specified in Makefile.Win32

    make_args = ["CPU=#{cpu}", "SYNTAX=#{syntax}"]
    make_args << "CC=#{ENV['CC']}" << "CXX=#{ENV['CXX']}" unless OS.windows?

    system "make", "-f", makefile, *make_args
    bin.install "vasm#{cpu}_#{syntax}"
  end

  test do
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