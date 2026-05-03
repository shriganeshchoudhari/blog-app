package com.example.gblog.repository;

import com.example.gblog.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface PostRepository extends JpaRepository<Post, UUID> { }
