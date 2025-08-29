package com.sindory.start_bridge.util

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.nio.charset.StandardCharsets
import java.util.*
import javax.crypto.SecretKey

@Component
class JwtUtil {

    @Value("\${jwt.secret}")
    private lateinit var secret: String

    @Value("\${jwt.expiration}")
    private var expiration: Long = 0

    private fun getSigningKey(): SecretKey {
        val keyBytes = secret.toByteArray(StandardCharsets.UTF_8)
        return Keys.hmacShaKeyFor(keyBytes)
    }

    fun generateToken(email: String): String {
        val now = Date()
        val expiryDate = Date(now.time + expiration)

        return Jwts.builder()
            .subject(email)
            .issuedAt(now)
            .expiration(expiryDate)
            .signWith(getSigningKey())
            .compact()
    }

    fun getEmailFromToken(token: String): String {
        val claims = getClaimsFromToken(token)
        return claims.subject
    }

    fun isTokenValid(token: String): Boolean {
        return try {
            val claims = getClaimsFromToken(token)
            !claims.expiration.before(Date())
        } catch (e: Exception) {
            false
        }
    }

    private fun getClaimsFromToken(token: String): Claims {
        return Jwts.parser()
            .verifyWith(getSigningKey())
            .build()
            .parseSignedClaims(token)
            .payload
    }
}