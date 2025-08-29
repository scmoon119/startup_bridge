package com.sindory.start_bridge.controller

import com.sindory.start_bridge.dto.LoginRequest
import com.sindory.start_bridge.dto.LoginResponse
import com.sindory.start_bridge.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val userService: UserService
) {

    @PostMapping("/login")
    fun login(@RequestBody request: LoginRequest): ResponseEntity<Map<String, Any>> {
        return try {
            val loginResponse = userService.login(request)
            val response = mapOf(
                "success" to true,
                "message" to "Login successful",
                "data" to loginResponse
            )
            ResponseEntity.ok(response)
        } catch (e: IllegalArgumentException) {
            val response = mapOf<String, Any>(
                "success" to false,
                "message" to (e.message ?: "Unknown error")
            )
            ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response)
        }
    }
}