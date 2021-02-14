# creates a youtube video with a still image
export OUTPUTDIR=/Users/mlynn/Music/Podcast/Daily Reflections/
for ii in `ls input/*.mp3`; do
   nn=`basename $ii | cut -d "." -f 1`
   mm=`echo $nn | cut -f 1 -d "-"`
   dd=`echo $nn | cut -f 2 -d "-"`
   tt=`cat assets/reflections-month-day.csv | grep "^$mm,$dd," | cut -d "," -f 3`
   echo "Base: ${nn} "
   echo "Month: ${mm}"
   echo "Day: ${dd}"
   echo "Reflection: $tt"
   echo
   if [ ! -d output/$mm-$dd ]; then
      mkdir output/"${mm}-${dd}"
   fi
   # generate text image for video
   #convert -gravity southeast -splice 40x40  -gravity northwest -splice 40x40 -font Helvetica -gravity Center -weight 700 -pointsize 100 pango:"<b>$3</b>\n$4" image-text.png
   convert -gravity southeast -splice 360x40  -gravity northwest -splice 360x40 -font Helvetica-Bold -gravity Center -weight 400 -pointsize 100 caption:"${mm} ${dd}\n${tt}" assets/image-text.png
   # convert image to full hd for video
   convert -gravity Center -resize 1920x1080^ -extent 1920x1080 "assets/background.jpg" "output/${mm}-${dd}/$nn"-1920x1080.png
   # merge transparent images for video
   composite -dissolve 30 -gravity Center assets/image-text.png "output/${mm}-${dd}/$nn"-1920x1080.png -alpha Set "output/${mm}-${dd}/$nn"-cover-1920x1080.png
   #convert image to square for SoundCloud and Insta
   convert -gravity Center -resize 1080x1080^ -extent 1080x1080 "output/${mm}-${dd}/$nn"-cover-1920x1080.png "output/${mm}-${dd}/$nn"-cover-1080x1080.png
   # genreate eq video
   /usr/local/bin/ffmpeg -i "$ii" -loop 1 -i "output/${mm}-${dd}/$nn"-cover-1920x1080.png -filter_complex "[0:a]showwaves=s=1920x200:mode=cline:colors=0xFFFFFF|0xD3D3D3:scale=sqrt:draw=full[fg];[1:v]scale=1920:-1[bg];[bg][fg]overlay=shortest=1:850:format=auto,format=yuv420p[out]" -map "[out]" -map 0:a -pix_fmt yuv420p -c:v libx264 -preset medium -crf 18 -c:a copy -shortest "output/${mm}-${dd}/$nn"-video.mkv
   /usr/local/bin/ffmpeg -i "output/${mm}-${dd}/$nn"-video.mkv -c copy -c:a aac -movflags +faststart "output/${mm}-${dd}/$nn"-video.mp4
   rm "output/${mm}-${dd}/$nn"-video.mkv
   mv $ii ./processed
done
exit;

echo "output/${mm}-${nn}/$nn"-1920x1080.png genrated
echo "output/${mm}-${nn}/$nn"-cover-1920x1080.png generated
echo "output/${mm}-${nn}/$nn"-cover-1080x1080.png generated
echo "output/${mm}-${nn}/$nn"-video.mkv generated

