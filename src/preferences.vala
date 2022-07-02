namespace Music {

    [GtkTemplate (ui = "/com/github/neithern/g4music/gtk/preferences.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {
        [GtkChild]
        unowned Gtk.Switch dark_btn;
        [GtkChild]
        unowned Gtk.Button music_dir_btn;
        [GtkChild]
        unowned Gtk.Switch thumbnail_btn;
        [GtkChild]
        unowned Gtk.Switch playbkgnd_btn;
        [GtkChild]
        unowned Gtk.Switch gapless_btn;
        [GtkChild]
        unowned Gtk.Switch replaygain_btn;
        [GtkChild]
        unowned Gtk.Switch pipewire_btn;
        [GtkChild]
        unowned Gtk.Switch peak_btn;

        public PreferencesWindow (Application app) {
            var settings = app.settings;

            dark_btn.bind_property ("state", app, "dark_theme", BindingFlags.DEFAULT);
            settings?.bind ("dark-theme", dark_btn, "state", SettingsBindFlags.DEFAULT);

            var music_dir = app.get_music_folder ();
            music_dir_btn.label = get_display_name (music_dir);
            music_dir_btn.clicked.connect (() => {
                var chooser = new Gtk.FileChooserNative (null, this,
                                Gtk.FileChooserAction.SELECT_FOLDER, null, null);
                try {
                    chooser.set_file (music_dir);
                } catch (Error e) {
                }
                chooser.modal = true;
                chooser.response.connect ((id) => {
                    if (id == Gtk.ResponseType.ACCEPT) {
                        var dir = chooser.get_file ();
                        if (dir is File && dir != music_dir) {
                            music_dir_btn.label = get_display_name ((!)dir);
                            settings?.set_string ("music-dir", ((!)dir).get_uri ());
                            app.reload_song_store ();
                        }
                    }
                });
                chooser.show ();
            });

            settings?.bind ("remote-thumbnail", thumbnail_btn, "state", SettingsBindFlags.GET_NO_CHANGES);
            thumbnail_btn.bind_property ("state", app.thumbnailer, "remote_thumbnail", BindingFlags.DEFAULT);

            settings?.bind ("play-background", playbkgnd_btn, "state", SettingsBindFlags.GET_NO_CHANGES);

            settings?.bind ("replay-gain", replaygain_btn, "state", SettingsBindFlags.GET_NO_CHANGES);
            replaygain_btn.bind_property ("state", app.player, "replay_gain", BindingFlags.DEFAULT);

            settings?.bind ("gapless-playback", gapless_btn, "state", SettingsBindFlags.GET_NO_CHANGES);
            gapless_btn.bind_property ("state", app.player, "gapless", BindingFlags.DEFAULT);

            settings?.bind ("pipewire-sink", pipewire_btn, "state", SettingsBindFlags.GET_NO_CHANGES);
            pipewire_btn.bind_property ("state", app.player, "pipewire_sink", BindingFlags.DEFAULT);

            settings?.bind ("show-peak", peak_btn, "state", SettingsBindFlags.GET_NO_CHANGES);
            peak_btn.bind_property ("state", app.player, "show_peak", BindingFlags.DEFAULT);
        }

        private static string get_display_name (File dir) {
            var name = dir.get_basename () ?? "";
            if (name.length == 0 || name == "/")
                name = dir.get_parse_name ();
            return name;
        }
    }
}