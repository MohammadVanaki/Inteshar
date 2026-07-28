package com.dijlah.inteshar.security

import android.content.Context
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import java.util.UUID

class PlayIntegrityManager(private val context: Context) {

    interface IntegrityCallback {
        fun onSuccess(token: String)
        fun onError(errorMessage: String)
    }

    /**
     * Requests a Play Integrity Token from Google Play Services with a nonce.
     */
    fun requestIntegrityToken(nonceStr: String?, callback: IntegrityCallback) {
        try {
            val integrityManager = IntegrityManagerFactory.create(context)
            val nonce = nonceStr ?: UUID.randomUUID().toString()

            val request = IntegrityTokenRequest.builder()
                .setNonce(nonce)
                .build()

            integrityManager.requestIntegrityToken(request)
                .addOnSuccessListener { response: IntegrityTokenResponse ->
                    val token = response.token()
                    callback.onSuccess(token)
                }
                .addOnFailureListener { exception: Exception ->
                    callback.onError(exception.message ?: "Play Integrity API Request Failed")
                }
        } catch (e: Exception) {
            callback.onError(e.message ?: "Play Integrity Initialization Failed")
        }
    }
}
