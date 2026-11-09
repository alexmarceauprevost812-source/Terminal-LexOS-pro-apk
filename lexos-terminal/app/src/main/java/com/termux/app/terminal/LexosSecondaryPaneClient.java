package com.termux.app.terminal;

import android.view.KeyEvent;
import android.view.MotionEvent;

import com.termux.app.TermuxActivity;
import com.termux.shared.logger.Logger;
import com.termux.terminal.TerminalSession;
import com.termux.view.TerminalViewClient;

/**
 * LexOS — client du volet qui n'a PAS le focus. Il ne fait presque rien : un toucher donne le focus à ce volet
 * (les rôles s'échangent, voir {@link TermuxActivity#lexosFocusOtherPane()}). La saisie clavier n'arrive ici
 * qu'après ce changement, quand le volet a repris le client complet de Termux.
 */
public final class LexosSecondaryPaneClient implements TerminalViewClient {

    private final TermuxActivity mActivity;

    public LexosSecondaryPaneClient(TermuxActivity activity) { mActivity = activity; }

    @Override public float onScale(float scale) { return 1.0f; }
    @Override public void onSingleTapUp(MotionEvent e) { mActivity.lexosFocusOtherPane(); }
    @Override public boolean shouldBackButtonBeMappedToEscape() { return false; }
    @Override public boolean shouldEnforceCharBasedInput() { return false; }
    @Override public boolean shouldUseCtrlSpaceWorkaround() { return false; }
    @Override public boolean isTerminalViewSelected() { return false; }
    @Override public void copyModeChanged(boolean copyMode) {}
    @Override public boolean onKeyDown(int keyCode, KeyEvent e, TerminalSession session) { return false; }
    @Override public boolean onKeyUp(int keyCode, KeyEvent e) { return false; }
    @Override public boolean onLongPress(MotionEvent event) { mActivity.lexosFocusOtherPane(); return true; }
    @Override public boolean readControlKey() { return false; }
    @Override public boolean readAltKey() { return false; }
    @Override public boolean readShiftKey() { return false; }
    @Override public boolean readFnKey() { return false; }
    @Override public boolean onCodePoint(int codePoint, boolean ctrlDown, TerminalSession session) { return false; }
    @Override public void onEmulatorSet() {}
    @Override public void logError(String tag, String message) { Logger.logError(tag, message); }
    @Override public void logWarn(String tag, String message) { Logger.logWarn(tag, message); }
    @Override public void logInfo(String tag, String message) { Logger.logInfo(tag, message); }
    @Override public void logDebug(String tag, String message) { Logger.logDebug(tag, message); }
    @Override public void logVerbose(String tag, String message) { Logger.logVerbose(tag, message); }
    @Override public void logStackTraceWithMessage(String tag, String message, Exception e) { Logger.logStackTraceWithMessage(tag, message, e); }
    @Override public void logStackTrace(String tag, Exception e) { Logger.logStackTrace(tag, e); }
}
