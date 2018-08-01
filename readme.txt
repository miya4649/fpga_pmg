* About

FPGA Portable Music Generator


* Demo

https://youtu.be/vDZ33SuhlP0


* Prerequisites


** TinyFPGA BX
https://tinyfpga.com/


** Synthesijer (HLS Compiler)
http://synthesijer.github.io/web/


** JDK 8 (Java Development Kit Version 8)


** IceStorm (FPGA Toolchain)
http://www.clifford.at/icestorm/


* Installation


** Ubuntu


*** JDK 8

sudo apt-get install openjdk-8-jdk ant curl unzip git build-essential manpages-dev

sudo update-alternatives --config java
(select version 8)


*** Synthesijer

cd ~

curl -O -L http://synthesijer.github.io/web/dl/20170322/setup_20170322.sh

sh setup_20170322.sh

echo 'source $HOME/synthesijer/synthesijer_env.sh' >> ~/.bashrc


*** python-pip

echo 'PATH="$HOME/.local/bin:$PATH"' >> ~/.profile

(update python-pip)
sudo apt-get purge python-pip python3-pip

sudo apt-get autoremove

sudo easy_install pip

sudo reboot


*** IceStorm

pip install --user --upgrade apio==0.4.0b3 "tinyprog>=1.0.10"

apio install system scons icestorm iverilog

apio drivers --serial-enable

(connect TinyFPGA BX)

tinyprog --update-bootloader


* build

cd fpga_pmg

cd synthesijer

make

cd ../tinyfpgabx

apio build

apio upload


* Parts Information

TinyFPGA BX
https://tinyfpga.com/bx/guide.html

Boost DC/DC Converter (1.5V to 5V)
http://akizukidenshi.com/catalog/g/gK-13065/
