package com.termux.app;

import android.content.Context;
import android.util.Log;

import com.termux.shared.termux.TermuxConstants;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

/**
 * LexOS Pro — installation au premier démarrage.
 *
 * Ce fichier est AJOUTÉ à Termux par l'overlay LexOS. Il ne modifie pas le
 * moteur : au premier lancement (et après une mise à jour de la version LexOS),
 * il dépose dans le dossier personnel :
 *   - ~/bin/aide                 (assistant IA de commandes)
 *   - ~/.lexos/lexos.sh          (invite + alias, chargé par ~/.bashrc)
 *   - ~/.lexos/config            (modèle IA, seulement si absent)
 *   - ~/.termux/colors.properties (thème du terminal, seulement si absent)
 * puis s'assure que ~/.bashrc charge lexos.sh.
 *
 * Tout est encapsulé dans des try/catch : en cas de pépin, l'app démarre
 * normalement quand même.
 */
public final class LexosSetup {

    private static final String LOG_TAG = "LexosSetup";

    /** À incrémenter quand aide/lexos.sh/couleurs changent, pour forcer le redéploiement. */
    private static final int LEXOS_SETUP_VERSION = 36;

    private static final String HOME = TermuxConstants.TERMUX_HOME_DIR_PATH;

    private LexosSetup() {}

    public static void run(final Context context) {
        try {
            doSetup(context);
        } catch (Throwable t) {
            Log.e(LOG_TAG, "Échec de l'installation LexOS (ignoré) : " + t.getMessage(), t);
        }
    }

    private static void doSetup(final Context context) throws IOException {
        File lexosDir = new File(HOME, ".lexos");
        //noinspection ResultOfMethodCallIgnored
        lexosDir.mkdirs();

        File marker = new File(lexosDir, ".version");
        int installed = readVersion(marker);
        boolean fresh = installed < LEXOS_SETUP_VERSION;

        // Fichiers (re)déployés à chaque montée de version
        if (fresh) {
            File bin = new File(HOME, "bin");
            //noinspection ResultOfMethodCallIgnored
            bin.mkdirs();
            installExecutable(context, "lexos/aide", new File(bin, "aide"));
            installExecutable(context, "lexos/lexos-update", new File(bin, "lexos-update"));
            installExecutable(context, "lexos/lexos-couleurs", new File(bin, "lexos-couleurs"));
            installExecutable(context, "lexos/lexos-ia", new File(bin, "lexos-ia"));
            installExecutable(context, "lexos/lexos", new File(bin, "lexos"));
            installExecutable(context, "lexos/lexos-menu", new File(bin, "lexos-menu"));
            installExecutable(context, "lexos/lexos-kali", new File(bin, "lexos-kali"));
            installExecutable(context, "lexos/kali", new File(bin, "kali"));
            installExecutable(context, "lexos/catalogue", new File(bin, "catalogue"));
            installExecutable(context, "lexos/lexos-facile", new File(bin, "lexos-facile"));
            installExecutable(context, "lexos/lexos-partage", new File(bin, "lexos-partage"));
            installExecutable(context, "lexos/lexos-fichier", new File(bin, "lexos-fichier"));
            installExecutable(context, "lexos/lexos-bienvenue", new File(bin, "lexos-bienvenue"));
            installExecutable(context, "lexos/apprendre", new File(bin, "apprendre"));
            installExecutable(context, "lexos/lexos-info", new File(bin, "lexos-info"));
            installExecutable(context, "lexos/lexos-serveur", new File(bin, "lexos-serveur"));

            copyAsset(context, "lexos/lexos.sh", new File(lexosDir, "lexos.sh"));
            copyAsset(context, "lexos/explique.sh", new File(lexosDir, "explique.sh"));
            copyAsset(context, "lexos/explications.txt", new File(lexosDir, "explications.txt"));
            copyAsset(context, "lexos/banner.txt", new File(lexosDir, "banner.txt"));
            copyAsset(context, "lexos/banner.png", new File(lexosDir, "banner.png"));
            copyAsset(context, "lexos/avatar.png", new File(lexosDir, "avatar.png"));
            copyAsset(context, "lexos/menu-gauche.png", new File(lexosDir, "menu-gauche.png"));

            // Leçons de « apprendre »
            File leconsDir = new File(lexosDir, "lecons");
            //noinspection ResultOfMethodCallIgnored
            leconsDir.mkdirs();
            for (String lecon : new String[] {
                    "01-fichiers.txt", "02-paquets.txt", "03-reseau.txt",
                    "04-python.txt", "05-git.txt", "06-securite.txt" }) {
                copyAsset(context, "lexos/lecons/" + lecon, new File(leconsDir, lecon));
            }

            File termuxDir = new File(HOME, ".termux");
            //noinspection ResultOfMethodCallIgnored
            termuxDir.mkdirs();
            copyAsset(context, "lexos/colors.properties", new File(termuxDir, "colors.properties"));
        }

        // config : seulement si absent (ne pas écraser le modèle IA choisi)
        File config = new File(lexosDir, "config");
        if (!config.exists()) copyAsset(context, "lexos/config", config);

        ensureBashrcSourcesLexos();

        writeVersion(marker);
        Log.i(LOG_TAG, "Installation LexOS OK (version " + LEXOS_SETUP_VERSION + ").");
    }

    private static void ensureBashrcSourcesLexos() throws IOException {
        File bashrc = new File(HOME, ".bashrc");
        String sourceLine = "[ -f \"$HOME/.lexos/lexos.sh\" ] && . \"$HOME/.lexos/lexos.sh\"";
        String existing = "";
        if (bashrc.exists()) existing = readFile(bashrc);
        if (existing.contains(".lexos/lexos.sh")) return;

        String toAppend = (existing.isEmpty() || existing.endsWith("\n") ? "" : "\n")
            + "\n# LexOS Pro\n" + sourceLine + "\n";
        try (OutputStream os = new FileOutputStream(bashrc, true)) {
            os.write(toAppend.getBytes(StandardCharsets.UTF_8));
        }
    }

    private static void installExecutable(Context context, String assetPath, File dest) throws IOException {
        copyAsset(context, assetPath, dest);
        //noinspection ResultOfMethodCallIgnored
        dest.setExecutable(true, false);
    }

    private static void copyAsset(Context context, String assetPath, File dest) throws IOException {
        File parent = dest.getParentFile();
        if (parent != null) //noinspection ResultOfMethodCallIgnored
            parent.mkdirs();
        try (InputStream in = context.getAssets().open(assetPath);
             OutputStream out = new FileOutputStream(dest)) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
        }
    }

    private static int readVersion(File marker) {
        try {
            if (!marker.exists()) return 0;
            return Integer.parseInt(readFile(marker).trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private static void writeVersion(File marker) throws IOException {
        try (OutputStream os = new FileOutputStream(marker)) {
            os.write(String.valueOf(LEXOS_SETUP_VERSION).getBytes(StandardCharsets.UTF_8));
        }
    }

    private static String readFile(File f) throws IOException {
        try (InputStream in = new java.io.FileInputStream(f)) {
            java.io.ByteArrayOutputStream bos = new java.io.ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) != -1) bos.write(buf, 0, n);
            return new String(bos.toByteArray(), StandardCharsets.UTF_8);
        }
    }
}
