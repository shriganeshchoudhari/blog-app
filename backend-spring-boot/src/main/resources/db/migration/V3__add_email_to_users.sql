-- Add email column to users table
ALTER TABLE blog.users ADD COLUMN email TEXT UNIQUE;

-- Update existing users with a dummy email (optional but good for NOT NULL)
UPDATE blog.users SET email = username || '@example.com' WHERE email IS NULL;

-- Make it NOT NULL
ALTER TABLE blog.users ALTER COLUMN email SET NOT NULL;
