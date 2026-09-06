mkdir -p "/mnt/c/Odin/Slime"

odin.exe build . -out:"C:/Odin/Slime/Slime.exe" || exit 1

cd "/mnt/c/Odin/Slime"

cmd.exe /c "C:\Odin\Slime\Slime.exe"
