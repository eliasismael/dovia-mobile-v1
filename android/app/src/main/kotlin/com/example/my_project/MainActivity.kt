package com.mycompany.dovia

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createPushChannel()
    }

    /**
     * Canal de los push de FCM (default_notification_channel_id en el
     * manifest). Con importancia alta Android los muestra como cartel
     * emergente; el canal por defecto de FCM sólo deja el ícono en la barra.
     * Tiene que existir antes del primer push: se crea al abrir la app.
     */
    private fun createPushChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            getString(R.string.push_channel_id),
            getString(R.string.push_channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        )
        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }
}
