package com.termux.app.terminal;

/**
 * LexOS Terminal — décision du balayage à deux doigts entre sessions.
 * Logique pure (sans Android) pour être testable avec JUnit.
 */
public final class LexosSwipe {

    private LexosSwipe() {}

    public static final int NONE = 0;
    /** Balayage vers la gauche : session suivante. */
    public static final int NEXT = 1;
    /** Balayage vers la droite : session précédente. */
    public static final int PREVIOUS = -1;

    /**
     * @param dx déplacement horizontal du centre des deux doigts (px, positif = vers la droite)
     * @param dy déplacement vertical (px)
     * @param minDistancePx distance minimale pour compter comme un balayage
     * Le geste doit être nettement horizontal (|dx| > 2 x |dy|) pour ne pas gêner le défilement vertical.
     */
    public static int decide(float dx, float dy, float minDistancePx) {
        if (Math.abs(dx) < minDistancePx) return NONE;
        if (Math.abs(dx) <= 2f * Math.abs(dy)) return NONE;
        return dx < 0 ? NEXT : PREVIOUS;
    }
}
