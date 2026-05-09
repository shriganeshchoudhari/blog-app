package com.example.gblog.model;

import jakarta.persistence.*;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "categories", schema = "blog")
public class Category {
  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private UUID id;

  public Category() {}
  public Category(String name) {
    this.name = name;
    this.slug = name.toLowerCase().replaceAll("[^a-z0-9]+", "-");
  }

  @Column(nullable = false, unique = true)
  private String name;

  @Column(nullable = false, unique = true)
  private String slug;

  @JsonIgnore
  @ManyToMany(mappedBy = "categories")
  private Set<Post> posts = new HashSet<>();

  public UUID getId() { return id; }
  public void setId(UUID id) { this.id = id; }
  public String getName() { return name; }
  public void setName(String name) { this.name = name; }
  public String getSlug() { return slug; }
  public void setSlug(String slug) { this.slug = slug; }
  public Set<Post> getPosts() { return posts; }
  public void setPosts(Set<Post> posts) { this.posts = posts; }
}
