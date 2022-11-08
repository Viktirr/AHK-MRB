# AHK-MRB
AutoHotkey - Multiple Replay Buffers for OBS  
  
This script is meant to save you some time during editing by only saving the amount of time you think is necessary for a clip, on the fly. You could also use it to upload the clips directly to YouTube or any other platform without wasting time trimming it out.  

## Usage  
Saving videos is simple, the default controls include:
- Alt + F2 - Saving the last 8 seconds
- Alt + F3 - Saving the last 20 seconds
- Alt + F5 - Saving the last 30 seconds
- Alt + F6 - Saving the last 45 seconds
- Alt + F7 - Saving the last 60 seconds (1 minute)
- Alt + F8 - Saving the last 120 seconds (2 minutes)
- Alt + F9 - Saving the last 180 seconds (3 minutes)
- Alt + F10 - Saving the last 300 seconds (5 minutes)
- Alt + F11 - Start/Stop Recording
- Alt + S - Force Save (Closing OBS also works)  
  
Upon exiting OBS, or force saving, your clips will be trimmed to the last amount of seconds you've chosen per clip.

## Installation
### Prerequisites
- Windows 10/11
- AutoHotkey  
Download: https://www.autohotkey.com/
- FFmpeg Binaries (essential or full)  
Download: https://www.gyan.dev/ffmpeg/builds/
- The Script Itself (AHK-MRB.ahk)  
Download: https://github.com/Viktirr/AHK-MRB/releases  

### Installation process
#### The script
You can save the script pretty much wherever you like,
if you'd like the script to start as soon as Windows is done booting, head over to...  
```
%AppData%\Microsoft\Windows\Start Menu\Programs\
```  
...and paste the script (AHK-MRB.ahk) there.
#### FFmpeg
There is no restriction for FFmpeg's location either, just as long as it doesn't require administrator rights to run, any place should be fine.  
My recommendation is to create a folder named ffmpeg inside Documents and paste ffmpeg.exe there  
1. Open the downloaded .7z file that contains FFmpeg
2. Head over to the bin folder inside the .7z file
3. Drag and drop ffmpeg.exe to the folder you created (or create the folder now)
4. Delete the .7z file  
#### Setting up the script  
- Create 2 new folders, one where the video will be temporarily stored, and the other where the final videos will be stored (the temporary folder can be nested inside the final one, the naming of the folders are up to your choosing).
- Open the script with a text editor (Notepad, Notepad++, VS Code...)  
- Set SetWorkingDir to the folder where ffmpeg is located (if you can't find SetWorkingDir, use Ctrl + F)
- Set TemporaryDirectory to the temporary folder you just created
- Set FinalDirectory to the final folder you just created
- Save the script and exit
#### Setting up OBS
Please note that all of these steps are mandatory for the script to work properly.
##### Set Recording Format to .mkv
- Open OBS -> Settings -> Output -> Recording
- Select .mkv under Recording Format
##### Select your Temporary Folder
- OBS -> Settings -> Output -> Recording
- Under Recording Path click Browse
- Select the temporary folder for saving your replays
##### Enable & Configure Replay Buffer
- OBS -> Settings -> Output -> Replay Buffer
- Enable the Replay Buffer
- Set the Replay Buffer to 300 seconds
##### Match Script Hotkeys with OBS
- OBS -> Settings -> Hotkeys
- Replace Save Replay with Alt + F10
- Replace Start/Stop Recording with Alt + F11
- Apply changes
  
If you've done everything as described, you should be good to go!

## Additional configuration  
If you want to customise your script even further, this [YouTube Video](https://www.youtube.com/watch?v=QQHP5CUg7WM) explains how to change the amount of replay buffers, change the hotkeys, compress videos further with x264 or x265, and tweak some additional options you may also like to change.
