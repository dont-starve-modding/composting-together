echo "removing artifacts..."
rm -r build/

mkdir -p build/scripts
mkdir -p build/images
mkdir -p build/anim

echo "copying files and scripts..."
cp -r scripts/* build/scripts/
cp -r images/* build/images/
cp -r anim/* build/anim/
cp CONTRIBUTORS build/
cp compostingtogether.* build/
cp LICENSE build/
cp *.lua build/
cp README* build/

echo "Finished."