# Render all Playgrounds
find ../ -name contents.xcplayground -exec sed -i '' -e "s/raw/rendered/" {} \;
