-- Seed Tags
INSERT INTO blog.tags (id, name, slug) VALUES 
(gen_random_uuid(), 'Technology', 'technology'),
(gen_random_uuid(), 'Lifestyle', 'lifestyle'),
(gen_random_uuid(), 'Coding', 'coding')
ON CONFLICT (slug) DO NOTHING;

-- Seed Categories
INSERT INTO blog.categories (id, name, slug) VALUES 
(gen_random_uuid(), 'Engineering', 'engineering'),
(gen_random_uuid(), 'General', 'general')
ON CONFLICT (slug) DO NOTHING;

-- Seed a sample post for Phase 1 readiness
INSERT INTO blog.posts (id, user_id, title, slug, content, summary, status, created_at, updated_at, published_at)
VALUES (gen_random_uuid(), NULL, 'Welcome to G-Blog X', 'welcome-to-gblog-x', 'This is a seed post to verify create/read flows. It showcases the premium blogging experience.', 'Welcome seed data', 'published', NOW(), NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Link Post to Tags (Generic approach - might need subqueries in real use if IDs are dynamic)
INSERT INTO blog.post_tags (post_id, tag_id)
SELECT p.id, t.id FROM blog.posts p, blog.tags t 
WHERE p.slug = 'welcome-to-gblog-x' AND t.slug IN ('technology', 'coding')
ON CONFLICT DO NOTHING;
