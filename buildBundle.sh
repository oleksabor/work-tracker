# parses gitversion tool output for major, minor and patch
json=$(gitversion)

major=$(echo $json | jq '.Major')
minor=$(echo $json | jq '.Minor')
patch=$(echo $json | jq '.Patch')
label=$(echo $json | jq '.PreReleaseLabelWithDash' | xargs)
mmp=$(echo $json | jq '.MajorMinorPatch' | xargs)

echo 'MajorMinorPatch: ' $mmp

# major=11
# minor=2
# patch=4

# formats build number using concatenation of
# major value, two digits minor number, two digits patch
# like mamipa where ma - major value, mi - minor value and pa - patch value 
# from the gitversion tool output
num=$(( 10000*major ))
num=$(( 100*minor + num))
num=$(( patch+num ))

echo $mmp ' => ' $mmp$label'+'$num

flutter build appbundle --build-name $mmp$label --build-number  $num