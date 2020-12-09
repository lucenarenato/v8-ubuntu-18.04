#!/bin/bash -eux

apt-get install chrpath
apt install libgtk-3-dev libxml++2.6-dev

cd /tmp

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=`pwd`/depot_tools:"$PATH"

fetch v8
cd v8

make native library=shared -j8

chrpath -r '$ORIGIN' out/native/lib.target/libv8.so

sudo mkdir -p /tmp/v8-install/lib /tmp/v8-install/include
sudo cp out/native/lib.target/lib*.so /tmp/v8-install/lib/
sudo cp -R include/* /tmp/v8-install/include
echo -e "create /tmp/v8-install/lib/libv8_libplatform.a\naddlib out/native/obj.target/tools/gyp/libv8_libplatform.a\nsave\nend" | sudo ar -M

cd /tmp
git clone https://github.com/preillyme/v8js.git
cd v8js
phpize
./configure --with-v8js=/tmp/v8-install
make
make test
sudo make install

echo "extension=v8js.so" > /etc/php5/mods-available/v8js.ini
ln -s /etc/php5/mods-available/v8js.ini /etc/php5/cli/conf.d/20-v8js.ini

service php5-fpm restart
