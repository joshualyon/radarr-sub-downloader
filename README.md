# radarr-sub-downloader
Radarr custom post processor script for handling subtitle download. (based on the @ebergama [Sonarr script](https://github.com/ebergama/sonarr-sub-downloader))

# Summary
This project contains 2 main bash scripts for handling Sonarr subtitle download after a movie has been downloaded.

* The script [sub-downloader.sh](sub-downloader.sh) works perfectly as a [Custom Post Processor Script](2) for [Radarr](1).
* The script [search-wanted.sh](wanted/search-wanted.sh) looks for those subtitles that were not found in previous executions of the first one. 
  * The search wanted script has not been completely updated for Radarr. Feel free to make the required changes if you use this functionality and submit a PR.

Behind the scenes, both scripts uses [subliminal](3) as subtitle downloader engine.

# Prerequisites
- Install the [subliminal plugin][3]
   - I **highly** recommend follow the author steps for install subliminal, but you can execute:
   ```bash
   sudo pip install -U subliminal
   ```

# How to setup the script in Radarr
1. Download the [latest][4] release (zip or tar.gz) file.
2. Uncompress the file

         unzip v0.5.zip
         # or
         tar -xvf v0.5.tar.gz
3. Open Radarr, go to: `<your-radarr-host>:<port>/settings/connect`
4. Click in the '+' => Custom Script
5. Choose a name for your script, recommended: "Subs Downloader"
6. Enable "On Download" and "On Upgrade"
7. Choose the path in which the script `sub-downloader` has been cloned.
8. The script requires 1 argument, a comma-separated language list for the subtitles to download, 
   for example, for download English and Spanish subtitles: `-l es,en`

# How to enable the not found searcher to run periodically
> !! This feature has not been finalized in the Radarr fork as I don't personally use it. Feel free to update the script to re-enable this functionality and submit a PR !!
1. Run [the installation script](wanted/install.sh) 
         
         ./wanted/install.sh
2. Check that the crontab has been setup correctly

         crontab -l

# License
MIT

# Developer Information
Josh Lyon - https://boshdirect.com - RADARR FORK  
Ezequiel Bergamaschi - ezequielbergamaschi@gmail.com - SONARR FORK

[1]: https://github.com/Radarr/Radarr
[2]: https://github.com/Radarr/Radarr/wiki/Custom-Post-Processing-Scripts
[3]: https://github.com/Diaoul/subliminal
[4]: https://github.com/joshualyon/radarr-sub-downloader/releases/latest
