# Back up YouTube Music

This project provides a solution to download an entire YouTube playlist and convert all the music into high-quality MP3 files.

It uses [yt-dlp](https://github.com/yt-dlp/yt-dlp) for extraction, [ffmpeg](https://www.ffmpeg.org/) for conversion, and [aria2](https://github.com/aria2/aria2) for high-speed multi-threaded downloads. It also maintains an archive file to ensure you only download new songs on subsequent runs.

## Environment setup

Create and activate a new Python environment using [conda](https://anaconda.org/anaconda/conda) or python's built-in [venv](https://docs.python.org/3/library/venv.html) module:

```bash
# Create a new conda environment and activate it:
conda create -n yt_downloader python=3.13 -y
conda activate yt_downloader

# If you prefer using venv, you can do the following:
python -m venv yt_downloader
source yt_downloader/bin/activate
```

Install the required tools:

```bash
# Install yt-dlp using pip
pip install yt-dlp

# Install ffmpeg and aria2 using apt (for Ubuntu/Debian-based systems)
sudo apt update && sudo apt install ffmpeg aria2
```

## Usage

### Manual download

You can run the backup manually using this optimized command. It updates `yt-dlp`, uses `aria2c` for speed, and saves files to the `$HOME/Music/YouTubeMusic/no_lyrics/` directory.

> [!NOTE]
> Replace the playlist URL below with your own if needed.
>
> Change the output directory (`$HOME/Music/YouTubeMusic/no_lyrics/`) before running the command.

```bash
yt-dlp -U && yt-dlp -x --audio-format mp3 \
  --download-archive archive.txt \
  --downloader aria2c \
  --downloader-args "aria2c:-x 16 -s 16 -k 1M" \
  -o "$HOME/Music/YouTubeMusic/no_lyrics/%(title)s.%(ext)s" \
  "https://www.youtube.com/playlist?list=PL22-qG2MGGhAr96FUEz9jv11sVx0nSZTY"
```

Here is a breakdown of the command options:

- **`-U`**: Ensures you always have the latest fixes for YouTube extraction.
- **`--download-archive archive.txt`**: Remembers what you've downloaded so it finishes instantly on subsequent runs.
- **`--downloader aria2c`**: Uses a much faster engine to pull files.
- **`--downloader-args "aria2c:-x 16 -s 16 -k 1M"`**: Configures the high-speed engine:
  - **`-x 16`**: Sets the maximum number of connections to a single server (default is 1).
  - **`-s 16`**: Splits each file into 16 segments to be downloaded simultaneously.
  - **`-k 1M`**: Sets the minimum split size. `aria2` will only split a file if the range is at least `2 * SIZE` (in this case, 2MB), which prevents the overhead of multi-threading for very small files.

## Automation with Anacron

For systems that are not powered on 24/7, **Anacron** is used instead of standard cron. Anacron ensures the job runs weekly, even if the computer was off at the scheduled time (it runs the next time the machine boots up).

The bash script [`backup_music.sh`](./backup_music.sh) handles logging, environment activation, and file paths.

### Create the weekly job

Create a new file in the `/etc/cron.weekly/` directory (without an extension):

```bash
sudo nano /etc/cron.weekly/backup-yt-music
```

### Add the configuration

Paste the following content. This command switches to the specified user (`su - <your_username>`) so the script can access the correct environment and ensure the downloaded files belong to the user, not `root`.

> [!IMPORTANT]
> Replace `<your_username>` with your actual system username. Also, ensure the path to the script is correct for your system.

```bash
#!/bin/bash
su - <your_username> -c "/home/<your_username>/Projects/BackUpYouTubeMusic/backup_music.sh"
```

### Enable the job

Make the script executable:

```bash
sudo chmod +x /etc/cron.weekly/backup-yt-music
```

### Verification

You can test that it works manually by running:

```bash
sudo /etc/cron.weekly/backup-yt-music
```

Logs will be generated in `logs/weekly_backup_YYYY-MM-DD.log`.

## Licence

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

Ensure you comply with YouTube's terms of service regarding content downloading.
