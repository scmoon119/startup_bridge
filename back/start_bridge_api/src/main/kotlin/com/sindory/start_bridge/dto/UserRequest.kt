package com.sindory.start_bridge.dto

data class UserCreateRequest(
    val email: String,
    val password: String,
    val name: String
)

data class LoginRequest(
    val email: String,
    val password: String
)

data class LoginResponse(
    val token: String,
    val email: String,
    val name: String
)