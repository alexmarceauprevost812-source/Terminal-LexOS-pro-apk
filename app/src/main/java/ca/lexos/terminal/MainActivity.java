package ca.lexos.terminal;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.termux.terminal.TerminalSession;
import com.termux.terminal.TerminalSessionClient;
import com.termux.view.TerminalView;
import com.termux.view.TerminalViewClient;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.nio.charset.StandardCharsets;

public final class MainActivity extends Activity {
    // Un processus Android local, distinct du gestionnaire de paquets Termux.
    private static final String SHELL = "/system/bin/sh";
    private static final int BG = Color.rgb(8, 16, 28);
    private static final int PANEL = Color.rgb(18, 35, 58);
    private static final int ACCENT = Color.rgb(41, 186, 255);
    private static final int WHITE = Color.rgb(237, 247, 255);
    private static final int MUTED = Color.rgb(155, 183, 205);

    private TerminalView terminalView;
    private TerminalSession session;
    private TextView status;
    private EditText composer;

    private int dp(int n) {
        return (int) (getResources().getDisplayMetrics().density * n + 0.5f);
    }

    private GradientDrawable surface(int fill, int stroke, int corner) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(fill);
        d.setCornerRadius(dp(corner));
        if (stroke != 0) d.setStroke(dp(1), stroke);
        return d;
    }

    private Button action(String title, Runnable action) {
        Button button = new Button(this);
        button.setText(title);
        button.setAllCaps(false);
        button.setTextSize(12);
        button.setTextColor(WHITE);
        button.setBackground(surface(PANEL, 0, 10));
        button.setPadding(dp(9), 0, dp(9), 0);
        button.setMinHeight(dp(42));
        button.setMinimumHeight(dp(42));
        button.setOnClickListener(v -> action.run());
        return button;
    }

    private void addKey(LinearLayout row, String title, Runnable command) {
        Button button = action(title, command);
        LinearLayout.LayoutParams p =
            new LinearLayout.LayoutParams(-2, dp(42));
        p.setMargins(0, 0, dp(5), 0);
        row.addView(button, p);
    }

    @Override
    public void onCreate(Bundle savedState) {
        super.onCreate(savedState);
        getWindow().setStatusBarColor(BG);
        getWindow().setNavigationBarColor(BG);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(BG);
        root.setFitsSystemWindows(true);
        root.setPadding(dp(8), dp(8), dp(8), dp(6));

        LinearLayout heading = new LinearLayout(this);
        heading.setOrientation(LinearLayout.VERTICAL);
        heading.setPadding(dp(8), dp(6), dp(8), dp(7));
        TextView brand = new TextView(this);
        brand.setText("⚜  LEXOS TERMINAL");
        brand.setTextColor(ACCENT);
        brand.setTextSize(19);
        brand.setTypeface(Typeface.MONOSPACE, Typeface.BOLD);
        heading.addView(brand);
        status = new TextView(this);
        status.setText("Android local  •  /system/bin/sh");
        status.setTextColor(MUTED);
        status.setTextSize(12);
        heading.addView(status);
        root.addView(heading);

        HorizontalScrollView keyScroller = new HorizontalScrollView(this);
        keyScroller.setHorizontalScrollBarEnabled(false);
        LinearLayout keys = new LinearLayout(this);
        keys.setOrientation(LinearLayout.HORIZONTAL);
        keys.setPadding(dp(2), dp(2), dp(2), dp(6));
        addKey(keys, "Nouveau", this::newSession);
        addKey(keys, "Ctrl+C", () -> write("\u0003"));
        addKey(keys, "Tab", () -> write("\t"));
        addKey(keys, "Échap", () -> write("\u001b"));
        addKey(keys, "↑", () -> write("\u001b[A"));
        addKey(keys, "↓", () -> write("\u001b[B"));
        addKey(keys, "Copier", this::copySelection);
        addKey(keys, "Coller", this::pasteClipboard);
        keyScroller.addView(keys);
        root.addView(keyScroller);

        terminalView = new TerminalView(this, null);
        terminalView.setBackgroundColor(BG);
        terminalView.setFocusableInTouchMode(true);
        terminalView.setTerminalViewClient(viewCallbacks());
        terminalView.setTextSize(dp(15));
        root.addView(terminalView, new LinearLayout.LayoutParams(
            -1, 0, 1f));

        LinearLayout editor = new LinearLayout(this);
        editor.setOrientation(LinearLayout.HORIZONTAL);
        editor.setGravity(Gravity.CENTER_VERTICAL);
        editor.setPadding(dp(5), dp(6), dp(5), dp(3));
        editor.setBackground(surface(PANEL, 0, 12));

        composer = new EditText(this);
        composer.setSingleLine(true);
        composer.setTextSize(15);
        composer.setTextColor(WHITE);
        composer.setHintTextColor(MUTED);
        composer.setHint("Écrire une commande…");
        composer.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        composer.setImeOptions(EditorInfo.IME_ACTION_SEND);
        composer.setBackgroundColor(Color.TRANSPARENT);
        composer.setPadding(dp(9), dp(7), dp(5), dp(7));
        composer.setOnEditorActionListener((v, actionId, event) -> {
            sendComposer();
            return true;
        });
        editor.addView(composer, new LinearLayout.LayoutParams(0, -2, 1f));
        Button send = action("ENVOYER ↵", this::sendComposer);
        send.setBackground(surface(ACCENT, 0, 8));
        send.setTextColor(BG);
        editor.addView(send, new LinearLayout.LayoutParams(-2, dp(46)));
        root.addView(editor, new LinearLayout.LayoutParams(-1, -2));
        setContentView(root);

        // Le clavier n'ecrase pas le champ du bas, et le terminal reste scrollable.
        newSession();
    }

    // Utiliser les interfaces OFFICIELLES du moteur Termux sans copier leur code.
    // Un adaptateur dynamique permet d'utiliser les callbacks de deux modules.
    private TerminalSessionClient sessionCallbacks() {
        return (TerminalSessionClient) Proxy.newProxyInstance(
            TerminalSessionClient.class.getClassLoader(),
            new Class<?>[]{TerminalSessionClient.class},
            (proxy, method, args) -> {
                switch (method.getName()) {
                    case "onTextChanged":
                        terminalView.post(() -> terminalView.onScreenUpdated());
                        break;
                    case "onColorsChanged":
                        terminalView.post(() -> terminalView.invalidate());
                        break;
                    case "onSessionFinished":
                        TerminalSession closed = args == null ? null : (TerminalSession) args[0];
                        if (closed == session) {
                            status.post(() -> status.setText(
                                "Session terminée • appuie sur Nouveau"));
                        }
                        break;
                    case "onCopyTextToClipboard":
                        if (args != null && args.length > 1 && args[1] instanceof String) {
                            copyText((String) args[1]);
                        }
                        break;
                    case "onPasteTextFromClipboard":
                        pasteClipboard();
                        break;
                    default:
                        break;
                }
                return defaultReturn(method);
            });
    }

    private TerminalViewClient viewCallbacks() {
        return (TerminalViewClient) Proxy.newProxyInstance(
            TerminalViewClient.class.getClassLoader(),
            new Class<?>[]{TerminalViewClient.class},
            (proxy, method, args) -> {
                switch (method.getName()) {
                    case "onScale":
                        return args != null && args.length > 0 ? args[0] : 1f;
                    case "isTerminalViewSelected":
                        return terminalView != null && terminalView.hasFocus();
                    case "shouldEnforceCharBasedInput":
                        return true; // Clavier Samsung
                    case "onSingleTapUp":
                        terminalView.requestFocus();
                        showKeyboard();
                        return null;
                    case "onEmulatorSet":
                        terminalView.post(() -> terminalView.onScreenUpdated());
                        return null;
                    default:
                        return defaultReturn(method);
                }
            });
    }

    private Object defaultReturn(Method method) {
        Class<?> type = method.getReturnType();
        if (type == boolean.class) return false;
        if (type == float.class) return 1f;
        if (type == int.class) return 0;
        if (type == long.class) return 0L;
        return null;
    }

    private void showKeyboard() {
        InputMethodManager imm =
            (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) imm.showSoftInput(terminalView, InputMethodManager.SHOW_IMPLICIT);
    }

    private void newSession() {
        if (session != null) session.finishIfRunning();
        try {
            String home = getFilesDir().getAbsolutePath();
            String[] env = {
                "HOME=" + home,
                "PWD=" + home,
                "TMPDIR=" + getCacheDir().getAbsolutePath(),
                "PATH=/system/bin:/system/xbin",
                "TERM=xterm-256color",
                "LANG=C.UTF-8"
            };
            session = new TerminalSession(SHELL, home,
                new String[]{SHELL, "-i"}, env, 2000, sessionCallbacks());
            terminalView.attachSession(session);
            terminalView.post(() -> terminalView.updateSize());
            status.setText("● Shell Android local • connecté");
        } catch (RuntimeException | LinkageError error) {
            status.setText("Erreur terminal : " + error.getClass().getSimpleName());
            Toast.makeText(this, "Impossible de démarrer le shell local.",
                Toast.LENGTH_LONG).show();
        }
    }

    private void write(String text) {
        if (session == null) return;
        byte[] bytes = text.getBytes(StandardCharsets.UTF_8);
        session.write(bytes, 0, bytes.length);
    }

    private void sendComposer() {
        String text = composer.getText().toString();
        write(text + "\n");
        composer.setText("");
        composer.requestFocus();
    }

    private void copyText(String text) {
        ClipboardManager clipboard =
            (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (clipboard != null) {
            clipboard.setPrimaryClip(ClipData.newPlainText("LexOS Terminal", text));
        }
    }

    private void copySelection() {
        String selected = terminalView.getSelectedText();
        if (selected == null || selected.isEmpty()) {
            Toast.makeText(this, "Sélectionne du texte dans le terminal.",
                Toast.LENGTH_SHORT).show();
            return;
        }
        copyText(selected);
    }

    private void pasteClipboard() {
        ClipboardManager clipboard =
            (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (clipboard != null && clipboard.hasPrimaryClip()) {
            ClipData clip = clipboard.getPrimaryClip();
            if (clip != null && clip.getItemCount() > 0) {
                CharSequence text = clip.getItemAt(0).coerceToText(this);
                if (text != null) write(text.toString());
            }
        }
    }

    @Override
    protected void onDestroy() {
        if (session != null && isFinishing()) session.finishIfRunning();
        super.onDestroy();
    }
}
