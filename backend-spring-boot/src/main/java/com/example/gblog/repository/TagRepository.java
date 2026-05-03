package com.example.gblog.repository;

import com.example.gblog.model.Tag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface TagRepository extends JpaRepository<Tag, UUID> {
  Optional<Tag> findBySlug(String slug);
}
