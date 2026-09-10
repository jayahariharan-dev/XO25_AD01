package com.example.shoulder_shield

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.ImageFormat
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.media.ImageReader
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions

class CameraMonitoringService : Service() {

    companion object {
        private const val TAG = "LOOKOUT_NATIVE"
        private const val CHANNEL_ID = "lookout_monitoring"
        private const val NOTIFICATION_ID = 1001
    }

    private lateinit var cameraManager: CameraManager

    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader? = null

    private lateinit var cameraThread: HandlerThread
    private lateinit var cameraHandler: Handler

    private val detector by lazy {
        val options = FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
            .enableTracking()
            .build()

        FaceDetection.getClient(options)
    }

    override fun onCreate() {
        super.onCreate()

        Log.d(TAG, "Service created")

        createNotificationChannel()

        val notification = createNotification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        cameraThread = HandlerThread("LookOutCameraThread")
        cameraThread.start()
        cameraHandler = Handler(cameraThread.looper)

        startCamera()
    }

    private fun startCamera() {

        if (checkSelfPermission(Manifest.permission.CAMERA)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "Camera permission not granted")
            stopSelf()
            return
        }

        cameraManager =
            getSystemService(Context.CAMERA_SERVICE) as CameraManager

        try {

            var frontCameraId: String? = null

            for (cameraId in cameraManager.cameraIdList) {

                val characteristics =
                    cameraManager.getCameraCharacteristics(cameraId)

                val facing =
                    characteristics.get(CameraCharacteristics.LENS_FACING)

                if (facing == CameraCharacteristics.LENS_FACING_FRONT) {
                    frontCameraId = cameraId
                    break
                }
            }

            if (frontCameraId == null) {
                Log.e(TAG, "Front camera not found")
                return
            }

            imageReader = ImageReader.newInstance(
                640,
                480,
                ImageFormat.YUV_420_888,
                2
            )

            imageReader!!.setOnImageAvailableListener(
                { reader ->
                    processImage(reader)
                },
                cameraHandler
            )

            cameraManager.openCamera(
                frontCameraId,
                object : CameraDevice.StateCallback() {

                    override fun onOpened(camera: CameraDevice) {

                        Log.d(TAG, "Background camera opened")

                        cameraDevice = camera

                        createCaptureSession()
                    }

                    override fun onDisconnected(camera: CameraDevice) {

                        Log.d(TAG, "Camera disconnected")

                        camera.close()
                        cameraDevice = null
                    }

                    override fun onError(
                        camera: CameraDevice,
                        error: Int
                    ) {

                        Log.e(TAG, "Camera error: $error")

                        camera.close()
                        cameraDevice = null
                    }
                },
                cameraHandler
            )

        } catch (e: Exception) {
            Log.e(TAG, "Camera start error", e)
        }
    }

    private fun createCaptureSession() {

        val camera = cameraDevice ?: return
        val surface = imageReader?.surface ?: return

        try {

            camera.createCaptureSession(
                listOf(surface),
                object : CameraCaptureSession.StateCallback() {

                    override fun onConfigured(
                        session: CameraCaptureSession
                    ) {

                        captureSession = session

                        try {

                            val request =
                                camera.createCaptureRequest(
                                    CameraDevice.TEMPLATE_PREVIEW
                                )

                            request.addTarget(surface)

                            session.setRepeatingRequest(
                                request.build(),
                                null,
                                cameraHandler
                            )

                            Log.d(
                                TAG,
                                "Background camera monitoring started"
                            )

                        } catch (e: Exception) {
                            Log.e(TAG, "Capture request error", e)
                        }
                    }

                    override fun onConfigureFailed(
                        session: CameraCaptureSession
                    ) {
                        Log.e(TAG, "Camera capture configuration failed")
                    }
                },
                cameraHandler
            )

        } catch (e: Exception) {
            Log.e(TAG, "Capture session error", e)
        }
    }

    private fun processImage(reader: ImageReader) {

        val image = reader.acquireLatestImage() ?: return

        try {

            val inputImage = InputImage.fromMediaImage(
                image,
                270
            )

            detector.process(inputImage)
                .addOnSuccessListener { faces ->

                    Log.d(
                        TAG,
                        "BACKGROUND: Faces detected = ${faces.size}"
                    )

                    if (faces.size >= 2) {

                        Log.d(
                            TAG,
                            "BACKGROUND: PRIVACY THREAT DETECTED"
                        )

                        // Later:
                        // Trigger the privacy overlay here.
                    }
                }
                .addOnFailureListener { e ->

                    Log.e(
                        TAG,
                        "Background face detection error",
                        e
                    )
                }
                .addOnCompleteListener {

                    image.close()
                }

        } catch (e: Exception) {

            image.close()

            Log.e(
                TAG,
                "Image processing error",
                e
            )
        }
    }

    private fun createNotificationChannel() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                CHANNEL_ID,
                "LookOut Monitoring",
                NotificationManager.IMPORTANCE_LOW
            )

            channel.description =
                "LookOut privacy monitoring"

            val manager =
                getSystemService(NotificationManager::class.java)

            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {

        return NotificationCompat.Builder(
            this,
            CHANNEL_ID
        )
            .setContentTitle("LookOut is monitoring")
            .setContentText("Privacy protection is active")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {

        Log.d(TAG, "Monitoring service stopped")

        try {
            captureSession?.close()
            cameraDevice?.close()
            imageReader?.close()
            detector.close()
            cameraThread.quitSafely()
        } catch (e: Exception) {
            Log.e(TAG, "Service cleanup error", e)
        }

        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}