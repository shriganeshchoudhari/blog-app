package com.example.gblog.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "posts", schema = "blog")
public class Post {
  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private UUID id;

  @Column(name = "user_id")
  private UUID userId;

  private String title;
  @Column(columnDefinition = "TEXT")
  private String content;
  private String status;
  private String slug;
  private String summary;
  @Column(name = "created_at")
  private ZonedDateTime createdAt = ZonedDateTime.now();
  @Column(name = "updated_at")
  private ZonedDateTime updatedAt = ZonedDateTime.now();
  @Column(name = "published_at")
  private ZonedDateTime publishedAt;
  private String author;

  @ManyToMany
  @JoinTable(
    name = "post_tags",
    joinColumns = @JoinColumn(name = "post_id"),
    inverseJoinColumns = @JoinColumn(name = "tag_id")
  )
  private Set<Tag> tags = new HashSet<>();

  @ManyToMany
  @JoinTable(
    name = "post_categories",
    joinColumns = @JoinColumn(name = "post_id"),
    inverseJoinColumns = @JoinColumn(name = "category_id")
  )
  private Set<Category> categories = new HashSet<>();

  // Getters/Setters
  public UUID getId() { return id; }
  public void setId(UUID id) { this.id = id; }
  public UUID getUserId() { return userId; }
  public void setUserId(UUID userId) { this.userId = userId; }
  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }
  public String getContent() { return content; }
  public void setContent(String content) { this.content = content; }
  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }
  public String getSlug() { return slug; }
  public void setSlug(String slug) { this.slug = slug; }
  public String getSummary() { return summary; }
  public void setSummary(String summary) { this.summary = summary; }
  public ZonedDateTime getCreatedAt() { return createdAt; }
  public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
  public ZonedDateTime getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(ZonedDateTime updatedAt) { this.updatedAt = updatedAt; }
  public ZonedDateTime getPublishedAt() { return publishedAt; }
  public void setPublishedAt(ZonedDateTime publishedAt) { this.publishedAt = publishedAt; }
  public String getAuthor() { return author; }
  public void setAuthor(String author) { this.author = author; }
  public Set<Tag> getTags() { return tags; }
  public void setTags(Set<Tag> tags) { this.tags = tags; }
  public Set<Category> getCategories() { return categories; }
  public void setCategories(Set<Category> categories) { this.categories = categories; }
}
