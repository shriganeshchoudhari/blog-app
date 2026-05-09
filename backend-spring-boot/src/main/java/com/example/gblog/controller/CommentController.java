package com.example.gblog.controller;

import com.example.gblog.model.Comment;
import com.example.gblog.repository.CommentRepository;
import com.example.gblog.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/posts/{postId}/comments")
public class CommentController {

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private PostRepository postRepository;

    @GetMapping
    public ResponseEntity<List<Comment>> getComments(@PathVariable("postId") UUID postId) {
        if (!postRepository.existsById(postId)) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(commentRepository.findByPostId(postId));
    }

    @PostMapping
    public ResponseEntity<Comment> addComment(@PathVariable("postId") UUID postId, @RequestBody Comment comment) {
        return postRepository.findById(postId).map(post -> {
            comment.setPostId(postId);
            comment.setCreatedAt(ZonedDateTime.now());
            if (comment.getAuthor() == null) {
                comment.setAuthor("Anonymous");
            }
            return ResponseEntity.ok(commentRepository.save(comment));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{commentId}")
    public ResponseEntity<Void> deleteComment(@PathVariable("postId") UUID postId, @PathVariable("commentId") UUID commentId) {
        return commentRepository.findById(commentId).map(comment -> {
            if (comment.getPostId().equals(postId)) {
                commentRepository.delete(comment);
                return ResponseEntity.noContent().<Void>build();
            }
            return ResponseEntity.badRequest().<Void>build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
