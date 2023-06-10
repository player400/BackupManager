Backup Manager
_______________________________________

This software consists of two Bash scripts that together allow you to easily manage backups on all Gnome-based Linux distributions and all other linux distribution with Zenity installed.

First script, called backup_manager.sh is a Zenity interface for backup management. It allows you to create a new backup, delete a backup or restore a backup.
While creating a backup you need to specify how often backup is supposed to be updated (default is 7 days).

This script will perform the backup only once, during it's creation. After that, the task of updating the backup will fall on script backup.sh.

To work properly backup.sh should always be auto-started on boot of your OS. I recommend using systemd for it.

Both scripts need to be in the same folder with properly configured backup_config.rc file. 


Quick setup guide
______________________

1. Put backup.sh, backup_manager.sh and backup_config.rc in one folder.
2. Write in the backup_config.rc file absolute paths to the scripts' working locations. Scripts will create backups/ folder and backup_list.rc file. You should never delete or modify those directories. Template of a proper backup_config.rc file is attached to this README.
3. Add backup.sh to auto-start of your OS. Personally on Fedora Linux I use systemd to run this script as a system service/deamon. This is done by creating a systemd unit file, that you then put in /etc/systemd/system/. Template of a proper unit file is attached to this README (backup.service). After placing the file in the proper directory execute commands in the following order: "sudo systemctl daemon-reload", ,,sudo systemctl enable backup.service". Then reboot your machine and run: sudo systemctl status backup.service. Status after reboot should be: enabled, active(running).
4. Run backup_manager.sh without options. A Zenity window will open.

IMPORTANT: Script remembers DIRECTORY of the file to backup. If you just move the file no further backups will be done. Script will probably crash. To do this properly, remove the backup in the script first and then create a new one for the new directory.

If you have any problems with configuration or need a more in-detail explanation, feel free to contact me.


License
______________________

Software is hereby released under MIT license. For details see opensource.org. Copy of the licence attached below.

Copyright Mateusz Nurczyński 2023.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"
he above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO #EVENT 	SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS #IN THE SOFTWARE.

