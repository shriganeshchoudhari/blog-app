package com.example.gblog.controller;

import com.example.gblog.model.User;
import com.example.gblog.repository.UserRepository;
import com.example.gblog.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
  @Autowired
  private JwtUtil jwtUtil;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private PasswordEncoder passwordEncoder;

  @PostMapping("/login")
  public ResponseEntity<?> login(@RequestBody Map<String, String> payload) {
    String email = payload.get("email");
    String password = payload.get("password");
    User user = userRepository.findByEmail(email).orElse(null);
    if (user == null || !passwordEncoder.matches(password, user.getPasswordHash())) {
      return ResponseEntity.status(401).body(Map.of("error", "invalid credentials"));
    }
    String token = jwtUtil.generateToken(user.getUsername(), user.getRole());
    String refreshToken = jwtUtil.generateRefreshToken(user.getUsername(), user.getRole());
    Map<String, Object> resp = new HashMap<>();
    resp.put("token", token);
    resp.put("refreshToken", refreshToken);
    Map<String, String> userInfo = new HashMap<>();
    userInfo.put("username", user.getUsername());
    userInfo.put("role", user.getRole());
    resp.put("user", userInfo);
    return ResponseEntity.ok(resp);
  }

  @PostMapping("/refresh")
  public ResponseEntity<?> refresh(@RequestBody Map<String, String> payload) {
    String refreshToken = payload.get("refreshToken");
    if (refreshToken == null || jwtUtil.isTokenExpired(refreshToken)) {
      return ResponseEntity.status(401).body(Map.of("error", "invalid or expired refresh token"));
    }
    String username = jwtUtil.extractUsername(refreshToken);
    String role = jwtUtil.extractRole(refreshToken);
    String newToken = jwtUtil.generateToken(username, role);
    return ResponseEntity.ok(Map.of("token", newToken));
  }

  @GetMapping("/verify")
  public ResponseEntity<?> verify() {
    org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
    if (auth == null || !auth.isAuthenticated() || auth instanceof org.springframework.security.authentication.AnonymousAuthenticationToken) {
      return ResponseEntity.status(401).build();
    }
    String username = auth.getName();
    User user = userRepository.findByUsername(username).orElse(null);
    if (user == null) {
      return ResponseEntity.status(401).build();
    }
    Map<String, String> userInfo = new HashMap<>();
    userInfo.put("username", user.getUsername());
    userInfo.put("role", user.getRole());
    userInfo.put("email", user.getEmail());
    return ResponseEntity.ok(Map.of("user", userInfo));
  }
}
