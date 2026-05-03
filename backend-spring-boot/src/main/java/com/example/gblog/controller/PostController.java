package com.example.gblog.controller;

import com.example.gblog.model.Post;
import com.example.gblog.model.Comment;
import com.example.gblog.model.Tag;
import com.example.gblog.model.Category;
import com.example.gblog.repository.PostRepository;
import com.example.gblog.repository.CommentRepository;
import com.example.gblog.repository.TagRepository;
import com.example.gblog.repository.CategoryRepository;
import com.example.gblog.dto.PostDetailDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;
import java.util.UUID;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.GrantedAuthority;

@RestController
@RequestMapping("/api/v1/posts")
public class PostController {
  @Autowired
  private PostRepository postRepository;
  @Autowired
  private CommentRepository commentRepository;
  @Autowired
  private TagRepository tagRepository;
  @Autowired
  private CategoryRepository categoryRepository;
  @Autowired
  private io.micrometer.core.instrument.Counter postCreationCounter;

  private java.util.List<Comment> fetchComments(UUID postId) {
    return commentRepository.findByPostId(postId);
  }

  private boolean hasRole(String... roles) {
    if (roles == null || roles.length == 0)
      return false;
    org.springframework.security.core.Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth == null)
      return false;
    for (GrantedAuthority ga : auth.getAuthorities()) {
      String a = ga.getAuthority(); // e.g. ROLE_ADMIN
      for (String r : roles) {
        if (a.equals("ROLE_" + r.toUpperCase()))
          return true;
      }
    }
    return false;
  }

  @GetMapping
  public List<Post> list() {
    return postRepository.findAll();
  }

  @GetMapping("/{id}")
  public ResponseEntity<?> get(@PathVariable UUID id) {
    java.util.Optional<Post> postOpt = postRepository.findById(id);
    if (postOpt.isEmpty())
      return ResponseEntity.notFound().build();
    Post post = postOpt.get();
    List<Comment> comments = fetchComments(post.getId());
    List<Tag> tags = new java.util.ArrayList<>(post.getTags());
    List<Category> categories = new java.util.ArrayList<>(post.getCategories());
    PostDetailDTO dto = new PostDetailDTO(post, comments, tags, categories);
    return ResponseEntity.ok(dto);
  }

  @PreAuthorize("hasAnyRole('ADMIN','AUTHOR','EDITOR')")
  @PostMapping
  public ResponseEntity<Post> create(@RequestBody Post p) {
    if (!hasRole("admin", "author", "editor")) {
      return ResponseEntity.status(403).build();
    }
    if (p.getSlug() == null || p.getSlug().isEmpty()) {
      p.setSlug((p.getTitle() != null ? p.getTitle() : "post").toLowerCase().replaceAll("[^a-z0-9]+", "-"));
    }
    // Persist tags/categories if provided
    if (p.getTags() != null) {
      java.util.Set<Tag> managedTags = new java.util.HashSet<>();
      for (Tag t : p.getTags()) {
        Tag existing = tagRepository.findBySlug(t.getSlug()).orElse(null);
        if (existing == null) {
          Tag nt = new Tag();
          nt.setName(t.getName());
          nt.setSlug(t.getSlug());
          existing = tagRepository.save(nt);
        }
        managedTags.add(existing);
      }
      p.setTags(managedTags);
    }
    if (p.getCategories() != null) {
      java.util.Set<Category> managedCats = new java.util.HashSet<>();
      for (Category c : p.getCategories()) {
        Category existing = categoryRepository.findBySlug(c.getSlug()).orElse(null);
        if (existing == null) {
          Category nc = new Category();
          nc.setName(c.getName());
          nc.setSlug(c.getSlug());
          existing = categoryRepository.save(nc);
        }
        managedCats.add(existing);
      }
      p.setCategories(managedCats);
    }
    postCreationCounter.increment();
    return ResponseEntity.ok(postRepository.save(p));
  }

  @PreAuthorize("hasAnyRole('ADMIN','EDITOR')")
  @PutMapping("/{id}")
  public ResponseEntity<Post> update(@PathVariable UUID id, @RequestBody Post p) {
    if (!hasRole("admin", "editor")) {
      return ResponseEntity.status(403).build();
    }
    return postRepository.findById(id).map(existing -> {
      existing.setTitle(p.getTitle());
      existing.setContent(p.getContent());
      existing.setSummary(p.getSummary());
      existing.setStatus(p.getStatus());
      existing.setUpdatedAt(java.time.ZonedDateTime.now());
      // Update tags/categories if provided
      if (p.getTags() != null) {
        java.util.Set<Tag> managedTags = new java.util.HashSet<>();
        for (Tag t : p.getTags()) {
          Tag existingTag = tagRepository.findBySlug(t.getSlug()).orElse(null);
          if (existingTag == null) {
            Tag nt = new Tag();
            nt.setName(t.getName());
            nt.setSlug(t.getSlug());
            existingTag = tagRepository.save(nt);
          }
          managedTags.add(existingTag);
        }
        existing.setTags(managedTags);
      }
      if (p.getCategories() != null) {
        java.util.Set<Category> managedCats = new java.util.HashSet<>();
        for (Category c : p.getCategories()) {
          Category existingCat = categoryRepository.findBySlug(c.getSlug()).orElse(null);
          if (existingCat == null) {
            Category nc = new Category();
            nc.setName(c.getName());
            nc.setSlug(c.getSlug());
            existingCat = categoryRepository.save(nc);
          }
          managedCats.add(existingCat);
        }
        existing.setCategories(managedCats);
      }
      return ResponseEntity.ok(postRepository.save(existing));
    }).orElseGet(() -> ResponseEntity.notFound().build());
  }

  @PreAuthorize("hasAnyRole('ADMIN','EDITOR')")
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> delete(@PathVariable UUID id) {
    if (!hasRole("admin", "editor")) {
      return ResponseEntity.status(403).build();
    }
    if (postRepository.existsById(id)) {
      postRepository.deleteById(id);
      return ResponseEntity.noContent().build();
    }
    return ResponseEntity.notFound().build();
  }
}
