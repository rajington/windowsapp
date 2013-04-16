require 'formula'

class WindowsApp < Formula
  homepage 'https://github.com/sdegutis/windows.app'
  url 'https://github.com/sdegutis/windows.app/archive/2.0.2.zip'
  version '2.0.2'
  sha1 'a8e94d67ce24b7926652a5fbd7180ba3b444958b'
  head 'https://github.com/sdegutis/Windows.git'

  depends_on :xcode

  def install
    system 'xcodebuild'
    prefix.install 'build/Release/Windows.app'
  end

  def caveats; <<-EOS

    Windows.app was installed in:
      #{prefix}

    To symlink into ~/Applications, you can do:
      brew linkapps

    However, Spotlight won't see it. But `open -a windows` will.

    EOS
  end
end
