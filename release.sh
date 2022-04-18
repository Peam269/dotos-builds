BUILDS=~/android/builds
REPO=https://github.com/Peam269/dotos-builds
EDITOR=nano
ZIPPATH=out/target/product/raphael

ZIPNAME=$(ls $ZIPPATH/dotOS-*.zip | tail -n1 | xargs -n1 basename)
METADATA=$(unzip -p "$ZIPPATH/$ZIPNAME" META-INF/com/android/metadata)
TIMESTAMP=$(echo "$METADATA" | grep post-timestamp | cut -f2 -d '=')
HASH=$(cut -f1 -d ' ' $ZIPPATH/$ZIPNAME.sha256sum)
SIZE=$(du -b $ZIPPATH/$ZIPNAME | cut -f1 -d '	')
VERSION=$(echo $ZIPPATH/$ZIPNAME | cut -f2 -d '-')
DATE=$(echo $ZIPNAME | cut -f5 -d '-')
DEVICE=$(echo "$METADATA" | grep pre-device | cut -f2 -d '=' | cut -f1 -d ',')
RELEASENAME=${DEVICE}-${DATE}
URL="$REPO/releases/download/${RELEASENAME}/${ZIPNAME}"


echo "device": $DEVICE
echo "date": $DATE
echo "generatedAt": $TIMESTAMP,
echo "fileName": "$ZIPNAME",
echo "url": "$URL",
echo "hash": "$HASH",
echo "size": $SIZE,
echo "version": "$VERSION"


cp $ZIPPATH/dotOS-*.zip $BUILDS
git -C $BUILDS/dotos-builds pull > /dev/null 2>&1
FILE="$BUILDS/dotos-builds/raphael.json"
/bin/cat <<EOM >$FILE
{
  "codename": "raphael",
  "deviceName": "Redmi K20 Pro",
  "brandName": "Xiaomi",
  "releases": [
    {
      "type": "UNOFFICIAL",
      "generatedAt": $TIMESTAMP,
      "fileName": "$ZIPNAME",
      "url": "$URL",
      "requireCleanFlash": false,
      "images": null,
      "hash": "$HASH",
      "size": $SIZE,
      "version": "$VERSION"
    }
  ]
}
EOM
# Push changes made to raphael.json to GitHub
$EDITOR $BUILDS/dotos-builds/changelog.md
git -C $BUILDS/dotos-builds add raphael.json
git -C $BUILDS/dotos-builds add changelog.md
git -C $BUILDS/dotos-builds commit -m $RELEASENAME
git -C $BUILDS/dotos-builds tag $RELEASENAME
git -C $BUILDS/dotos-builds push
cd $BUILDS/dotos-builds && gh release create $RELEASENAME -F changelog.md $BUILDS/$ZIPNAME --target main
echo new build released!
