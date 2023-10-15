# parses gitversion tool output for major, minor and patch
##
##
## flutter 3.3.10
## jdk-17

json=$(dotnet-gitversion)

major=$(echo $json | jq-win64 '.Major')
minor=$(echo $json | jq-win64 '.Minor')
patch=$(echo $json | jq-win64 '.Patch')
label=$(echo $json | jq-win64 '.PreReleaseLabelWithDash' | xargs)
mmp=$(echo $json | jq-win64 '.MajorMinorPatch' | xargs)

echo 'MajorMinorPatch: ' $mmp

# major=11
#minor=2
#patch=100

if (( minor > 99 )); then
echo "minor version number out of range $minor";
exit -1;
fi

if (( patch > 99 )); then
echo "patch version number out of range $patch";
exit -1;
fi

# formats build number using concatenation of
# major value, two digits minor number, two digits patch
# like mamipa where ma - major value, mi - minor value and pa - patch value 
# from the gitversion tool output
num=$(( 10000*major ))
num=$(( 100*minor + num))
num=$(( patch+num ))

echo $mmp ' => ' $mmp$label'+'$num

flutter clean

flutter build appbundle --build-name $mmp$label --build-number  $num -t  lib/main.dart
