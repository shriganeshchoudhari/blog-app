package com.example.gblog.model;

import jakarta.persistence.*;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "comments", schema = "blog")
public class Comment {
  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private UUID id;
  @Column(name = "post_id")
  private UUID postId;
  @Column(name = "user_id")
  private UUID userId;
  @Column(columnDefinition = "TEXT")
  private String content;
  private ZonedDateTime createdAt = ZonedDateTime.now();
  private ZonedDateTime updatedAt = ZonedDateTime.now();
  private UUID parentId;

  // getters/setters
  public UUID getId() { return id; }
  public void setId(UUID id) { this.id = id; }
  public UUID getPostId() { return postId; }
  public void setPostId(UUID postId) { this.postId = postId; }
  public UUID getUserId() { return userId; }
  public void setUserId(UUID userId) { this.userId = userId; }
  public String getContent() { return content; }
  public void setContent(String content) { this.content = content; }
  public ZonedDateTime getCreatedAt() { return createdAt; }
  public void setCreatedAt(ZonedDateTime createdAt) { this.createdAt = createdAt; }
  public ZonedDateTime getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(ZonedDateTime updatedAt) { this.updatedAt = updatedAt; }
  public UUID getParentId() { return parentId; }
  public void setParentId(UUID parentId) { this.parentId = parentId; }
}
