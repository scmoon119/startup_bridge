package com.sindory.start_bridge.controller

import com.sindory.start_bridge.dto.UserCreateRequest
import com.sindory.start_bridge.entity.User
import com.sindory.start_bridge.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/users")
class UserController(
    private val userService: UserService
) {

    @PostMapping
    fun createUser(@RequestBody request: UserCreateRequest): ResponseEntity<Map<String, Any>> {
        return try {
            val user = userService.createUser(request)
            val response = mapOf(
                "success" to true,
                "message" to "User created successfully",
                "data" to mapOf(
                    "id" to user.id,
                    "email" to user.email,
                    "name" to user.name
                )
            )
            ResponseEntity.status(HttpStatus.CREATED).body(response)
        } catch (e: IllegalArgumentException) {
            val response = mapOf<String, Any>(
                "success" to false,
                "message" to (e.message ?: "Unknown error")
            )
            ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response)
        }
    }

    @GetMapping("/check-email")
    fun checkEmail(@RequestParam email: String): ResponseEntity<Map<String, Any>> {
        val exists = userService.checkEmailExists(email)
        val response = mapOf<String, Any>(
            "exists" to exists,
            "message" to if (exists) "Email already exists" else "Email is available"
        )
        return ResponseEntity.ok(response)
    }
}