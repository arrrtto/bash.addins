**To "install" **or basically start using this Library with custom functionalities, all you have to do is:
1. Have a GNU/Linux operating system (Debian-based, LMDE for example)
2. Download the bash.addins file
3. Put it into your Home folder, under a folder called "bin". If you don't have a "bin" folder, create it, and then put the file there
4. Make the file executable in Terminal: chmod +x /home/$USER/bin/bash.addins
5. Run this: bash.addins setup

The setup does this: installs some needed dependencies with sudo apt install command (works on Debian based systems), then adds "source bash.addins" command to .bashrc file so that the Library would get imported every time you open the Terminal.

**Custom commands (parameters):**
bash.addins help
bash.addins setup
bash.addins update
bash.addins version


Testing, help (by additional developments to the Library) and feedback are welcome.
Contact: artto@tuta.com or @divineloveartto on Telegram
