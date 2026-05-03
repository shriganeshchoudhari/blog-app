-- Seed a sample post for Phase 1 readiness
INSERT INTO blog.posts (id, user_id, title, slug, content, summary, status, created_at, updated_at, published_at)
VALUES (gen_random_uuid(), NULL, 'Seed Post for Phase 1', 'seed-post-phase-1', 'This is a seed post to verify create/read flows in Phase 1.', 'Seed data', 'published', NOW(), NOW(), NOW());
