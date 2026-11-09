package com.termux.app.terminal;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

import com.termux.terminal.TerminalColorScheme;
import com.termux.terminal.TextStyle;

import org.junit.Test;

import java.util.Properties;

/** Vérifie les couleurs LexOS par défaut : validité, orange gardé, et contraste WCAG calculé. */
public class LexosThemeTest {

    /** #rrggbb -> 0xAARRGGBB ; 0 si invalide. */
    private static int parse(String hex) {
        if (hex == null || !hex.matches("#[0-9a-fA-F]{6}")) return 0;
        return 0xff000000 | Integer.parseInt(hex.substring(1), 16);
    }

    /** Luminance relative WCAG 2.x d'une couleur #rrggbb. */
    private static double luminance(String hex) {
        final int c = parse(hex);
        final double[] ch = {((c >> 16) & 0xff) / 255.0, ((c >> 8) & 0xff) / 255.0, (c & 0xff) / 255.0};
        for (int i = 0; i < 3; i++) ch[i] = ch[i] <= 0.03928 ? ch[i] / 12.92 : Math.pow((ch[i] + 0.055) / 1.055, 2.4);
        return 0.2126 * ch[0] + 0.7152 * ch[1] + 0.0722 * ch[2];
    }

    private static double contrast(String a, String b) {
        final double la = luminance(a), lb = luminance(b);
        return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
    }

    @Test
    public void night_isPureBlackWhiteAndNeonOrange() {
        final Properties p = LexosTheme.defaultColors(true);
        assertEquals("#000000", p.getProperty("background"));
        assertEquals("#ffffff", p.getProperty("foreground"));
        assertEquals("#ff6a1a", p.getProperty("cursor"));
        assertFalse("la nuit garde la palette ANSI de Termux", p.containsKey("color0"));
    }

    @Test
    public void day_hasLightBackgroundAndFullAnsiPalette() {
        final Properties p = LexosTheme.defaultColors(false);
        assertEquals("#ffffff", p.getProperty("background"));
        for (int i = 0; i < 16; i++) assertTrue("color" + i + " manquante", p.containsKey("color" + i));
        assertEquals(16, LexosTheme.DAY_ANSI.length);
    }

    @Test
    public void orangeIsKeptInBothThemes() {
        // « orange gardé dans les deux » : le curseur est orange (rouge fort, vert moyen, bleu faible).
        for (boolean night : new boolean[] {true, false}) {
            final int c = parse(LexosTheme.defaultColors(night).getProperty("cursor"));
            final int r = (c >> 16) & 0xff, g = (c >> 8) & 0xff, b = c & 0xff;
            assertTrue("rouge dominant (night=" + night + ")", r > 180 && r > g && g > b);
            assertTrue("vert moyen, bleu faible (night=" + night + ")", g > 40 && b < 60);
        }
    }

    @Test
    public void allColorsParse() {
        for (boolean night : new boolean[] {true, false}) {
            for (String key : LexosTheme.defaultColors(night).stringPropertyNames()) {
                final String v = LexosTheme.defaultColors(night).getProperty(key);
                assertNotEquals("couleur invalide " + key + "=" + v, 0, parse(v));
            }
        }
    }

    @Test
    public void night_contrastIsReadable() {
        assertTrue(contrast(LexosTheme.NIGHT_FOREGROUND, LexosTheme.NIGHT_BACKGROUND) >= 4.5);
        assertTrue("curseur visible", contrast(LexosTheme.NIGHT_CURSOR, LexosTheme.NIGHT_BACKGROUND) >= 3.0);
    }

    @Test
    public void day_everyTextColorMeetsWcagAA() {
        final String bg = LexosTheme.DAY_BACKGROUND;
        assertTrue("texte principal", contrast(LexosTheme.DAY_FOREGROUND, bg) >= 4.5);
        assertTrue("curseur orange visible sur blanc", contrast(LexosTheme.DAY_CURSOR, bg) >= 3.0);
        for (int i = 0; i < LexosTheme.DAY_ANSI.length; i++) {
            assertTrue("color" + i + " " + LexosTheme.DAY_ANSI[i] + " contraste "
                + contrast(LexosTheme.DAY_ANSI[i], bg), contrast(LexosTheme.DAY_ANSI[i], bg) >= 4.5);
        }
        // Le néon, lui, NE convient PAS au jour : c'est la raison de l'orange plus foncé.
        assertTrue(contrast(LexosTheme.NIGHT_CURSOR, bg) < 3.0);
    }

    @Test
    public void appliedToRealColorScheme_setsExpectedValues() {
        final TerminalColorScheme night = new TerminalColorScheme();
        night.updateWith(LexosTheme.defaultColors(true));
        assertEquals(0xffff6a1a, night.mDefaultColors[TextStyle.COLOR_INDEX_CURSOR]);
        assertEquals(0xff000000, night.mDefaultColors[TextStyle.COLOR_INDEX_BACKGROUND]);
        assertEquals(0xffffffff, night.mDefaultColors[TextStyle.COLOR_INDEX_FOREGROUND]);

        final TerminalColorScheme day = new TerminalColorScheme();
        day.updateWith(LexosTheme.defaultColors(false));
        assertEquals(0xffc2410c, day.mDefaultColors[TextStyle.COLOR_INDEX_CURSOR]);
        assertEquals(0xffffffff, day.mDefaultColors[TextStyle.COLOR_INDEX_BACKGROUND]);
        assertEquals(0xff111111, day.mDefaultColors[TextStyle.COLOR_INDEX_FOREGROUND]);
        assertEquals(0xffc62828, day.mDefaultColors[1]);
    }
}
