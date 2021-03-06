#/bin/bash

echo "removing artifacts..."
rm -r build/

echo "creating directories..."
mkdir -p build/scripts
mkdir -p build/images/inventoryimages
mkdir -p build/anim

echo "compiling animations..."
"C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Mod Tools\mod_tools\scml.exe" compostpile.scml .
"C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Mod Tools\mod_tools\scml.exe" ui_compostpile1c6x3/ui_compostpile1c6x3.scml .

echo "copying files and scripts..."
cp -r scripts/* build/scripts/
cp images/inventoryimages/*.xml build/images/inventoryimages
cp images/inventoryimages/*.tex build/images/inventoryimages
cp -r anim/*.zip build/anim/
cp CONTRIBUTORS build/
cp compostingtogether.* build/
cp LICENSE build/
cp *.lua build/
cp README* build/

echo "Finished."