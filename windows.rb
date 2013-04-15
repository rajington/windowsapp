require 'formula'

class Windows < Formula
  homepage 'https://github.com/sdegutis/windows'
  url 'https://github.com/sdegutis/Windows/archive/1.2.3.zip'
  sha1 '9bfacf3d39d6d30d276dca4abc2be51245410c1e'

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

    EOS
  end
end
