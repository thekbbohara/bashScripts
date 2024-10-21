wallpapers=$(ls ~/wallpaper)
array=($wallpapers) # Split the string into an array
length=${#array[@]}
random_index=$((RANDOM % length))
# echo "length $length"
# echo "random_index $random_index"
# echo "${array[random_index]}" # Print all elements in the array
wallpaper="${array[random_index]}"

swww img ~/wallpaper/"$wallpaper"
