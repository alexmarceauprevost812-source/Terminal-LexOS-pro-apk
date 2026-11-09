package com.termux.app.terminal;

import java.util.List;

/**
 * LexOS Terminal — état d'une fenêtre divisée en deux (haut/bas).
 * Logique pure, sans Android : la même session n'est jamais affichée dans les deux volets.
 *
 * @param <T> type de session (TerminalSession dans l'app, String dans les tests)
 */
public final class LexosSplitModel<T> {

    private T active;   // session du volet qui a le clavier
    private T other;    // session de l'autre volet ; null = pas de division

    public LexosSplitModel(T active) { this.active = active; }

    public T active() { return active; }
    public T other() { return other; }
    public boolean isSplit() { return other != null; }

    /**
     * Active la division : l'autre volet prend la session qui suit l'active dans la liste (circulaire).
     * @return la session choisie, ou null s'il n'y a pas d'autre session (l'appelant doit alors en créer une).
     */
    public T split(List<T> all) {
        if (active == null || all == null) return null;
        final int i = all.indexOf(active);
        for (int k = 1; k < all.size(); k++) {
            final T c = all.get(((i < 0 ? -1 : i) + k + all.size()) % all.size());
            if (c != null && !c.equals(active)) { other = c; return c; }
        }
        return null;
    }

    /** Division avec une session précise (par ex. celle qu'on vient de créer). Refuse la même session. */
    public boolean splitWith(T s) {
        if (active == null || s == null || s.equals(active)) return false;
        other = s; return true;
    }

    public void unsplit() { other = null; }

    /**
     * Le volet actif affiche maintenant {@code s}. Si {@code s} était déjà dans l'autre volet, les volets
     * échangent leurs sessions (l'autre prend l'ancienne session active).
     * @return true si l'autre volet doit être rattaché à {@link #other()}.
     */
    public boolean setActive(T s) {
        if (s == null) return false;
        final T old = active;
        active = s;
        if (other != null && other.equals(s)) { other = old; return true; }
        return false;
    }

    /** L'utilisateur touche l'autre volet : les rôles s'échangent. */
    public boolean focusOther() {
        if (other == null) return false;
        final T t = active; active = other; other = t; return true;
    }

    /** Une session disparaît. @return true si la division a dû être fermée. */
    public boolean sessionRemoved(T s) {
        if (other == null || s == null) return false;
        if (s.equals(other) || s.equals(active)) { other = null; return true; }
        return false;
    }

    /** Ferme la division si l'autre session n'existe plus dans la liste vivante. @return true si fermée. */
    public boolean validate(List<T> alive) {
        if (other != null && (alive == null || !alive.contains(other))) { other = null; return true; }
        return false;
    }
}
