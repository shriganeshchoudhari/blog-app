package com.example.gblog.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class JwtUtil {
  private String secret = System.getenv("JWT_SECRET");
  private long jwtExpirationMs = 900_000; // 15 minutes for access token
  private long refreshExpirationMs = 604800_000; // 7 days for refresh token

  public JwtUtil() {
    if (secret == null || secret.isEmpty()) {
      secret = "change-me-now-and-make-it-long-enough-for-hs256"; // HS256 needs at least 256 bits
    }
  }

  private SecretKey getSigningKey() {
    return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
  }

  public String generateToken(String username, String role) {
    return createToken(username, role, jwtExpirationMs);
  }

  public String generateRefreshToken(String username, String role) {
    return createToken(username, role, refreshExpirationMs);
  }

  private String createToken(String username, String role, long expiration) {
    Map<String, Object> claims = new HashMap<>();
    claims.put("role", role);
    return Jwts.builder()
        .claims(claims)
        .subject(username)
        .issuedAt(new Date())
        .expiration(new Date(System.currentTimeMillis() + expiration))
        .signWith(getSigningKey())
        .compact();
  }

  public String extractUsername(String token) {
    return extractAllClaims(token).getSubject();
  }

  public String extractRole(String token) {
    Claims c = extractAllClaims(token);
    Object r = c.get("role");
    return r != null ? r.toString() : null;
  }

  public boolean isTokenExpired(String token) {
    Date expiration = extractAllClaims(token).getExpiration();
    return expiration.before(new Date());
  }

  public boolean validateToken(String token, String username) {
    final String user = extractUsername(token);
    return (user.equals(username) && !isTokenExpired(token));
  }

  private Claims extractAllClaims(String token) {
    return Jwts.parser()
        .verifyWith(getSigningKey())
        .build()
        .parseSignedClaims(token)
        .getPayload();
  }
}
