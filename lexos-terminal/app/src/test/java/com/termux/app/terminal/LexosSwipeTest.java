package com.termux.app.terminal;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class LexosSwipeTest {
    @Test public void leftIsNext() { assertEquals(LexosSwipe.NEXT, LexosSwipe.decide(-300, 20, 150)); }
    @Test public void rightIsPrevious() { assertEquals(LexosSwipe.PREVIOUS, LexosSwipe.decide(300, -20, 150)); }
    @Test public void tooShortIsIgnored() { assertEquals(LexosSwipe.NONE, LexosSwipe.decide(-100, 0, 150)); }
    @Test public void verticalScrollIsIgnored() { assertEquals(LexosSwipe.NONE, LexosSwipe.decide(-200, 180, 150)); }
    @Test public void diagonalIsIgnored() { assertEquals(LexosSwipe.NONE, LexosSwipe.decide(200, 120, 150)); }
    @Test public void exactlyTwiceIsIgnored() { assertEquals(LexosSwipe.NONE, LexosSwipe.decide(200, 100, 150)); }
}
