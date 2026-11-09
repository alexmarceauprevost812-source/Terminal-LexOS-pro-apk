package com.termux.app.terminal;

import java.util.Properties;

/**
 * LexOS Terminal — couleurs par défaut du terminal.
 *
 * <ul>
 *   <li><b>Nuit</b> : fond noir pur, texte blanc, curseur orange néon. La palette ANSI de Termux est
 *       conservée (déjà lisible sur noir).</li>
 *   <li><b>Jour</b> : fond blanc, texte presque noir, et une palette ANSI complète choisie pour rester
 *       lisible sur blanc (contraste WCAG &gt;= 4,5 pour le texte, vérifié par LexosThemeTest). L'orange
 *       est gardé, mais plus foncé : le néon #FF6A1A n'a que 2,87 de contraste sur blanc.</li>
 * </ul>
 *
 * Ces couleurs ne servent que si l'utilisateur n'a PAS de {@code ~/.termux/colors.properties} :
 * son fichier gagne toujours. Classe volontairement sans dépendance Android (testable avec JUnit).
 */
public final class LexosTheme {

    private LexosTheme() {}

    public static final String NIGHT_BACKGROUND = "#000000";
    public static final String NIGHT_FOREGROUND = "#ffffff";
    /** Orange néon (même valeur que le curseur du terminal LexOS). */
    public static final String NIGHT_CURSOR = "#ff6a1a";

    public static final String DAY_BACKGROUND = "#ffffff";
    public static final String DAY_FOREGROUND = "#111111";
    /** Orange de jour : plus foncé que le néon pour rester visible sur blanc. */
    public static final String DAY_CURSOR = "#c2410c";

    /** Palette ANSI (color0..color15) du thème de jour. */
    public static final String[] DAY_ANSI = {
        "#000000", "#c62828", "#2e7d32", "#8a5200", "#1565c0", "#8e24aa", "#00697a", "#4d4d4d",
        "#595959", "#d32f2f", "#1b7f3a", "#b34700", "#0d5fbf", "#9c27b0", "#00778b", "#000000",
    };

    /**
     * Propriétés au format de {@code colors.properties}, à passer à
     * {@code TerminalColorScheme.updateWith()}.
     */
    public static Properties defaultColors(boolean night) {
        final Properties p = new Properties();
        if (night) {
            p.setProperty("background", NIGHT_BACKGROUND);
            p.setProperty("foreground", NIGHT_FOREGROUND);
            p.setProperty("cursor", NIGHT_CURSOR);
        } else {
            p.setProperty("background", DAY_BACKGROUND);
            p.setProperty("foreground", DAY_FOREGROUND);
            p.setProperty("cursor", DAY_CURSOR);
            for (int i = 0; i < DAY_ANSI.length; i++) p.setProperty("color" + i, DAY_ANSI[i]);
        }
        return p;
    }
}
