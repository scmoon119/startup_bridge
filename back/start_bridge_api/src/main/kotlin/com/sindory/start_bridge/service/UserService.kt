package com.sindory.start_bridge.service

import com.sindory.start_bridge.dto.LoginRequest
import com.sindory.start_bridge.dto.LoginResponse
import com.sindory.start_bridge.dto.UserCreateRequest
import com.sindory.start_bridge.entity.User
import com.sindory.start_bridge.repository.UserRepository
import com.sindory.start_bridge.util.JwtUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtUtil: JwtUtil
) {

    fun createUser(request: UserCreateRequest): User {
        if (userRepository.existsByEmail(request.email)) {
            throw IllegalArgumentException("Email already exists")
        }

        val encodedPassword = passwordEncoder.encode(request.password)
        val user = User(
            email = request.email,
            password = encodedPassword,
            name = request.name
        )

        return userRepository.save(user)
    }

    fun login(request: LoginRequest): LoginResponse {
        val user = userRepository.findByEmail(request.email)
            .orElseThrow { IllegalArgumentException("Invalid email or password") }

        if (!passwordEncoder.matches(request.password, user.password)) {
            throw IllegalArgumentException("Invalid email or password")
        }

        val token = jwtUtil.generateToken(user.email)
        return LoginResponse(
            token = token,
            email = user.email,
            name = user.name
        )
    }

    fun checkEmailExists(email: String): Boolean {
        return userRepository.existsByEmail(email)
    }
}