# README
A toy PDF viewer I made as a learning project -- `ramanpdf.app`.

Since I do not have the xcode IDE, I explored alternatives and found 
the trio of Vala compiler, GTK4, and Poppler.
This project took me on a happy journey of discovery.
To share the lessons I learnt, I put it here on github for like-minded 
people who are possibly in search of a similar solution.

## What I wanted 
1. A PDF viewer with simple key-press control.
2. GUI application that runs on OSX Big Sur without showing the terminal.
3. Able to call it from OSX Finder's "Open With" context menu.
4. Can switch between a "light" and a "dark" mode.
5. Can be put on one side of the screen, so that I can take notes with
   another app on the other side.
6. Able to rotate and zoom the pdf page.

## Features 
1. No menu.
2. Key-press commands:
   * 'o' opens a FileDialog to choose the PDF file.
   * '=' to zoom in.
   * '-' to zoom out.
   * '0' (zero) to reset zoom.
   * ' ' (space) to cycle forward through the pages.
   * 't' to rotate 90 degrees clockwise each time.
   * 'd' to toggle between color and grayscale.
   * 'i' to flip color or grayscale to their opposites. 
   * 'q' to quit.
3. Scrolling is restricted to panning the one page within the window.
   Scrollbar(s) appear when the page is too big for the window.
4. Grey background when no file; or when PDF is a damaged file (or not PDF).
5. Handles opening of file from Finder (ie., it is *registered*).
6. Does not open multiple windows.
   The single application window is recycled for each new file opened.
7. User can see highlights (but cannot add new highlight).
8. Window title can be empty, a document file name, or an error message.
9. Resizable window.

## Limitations
1. Not app-sandboxed, hardened, notarised, or evaluated by gatekeeper.
2. No security measures to protect against cyber-attacks.
3. Not much error-handling.
4. A lag when rendering a 'busy' page (colorful or large image).
5. No key-press command to go back one page.
6. Content does not resize to window (ie., cannot zoom by resizing window).
7. User cannot select text or images for copying.
8. User cannot add highlights, annotations, bookmarks, or anything.
9. Does not respond to clicking URL inside the pdf.
10. Does not support "drag and drop".
11. In essence, whatever not mentioned in "Features" above.
12. Not tested on any OS besides Apple OSX 11.7.10 (Big Sur).

## Ingredients
1. Compiler, tools, and libraries: Vala, GTK4, Poppler, pkg-config.
2. Code: `ramanpdf.vala`, `ramanpdf.icns`, `Info.plist`, `makefile`.
3. Optional: `svg2icns.sh` and `ramanpdf.svg`.
   Not uploaded to github here.

## Mac App Bundling
* The makefile makes the app (`ramanpdf`) and packages it into
  an app bundle (`ramanpdf.app`).
  * An "App Bundle" is the result of Apple's way of arranging an app, 
    its linked libraries, app icon, and "configuration" file (pList) into
    a folder structure with a `.app` suffix -- that we have come to know 
    as an OSX Application.
  * When a app bundle is run, it no longer shows a Terminal window.
  * The makefile simply copies `ramanpdf`, `ramanpdf.icns`, and `Info.plist`;
    and pastes them into the folder structure of an app bundle.
  * It also copies the relevant dynamic libraries (of GTK4 and Poppler) 
    and pastes them to the folder structure; and finally tells `ramanpdf` 
    how to find them within the app bundle.
  * To tell `ramanpdf` how to find the libraries, it uses OSX's `otool` to
    find the libraries that `ramanpdf` links to, then it selects the ones
    that are not built-in (which would be the GTK and Poppler libraries), 
    and uses OSX's `install_name_tool` to tell `ramanpdf` about the new
    paths of the libraries.
  * Although 'otool' and 'install_name_tool' are both built-in OSX programs,
    I am not certain whether this part of the make process will work for
    other OSX versions.
    (Easy to check whether your OSX have these, by typing `which otool` in 
    the Terminal. Similarly, for install_name_tool).
  * The `list.txt` is generated by the makefile and it lists all the 
    libraries that are to be copied to the app bundle.
* Accessories:
  * Inkscape (for designing the app bundle icon as an Inkscape SVG file).
  * zsh shell file [svg2icns.sh](
    https://gist.github.com/ikey4u/659f38b4d7b3484d0b55de85a55a8154) 
    (for making icns file from the SVG above).
    It uses Inkscape to convert the SVG into multiple PNG files, each of
    a different size, and after that it uses OSX built-in `iconutil` to 
    group these PNG files into a single ICNS file.

## How I built the application and the OSX app bundle
1. Set up:
   * I developed on OSX Big Sur (and not sure if it works on others).
   * I used [homebrew](https://brew.sh) to install Vala, GTK4, and Poppler.
   * I used [homebrew](https://brew.sh) to install `pkg-config`.
     * Since I am using homebrew's version of pkg-config, I must export a 
       PKG_CONFIG_PATH environment variable for each of `libffi` and `glib` 
       to ensure pkg-config looks for the correct libraries in the correct
       paths.
       This has been incorporated in the makefile.
   * Optional (for designing the icon SVG file):
     I used Inkscape to make `ramanpdf.svg`.
     Then I used `svg2icns.sh` to make `ramanpdf.icns`.
2. Build:
   * I used `make` instead of the `meson` and `ninja` that came with the 
     homebrew installation of `gtk4`.
     (It might be easier to build by using the latter two but I am less 
     familiar with them than with `make`).
   * Run `make` to build *everything*:
     * `ramanpdf` - this runs with Terminal showing.
     * `list.txt` - this is just a by-product of the build process.
     * `ramanpdf.app` - this runs without Terminal showing.
   * Instead, to just build the app that can be called from Terminal 
     and not for registering with OSX Finder, run `make ramanpdf`.
     If things go well, a file named `ramanpdf` should appear.
     You can then run it using the command `./ramanpdf` in Terminal.
     Or, double-click on `ramanpdf` in Finder.
   * The Terminal `ramanpdf` accepts a single argument of file name.
     For example, run `./ramanpdf filename.pdf` to open said pdf file.

## Install App Bundle and Register with OSX Finder
1. Copy `ramanpdf.app` to the Applications folder to install. 
   And then double-click on it (ie., run it inside the Applications folder) 
   to register.
2. I take it as registered when the app window appears.
3. If registration went well, you should be able to see `ramanpdf.app` in 
   the context menu (test right-click on a file in Finder - look under 
   "Open With").

## Clean-up 
1. To start over, run `make clean` to remove everything that was made.
2. The 'ramanpdf.app' can be removed from the Applications folder 
   the usual way if you do not want it anymore -- just delete it.

## Pre-Release
I have uploaded my build of `ramanpdf` and `ramanpdf.app`.
But your OSX *might* say it comes from another computer and refuse to run
it for security reasons.
I mean, I have not tested on other people's Apple computers, so that is 
why I included the word "might".

My OSX did not complain about security, but probably because I build the
App Bundle on my OSX.
If you build it yourself on your own OSX, your OSX security *might* not 
complain.

## Acknowledgements
1. [Vala](https://vala-language.org) for taking the pain out of working
   with C coding.
2. [GTK4](https://www.gtk.org) for making the GUI look like the native 
   OSX GUI and can be easily registered with OSX Finder.
3. [Poppler](https://poppler.freedesktop.org) for making it so easy to 
   incorporate PDF rendering into GTK4, using the poppler-glib API.
4. [Inkscape](https://inkscape.org) for making it possible to quickly 
   design a simple image file in SVG.
5. Many thanks to zhq/ikey4u, the author of [svg2icns.sh](
   https://gist.github.com/ikey4u/659f38b4d7b3484d0b55de85a55a8154) 
   for a wonderful shell script that streamlines my icon design workflow to
   Inkscape and `iconutil` only.  
6. This [GNOME discourse](
   https://discourse.gnome.org/t/using-filedialog-in-vala/15376) pointed
   the way how to use the file dialog in Vala.
7. [Stackoverflow.com](https://stackoverflow.com).
8. [Apple StackExchange](https://apple.stackexchange.com).
9. Many other sources on the web that I have not mentioned here.

## Bugs 
1. Poppler (Cairo backend) [bug](
   https://gitlab.freedesktop.org/poppler/poppler/-/issues/1443) 
   related to an image in PDF file.
   

## DISCLAIMER
I am not a professional programmer; and I do not have any real software 
industry exposure or experience. 
I do not know what the relevant standards are; and I have not done strong
testing of this code and of this application.
As a consequence, I cannot guarantee that this application or the code 
provided here is safe, error-free, or even harmless.

Use at your own risk!

