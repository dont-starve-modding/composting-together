#/bin/bash
echo "removing..."
SUFFIX=$(ls *.tex| cut -c1-6)
rm -r "/c/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/mods/build-${SUFFIX}"
echo "copying to /c/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/mods/build-${SUFFIX} ..."
cp -r build "/c/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/mods/build-${SUFFIX}"