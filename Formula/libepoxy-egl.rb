# Copyright (c) 2025, Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause

class LibepoxyEgl < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  url "https://github.com/akihikodaki/libepoxy.git", :revision => "ec54e0ff95dd98cd5d5c62b38d9ae427e4e6e747"
  version "20220529"
  license "MIT"

  conflicts_with "libepoxy"
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "quic/quic/angle"

  # Require EGL as a public dependency
  patch :DATA

  def install
    mkdir "build" do
      system "meson", "setup", *std_meson_args, "-Degl=yes", "-Dx11=false", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <epoxy/gl.h>
      #include <OpenGL/CGLContext.h>
      #include <OpenGL/CGLTypes.h>
      #include <OpenGL/OpenGL.h>
      int main()
      {
          CGLPixelFormatAttribute attribs[] = {0};
          CGLPixelFormatObj pix;
          int npix;
          CGLContextObj ctx;
          CGLChoosePixelFormat( attribs, &pix, &npix );
          CGLCreateContext(pix, (void*)0, &ctx);
          glClear(GL_COLOR_BUFFER_BIT);
          CGLReleasePixelFormat(pix);
          CGLReleaseContext(pix);
          return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lepoxy", "-framework", "OpenGL", "-o", "test"
    system "ls", "-lh", "test"
    system "file", "test"
    system "./test"
  end
end

__END__
diff --git a/src/meson.build b/src/meson.build
index 457a811..4380be0 100644
--- a/src/meson.build
+++ b/src/meson.build
@@ -117,5 +117,5 @@ pkg.generate(
     'epoxy_has_wgl=@0@'.format(epoxy_has_wgl),
   ],
   filebase: 'epoxy',
-  requires_private: ' '.join(gl_reqs),
+  requires: ' '.join(gl_reqs),
 )
