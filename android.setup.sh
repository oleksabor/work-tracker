# working with sdkmanager
# https://gist.github.com/mrk-han/66ac1a724456cadf1c93f4218c6060ae

sudo $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "system-images;android-31;google_apis;x86_64"

sudo $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "build-tools;31.0.0"
sudo $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "build-tools;30.0.3"

# in case if SDK was installed to /usr/lib and ordinary user have no permission
sudo sudo chmod a+rwx $ANDROID_SDK_ROOT

sudo /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --install "system-images;android-29;default;x86"




$ sudo /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-31"
sudo /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-29"

sudo /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --update

# licenses should be accepted with the current user privileges
flutter doctor --android-licenses

avdmanager create avd -n emu31 --package "system-images;android-31;google_apis;x86_64"
avdmanager create avd -n emu29 --package "system-images;android-29;default;x86"
avdmanager create avd -n emu29_7in --tag 48 --package "system-images;android-29;default;x86"
# to make 7" and 10" GooglePlay screenshots
avdmanager create avd -n emu29_10in --package "system-images;android-29;default;x86" --device "10.1in WXGA (Tablet)"
avdmanager create avd -n emu29_7in --package "system-images;android-29;default;x86" --device "7in WSVGA (Tablet)"

#new flutter sdk requires new Java to be installed
sudo apt-get install openjdk-11-jdk

#reset network if fails
sudo nmcli networking on

git branch -D $(git branch | grep 3.2*)

