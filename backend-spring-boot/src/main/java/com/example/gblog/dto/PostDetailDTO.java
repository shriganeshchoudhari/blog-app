package com.example.gblog.dto;

import com.example.gblog.model.Comment;
import com.example.gblog.model.Post;
import com.example.gblog.model.Tag;
import com.example.gblog.model.Category;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

public class PostDetailDTO {
  public UUID id;
  public String title;
  public String content;
  public String slug;
  public String summary;
  public String status;
  public ZonedDateTime createdAt;
  public ZonedDateTime updatedAt;
  public ZonedDateTime publishedAt;
  public String author;
  public List<Comment> comments;
  public List<Tag> tags;
  public List<Category> categories;

  public PostDetailDTO() {}
  public PostDetailDTO(Post p, List<Comment> comments, List<Tag> tags, List<Category> categories) {
    this.id = p.getId();
    this.title = p.getTitle();
    this.content = p.getContent();
    this.slug = p.getSlug();
    this.summary = p.getSummary();
    this.status = p.getStatus();
    this.createdAt = p.getCreatedAt();
    this.updatedAt = p.getUpdatedAt();
    this.publishedAt = p.getPublishedAt();
    this.author = p.getAuthor();
    this.comments = comments;
    this.tags = tags;
    this.categories = categories;
  }
}
