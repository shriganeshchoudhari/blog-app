package com.example.gblog.config;

import com.example.gblog.model.Post;
import com.example.gblog.model.User;
import com.example.gblog.repository.PostRepository;
import com.example.gblog.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.security.crypto.password.PasswordEncoder;

import jakarta.annotation.PostConstruct;
import java.time.ZonedDateTime;

@Component
public class DataLoader {
  @Autowired
  private PostRepository postRepository;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private PasswordEncoder passwordEncoder;

  @PostConstruct
  public void load() {
    // Seed admin user if not exists
    if (userRepository.findByUsername("admin").isEmpty()) {
      User u = new User();
      u.setUsername("admin");
      u.setPasswordHash(passwordEncoder.encode("password"));
      u.setRole("admin");
      userRepository.save(u);
    }
    // Seed a sample post if no posts exist
    if (postRepository.count() == 0) {
      Post p = new Post();
      p.setTitle("Welcome to G-Blog X");
      p.setContent("This is a sample post to bootstrap the blog.");
      p.setStatus("published");
      p.setSlug("welcome-to-gblog-x");
      p.setSummary("Intro post");
      p.setAuthor("admin");
      p.setCreatedAt(ZonedDateTime.now());
      p.setUpdatedAt(ZonedDateTime.now());
      p.setPublishedAt(ZonedDateTime.now());
      postRepository.save(p);
    }
  }
}
