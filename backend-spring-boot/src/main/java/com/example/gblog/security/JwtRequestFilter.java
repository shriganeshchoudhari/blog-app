package com.example.gblog.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

public class JwtRequestFilter extends OncePerRequestFilter {
  private final JwtUtil jwtUtil = new JwtUtil();

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
      throws ServletException, IOException {
    final String authHeader = request.getHeader("Authorization");
    String username = null;
    String jwt = null;
    if (authHeader != null && authHeader.startsWith("Bearer ")) {
      jwt = authHeader.substring(7);
      try {
        username = jwtUtil.extractUsername(jwt);
        String role = jwtUtil.extractRole(jwt);
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
          UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
              username,
              null,
              Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + (role != null ? role.toUpperCase() : "USER")))
          );
          SecurityContextHolder.getContext().setAuthentication(auth);
        }
      } catch (Exception e) {
        // invalid token; fall through to unauthenticated
      }
    }
    chain.doFilter(request, response);
  }
}
