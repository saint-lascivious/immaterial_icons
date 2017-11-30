#!/usr/bin/perl -w

use File::Temp;
use Getopt::Long;

#MAIN ICON SET
my @iconlist = (
    "./source/ic_music_note_black_48px",            # ICON_AUDIO
    "./source/ic_folder_black_48px",                # ICON_FOLDER
    "./source/ic_format_list_bulleted_black_48px",  # ICON_PLAYLIST
    "./source/ic_chevron_right_black_48px",         # ICON_CURSOR
    "./source/ic_palette_black_48px",               # ICON_WPS
    "./source/ic_sd_storage_black_48px",            # ICON_FIRMWARE
    "./source/ic_font_download_black_48px",         # ICON_FONT
    "./source/ic_language_black_48px",              # ICON_LANGUAGE
    "./source/ic_settings_applications_black_48px", # ICON_CONFIG
    "./source/ic_extension_black_48px",             # ICON_PLUGIN
    "./source/ic_bookmark_black_48px",              # ICON_BOOKMARK
    "./source/ic_star_black_48px",                  # ICON_PRESET
    "./source/ic_playlist_add_black_48px",          # ICON_QUEUED
    "./source/ic_swap_vert_black_48px",             # ICON_MOVING
    "./source/ic_keyboard_black_48px",              # ICON_KEYBOARD
    "./source/ic_chevron_left_black_48px",          # ICON_REVERSE_CURSOR
    "./source/ic_help_black_48px",                  # ICON_QUETIONMARK
    "./source/ic_settings_applications_black_48px", # ICON_MENU_SETTING
    "./source/ic_settings_applications_black_48px", # ICON_MENU_FUNCTIONCALL
    "./source/ic_settings_applications_black_48px", # ICON_SUBMENU
    "./source/ic_settings_black_48px",              # ICON_SUBMENU_ENTERED
    "./source/ic_fiber_manual_record_black_48px",   # ICON_RECORDING
    "./source/ic_record_voice_over_black_48px",     # ICON_VOICE
    "./source/ic_settings_applications_black_48px", # ICON_GENERAL_SETTINGS_MENU
    "./source/ic_settings_black_48px",              # ICON_SYSTEM_MENU
    "./source/ic_play_arrow_black_48px",            # ICON_PLAYBACK_MENU
    "./source/ic_desktop_windows_black_48px",       # ICON_DISPLAY_MENU
    "./source/ic_smartphone_black_48px",            # ICON_REMOTE_DISPLAY
    "./source/ic_radio_black_48px",                 # ICON_RADIO_SCREEN
    "./source/ic_storage_black_48px",               # ICON_FILE_VIEW_MENU
    "./source/ic_equalizer_black_48px",             # ICON_EQ
    "./source/rockbox-icon"                         # ICON_ROCKBOX
);


# VIEWERS ICON SET
my @iconlist_viewers = (
    "./source/ic_brush_black_48px",                 # BMP
    "./source/ic_theaters_black_48px",              # MPEG
    "./source/ic_extension_black_48px",             # CH8, SNA, TAP, TZX, Z80
    "./source/ic_music_note_black_48px",            # MID, MP3, RMI, WAV
    "./source/ic_description_black_48px",           # NFO, TXT
    "./source/ic_videogame_asset_black_48px",       # SS
    "./source/ic_videogame_asset_black_48px",       # GB, GBC
    "./source/ic_image_black_48px",                 # JPE, JPEG, JPG
    "./source/ic_format_list_bulleted_black_48px",  # M3U
    "./source/ic_videogame_asset_black_48px",       # PGN
    "./source/ic_lightbulb_outline_black_48px",     # ZZZ
);


my $help;
my $do_viewers;
my $source="";
my $size;
my @list = @iconlist;
my $output = "immaterial_icons";


GetOptions ( 'c' => \$do_theme,
             'h|help'   => \$help,
             'o|output=s' => \$output,
             't|source=s' => \$source,
             'v' => \$do_viewers,
    );


if($#ARGV != 0 or $help) {
    print "usage: $0 [-o <PREFIX>] [-t <PATH>] [-c] [-v] <SIZE>\n";
    print "\n";
    print "  -c\tgenerate theme .cfg\n";
    print "\tnote: also builds the main icon set\n";
    print "\tnote: default <SIZE>-<PREFIX>.cfg\n";
    print "  -h\tshow this help dialogue\n";
    print "  -o\tuse <PREFIX> for the output filename\n";
    print "\tnote: default <PREFIX> is \"immaterial_icons(_viewers)\"\n";
    print "  -t\tpath to source of immaterial icon set\n";
    print "  -v\tgenerate viewer icons\n";
    print "\n";
    print "  \t<SIZE> can be in the form of NN or NNxNN\n";
    print "\tnote: also used for the output filename\n";
    exit();
}


$size = $ARGV[0];


if ($do_viewers) {
    $output .= "_viewers";
    @list = @iconlist_viewers;
    print "creating $size-$output.icons ...\n";
    `cp icons_template $size-$output.icons`;
    print "completed\n\n";
}


if ($do_theme) {
    print "creating $size-$output.cfg ...\n";
    `cp theme_template $size-$output.cfg`;
    `sed -i -e s/PLACE_HOLDER/$size/g $size-$output.cfg`;
    print "completed\n\n";
}


my $alphatemp = File::Temp->new(SUFFIX => ".png");
my $alphatempfname = $alphatemp->filename();
my $exporttemp = File::Temp->new(SUFFIX => ".png");
my $exporttempfname = $exporttemp->filename();
my $tempstrip = File::Temp->new(SUFFIX => ".png");
my $tempstripfname = $tempstrip->filename();
my $newoutput = "$size-$output.bmp";


if(-e $newoutput) {
    die("warning: $newoutput already exists\n");
}


print "creating $newoutput ...\n";


my $count;
$count = 0;


foreach(@list) {
    print "processing $_ ...\n";
    my $file;
    if(m/^$/) {
        my $s = $size . "x" . $size;
        `convert -size $s xc:"#ff00ff" -alpha transparent $exporttempfname`
    }
    elsif(m/\./) {
        $file = $_ . ".svg";
        `inkscape --export-png=$exporttempfname --export-width=$size --export-height=$size $file`
    }
    else {
        if ($source eq "") {
            print "Path to tango sources needed but not given!\n";
            exit(1);
        }
        $file = "$source/scalable/" . $_ . ".svg";
        `cp $file source/`;
    }
    if($count != 0) {
        `convert -append $tempstripfname $exporttempfname $tempstripfname`;
    }
    else {
        `convert $exporttempfname $tempstripfname`;
    }
    $count++;
}


print "completed\n\n";


print "converting result ...\n";
`convert $tempstripfname $newoutput`;
print "completed\n";