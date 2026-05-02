package com.starwinde.routinemon.overlay

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

/**
 * System-wide overlay controller for T5.21 disturbance UI.
 *
 * Uses [WindowManager] with [WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY]
 * so the disturbance UI appears OVER any foreground app (YouTube, browsers,
 * etc.). Requires SYSTEM_ALERT_WINDOW; callers must verify via
 * [Settings.canDrawOverlays] before invoking show methods.
 *
 * Threading: all show/dismiss must be invoked on the main thread. The Pigeon
 * dispatch already runs on the main thread, so no additional posting is
 * needed for normal API calls.
 */
class DisturbanceOverlayController(private val context: Context) {

    private val windowManager: WindowManager
        get() = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    private val mainHandler = Handler(Looper.getMainLooper())

    private var currentView: View? = null
    private var dismissRunnable: Runnable? = null

    /** L1 — opaque black fullscreen for [durationMs] then auto-dismiss. */
    fun showBlack(durationMs: Long) {
        if (!Settings.canDrawOverlays(context)) return
        dismissInternal()
        val view = FrameLayout(context).apply {
            setBackgroundColor(Color.BLACK)
        }
        addView(view, fullscreenParams())
        scheduleAutoDismiss(durationMs)
    }

    /** L2 — small centered countdown overlay; auto-dismisses after [countdownSec]. */
    fun showBlockDialog(countdownSec: Int) {
        if (!Settings.canDrawOverlays(context)) return
        dismissInternal()
        val countdownView = TextView(context).apply {
            text = "일정 중이에요\n${countdownSec}초 후 홈으로 돌아갑니다."
            setBackgroundColor(0xCC000000.toInt())
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            gravity = Gravity.CENTER
            setPadding(72, 48, 72, 48)
            typeface = Typeface.DEFAULT_BOLD
        }
        val params = baseParams().apply {
            width = WindowManager.LayoutParams.WRAP_CONTENT
            height = WindowManager.LayoutParams.WRAP_CONTENT
            gravity = Gravity.CENTER
        }
        addView(countdownView, params)
        scheduleAutoDismiss(countdownSec * 1000L)
    }

    /** L3 — fullscreen block, persists until [dismiss]. */
    fun showBlockFullscreen() {
        if (!Settings.canDrawOverlays(context)) return
        dismissInternal()
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.BLACK)
            addView(
                TextView(context).apply {
                    text = "🔒"
                    setTextColor(Color.WHITE)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 48f)
                    gravity = Gravity.CENTER
                }
            )
            addView(
                TextView(context).apply {
                    text = "일정 종료까지 차단 중"
                    setTextColor(Color.WHITE)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
                    gravity = Gravity.CENTER
                    typeface = Typeface.DEFAULT_BOLD
                    setPadding(0, 24, 0, 8)
                }
            )
            addView(
                TextView(context).apply {
                    text = "집중을 위해 잠시 멈춰 주세요."
                    setTextColor(0xB3FFFFFF.toInt())
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                    gravity = Gravity.CENTER
                }
            )
        }
        addView(container, fullscreenParams())
        // No auto-dismiss; controller dismisses on schedule end.
    }

    /** Removes whichever overlay is currently shown, if any. */
    fun dismiss() {
        mainHandler.post { dismissInternal() }
    }

    private fun dismissInternal() {
        dismissRunnable?.let { mainHandler.removeCallbacks(it) }
        dismissRunnable = null
        val view = currentView ?: return
        currentView = null
        try {
            windowManager.removeView(view)
        } catch (_: IllegalArgumentException) {
            // View was already removed.
        } catch (_: SecurityException) {
            // Permission revoked between addView and removeView; ignore.
        }
    }

    private fun addView(view: View, params: WindowManager.LayoutParams) {
        try {
            windowManager.addView(view, params)
            currentView = view
        } catch (_: SecurityException) {
            // SAW revoked; fail silently.
        } catch (_: WindowManager.BadTokenException) {
            // Should not happen with TYPE_APPLICATION_OVERLAY but guard anyway.
        }
    }

    private fun scheduleAutoDismiss(delayMs: Long) {
        if (delayMs <= 0L) return
        val r = Runnable { dismissInternal() }
        dismissRunnable = r
        mainHandler.postDelayed(r, delayMs)
    }

    private fun fullscreenParams(): WindowManager.LayoutParams = baseParams().apply {
        width = WindowManager.LayoutParams.MATCH_PARENT
        height = WindowManager.LayoutParams.MATCH_PARENT
        gravity = Gravity.TOP or Gravity.START
        @Suppress("DEPRECATION")
        flags = flags or
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
    }

    private fun baseParams(): WindowManager.LayoutParams {
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        return WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
    }
}
