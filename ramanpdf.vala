/*

ramanpdf.vala

Copyright 2023 Roland Chee <rolandchee@gmail.com>

This program is distributed under the terms of the
GNU General Public Licence.

This program is free software: you can redistribute it
and/or modify it under the terms of the GNU General
Public License as published by the Free Software
Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will 
be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General 
Public License along with this program. If not, see
<https://www.gnu.org/licenses/>.

This program is a work that uses the GTK library.
The GTK library is licensed under the terms of the
GNU Library General Public License Version 2, June 1991.

You should have received a copy of the GNU Library
General Public License along with this program;
if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

This program is a work that uses the Poppler library.
The Poppler library is licensed under the terms of the
GNU General Public License Version 2, June 1991.

You should have received a copy of the GNU 
General Public License along with this program;
if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

*/

using Gtk;
using Poppler;

int 
main (string[] argv)
{

    GLib.File gfile = null;
    string doc_name = "";
    int rotate  = 0;
    int index   = 0;
    int n_pages = 0;
    bool invert    = false;
    bool grayscale = false;
    double scale = 1.0;
    double pgw   = 0.0;
    double pgh   = 0.0;
    
    Gtk.Application application =
        new Gtk.Application (
            "org.ramanpdf.www",
            GLib.ApplicationFlags.HANDLES_OPEN);

    // register with OSX to open file from Finder
    // must be done here and
    // cannot be done under startup
    Value val = Value (GLib.Type.BOOLEAN);
    val.set_boolean (true);
    application.set_property ("register-session", val);
    val.unset ();

    application.startup.connect (()=>{

        // application accelerator action
        GLib.SimpleAction action1 =
            new GLib.SimpleAction ("actiona", null);
        action1.activate.connect (()=>{ 
            //print("Action1\n"); 
            application.quit();});
        action1.set_enabled (true);
        application.add_action (action1);
        const string[] key1 = {"q"};
        application.set_accels_for_action ("app.actiona", key1);

    });

    application.activate.connect (()=>{

        // does not open any window  
        // but passes this to application.open
        if (argv.length > 1)
        {
            GLib.File file =
                GLib.File.new_for_commandline_arg (argv[1]);
            application.open ({file},"");
            return;
        } 
        else {
            application.open ({null},"");
            return;
        };

    });

    application.open.connect ((files, hint)=>{

        // opens the window 
        gfile = files[0];

        Gtk.ApplicationWindow window = null;
        if (application.get_active_window () != null) 
        {
            window = application.get_active_window () as 
            Gtk.ApplicationWindow;
        } 
        else {
            window = new Gtk.ApplicationWindow (application);
            window.set_default_size (480, 360);
        };

        Gtk.ScrolledWindow screen = 
            new Gtk.ScrolledWindow ();
        window.set_child (screen);

        Gtk.DrawingArea da = 
            new Gtk.DrawingArea ();
        screen.set_child (da);

        da.set_draw_func ((da,cr,w,h)=>{

            if (gfile == null) 
            {
                cr.set_source_rgb (0.7,0.7,0.7);
                cr.rectangle (0,0,w,h);
                cr.fill ();
            } 
            else 
            {

                try 
                { 
                    Poppler.Document popdoc = 
                        new Poppler.Document.from_gfile (gfile, 
                        null, null); 

                    if (popdoc != null)
                    {

                        // whether run from commandline or from inside app
                        // window title is set here
                        doc_name = gfile.get_basename ();
                        window.set_title (doc_name);

                        n_pages = popdoc.get_n_pages ();
                        index %= n_pages;
                        
                        Poppler.Page poppage = 
                            popdoc.get_page (index);
                        poppage.get_size (out pgw, out pgh);

                        if ((rotate % 2) ==0) 
                        {
                            da.set_content_width ((int)(pgw * scale));
                            da.set_content_height((int)(pgh * scale));
                        }
                        else
                        {
                            da.set_content_height((int)(pgw * scale));
                            da.set_content_width ((int)(pgh * scale));
                        };

                        Cairo.ImageSurface surface =
                            new Cairo.ImageSurface (
                                Cairo.Format.ARGB32,
                                (int)(scale * pgw),
                                (int)(scale * pgh));
                        Cairo.Context context =
                            new Cairo.Context (surface);
                        context.scale (scale,scale);
                        poppage.render (context);
                        switch (rotate) {
                            case 1: 
                                cr.translate (
                                    (double)(scale*pgh),
                                    (double)(scale*0));
                                cr.rotate ((double)( 90*GLib.Math.PI/180));
                                break;
                            case 2:
                                cr.translate ( 
                                    (double)(scale*pgw),
                                    (double)(scale*pgh));
                                cr.rotate ((double)(180*GLib.Math.PI/180));
                                break;
                            case 3: 
                                cr.translate (
                                    (double)(scale*0),
                                    (double)(scale*pgw));
                                cr.rotate ((double)(270*GLib.Math.PI/180));
                                break;
                            default: 
                                break;
                        };
                        // lays an opaque white background
                        // because some PDF has transparent parts
                        cr.set_operator (Cairo.Operator.SOURCE);
                        cr.set_source_rgba (1,1,1,1); 
                        cr.paint ();
                        // lays the PDF over the background
                        cr.set_operator (Cairo.Operator.OVER);
                        cr.set_source_surface (context.get_target (), 0, 0);
                        cr.paint ();
                        if (invert==true)
                        {
                            cr.set_operator (Cairo.Operator.DIFFERENCE);
                            cr.set_source_rgba (1,1,1,1); 
                            cr.paint ();
                        };
                        if (grayscale==true)
                        {
                            cr.set_operator (Cairo.Operator.HSL_SATURATION);
                            cr.set_source_rgba(0,0,0,1);
                            cr.paint ();
                        };
/*
                        print("%d of %d pages\n", index+1, n_pages);
                        print("Cairo scale: %f\n", scale);
                        print("Cairo rotate: %d\n", rotate);
                        print("Poppler page width: %d, height: %d\n",
                               (int)pgw, (int)pgh);
                        print("DA Content width: %d, height: %d\n",
                              da.get_content_width (),
                              da.get_content_height ());
                        print("Widget width: %d, height: %d\n",
                              screen.get_width(), 
                              screen.get_height());
                        print("R:%1.1f G:%1.1f B:%1.1f A:%1.1f\n",
                            red, green, blue, alpha);
*/

                    };

                }
                catch (GLib.Error e) 
                {
                    //print("Poppler: %s\n", e.message);
                    gfile = null; // stop repeating same error
                    doc_name = "";
                    window.set_title (e.message);
                };
            };  
        });

        Gtk.EventControllerKey eventkey = 
            new Gtk.EventControllerKey ();
        eventkey.key_pressed.connect ((keyval, keycode, state)=>{
            //print ("keyval: %3u keycode: %3u\n", keyval, keycode);
            //print ("keyval_name: %s\n", Gdk.keyval_name(keyval));
            switch (Gdk.keyval_name (keyval)){
                case "o":
                    FileDialog fileDialog = 
                        new FileDialog ();
                    Cancellable cancellable = null;
                    fileDialog.set_accept_label ("open");
                    fileDialog.open.begin (window, cancellable,
                                          (obj,res)=>{
                        try 
                        { 
                            gfile = fileDialog.open.end (res); 
                            if (gfile != null) 
                            {
                                //print ("File: %s\n", gfile.get_path ()); 
                                da.queue_draw (); // window title is set there
                            };
                        }
                        catch (GLib.Error e) 
                        { 
                            //print ("Open error: %s\n", e.message); 
                            string error_message = e.message;
                            window.set_title (error_message);
                        }
                    });
                    break;
                case "equal":
                    scale += 0.1;
                    da.queue_draw ();
                    break;
                case "minus":
                    scale -= 0.1;
                    if (scale < 0.1) {scale = 0.1;};
                    da.queue_draw ();
                    break;
                case "0":
                    scale = 1.0;
                    da.queue_draw ();
                    break;
                case "space":
                    if ((gfile != null) && (n_pages != 0))
                    {
                        if ((state & Gdk.ModifierType.SHIFT_MASK) ==
                            Gdk.ModifierType.SHIFT_MASK)
                        {
                            index--;
                            if (index < 0)
                            {
                                index = n_pages - (index.abs() % n_pages);
                                da.queue_draw ();
                            }
                            else
                            {
                                index %= n_pages;
                                da.queue_draw ();
                            };
                        }
                        else
                        {
                            index++;
                            index %= n_pages;
                            da.queue_draw ();
                        };
                    }
                    break;
                case "i":
                    invert = !invert;
                    da.queue_draw ();
                    break;
                case "t":
                    rotate++;
                    rotate %= 4;
                    da.queue_draw ();
                    break;
                case "d":
                    grayscale = !grayscale;
                    da.queue_draw ();
                    break;
                default:
                    break;

            };
            return true;
        });
        screen.add_controller (eventkey);

        window.present ();

    });

    var status = application.run (argv);
    return status;
}
