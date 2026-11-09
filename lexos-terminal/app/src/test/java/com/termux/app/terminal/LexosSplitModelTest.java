package com.termux.app.terminal;

import static org.junit.Assert.*;

import org.junit.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class LexosSplitModelTest {
    private static final List<String> ABC = Arrays.asList("a", "b", "c");

    @Test public void startsNotSplit() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a");
        assertFalse(m.isSplit()); assertNull(m.other());
    }
    @Test public void splitPicksNextCyclic() {
        LexosSplitModel<String> m = new LexosSplitModel<>("c");
        assertEquals("a", m.split(ABC)); assertTrue(m.isSplit());
        m = new LexosSplitModel<>("a");
        assertEquals("b", m.split(ABC));
    }
    @Test public void splitWithSingleSessionNeedsANewOne() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a");
        assertNull(m.split(Collections.singletonList("a"))); assertFalse(m.isSplit());
        assertTrue(m.splitWith("z")); assertEquals("z", m.other());
    }
    @Test public void splitWithSameSessionRefused() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a");
        assertFalse(m.splitWith("a")); assertFalse(m.isSplit());
    }
    @Test public void neverSameSessionInBothPanes() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a"); m.split(ABC);   // other = b
        assertTrue(m.setActive("b"));            // on bascule vers la session de l'autre volet
        assertEquals("b", m.active()); assertEquals("a", m.other());
    }
    @Test public void switchToUnrelatedSessionKeepsOther() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a"); m.split(ABC);   // other = b
        assertFalse(m.setActive("c"));
        assertEquals("c", m.active()); assertEquals("b", m.other());
    }
    @Test public void focusOtherSwapsRoles() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a"); m.split(ABC);
        assertTrue(m.focusOther());
        assertEquals("b", m.active()); assertEquals("a", m.other());
    }
    @Test public void focusOtherWithoutSplitDoesNothing() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a");
        assertFalse(m.focusOther()); assertEquals("a", m.active());
    }
    @Test public void removingEitherSessionClosesSplit() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a"); m.split(ABC);
        assertTrue(m.sessionRemoved("b")); assertFalse(m.isSplit());
        m = new LexosSplitModel<>("a"); m.split(ABC);
        assertTrue(m.sessionRemoved("a")); assertFalse(m.isSplit());
    }
    @Test public void removingThirdSessionKeepsSplit() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a"); m.split(ABC);
        assertFalse(m.sessionRemoved("c")); assertTrue(m.isSplit());
    }
    @Test public void validateClosesWhenOtherIsGone() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a"); m.split(ABC);
        assertFalse(m.validate(ABC)); assertTrue(m.isSplit());
        assertTrue(m.validate(Arrays.asList("a", "c"))); assertFalse(m.isSplit());
    }
    @Test public void setActiveNullIgnored() {
        LexosSplitModel<String> m = new LexosSplitModel<>("a");
        assertFalse(m.setActive(null)); assertEquals("a", m.active());
    }
}
