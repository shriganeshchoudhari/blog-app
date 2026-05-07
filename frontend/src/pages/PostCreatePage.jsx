import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../services/api'

export default function PostCreatePage() {
  const [post, setPost] = useState({ title: '', content: '', status: 'draft', summary: '' })
  const navigate = useNavigate()

  async function handleSubmit(e) {
    e.preventDefault()
    try {
      await api.post('/posts', post)
      navigate('/posts')
    } catch (err) {
      console.error(err)
      alert('Failed to create post: ' + (err.response?.data?.message || 'Error'))
    }
  }

  return (
    <div className="container">
      <div className="glass-card">
        <h2>Create New Post</h2>
        <form onSubmit={handleSubmit}>
          <div>
            <label>Title</label>
            <input 
              value={post.title} 
              onChange={e => setPost({ ...post, title: e.target.value })} 
              placeholder="Enter post title"
              required 
            />
          </div>
          <div>
            <label>Summary</label>
            <input 
              value={post.summary} 
              onChange={e => setPost({ ...post, summary: e.target.value })} 
              placeholder="Short summary of the post"
            />
          </div>
          <div>
            <label>Content</label>
            <textarea 
              rows="10"
              value={post.content} 
              onChange={e => setPost({ ...post, content: e.target.value })} 
              placeholder="Write your story here..."
              required 
            />
          </div>
          <div>
            <label>Status</label>
            <select 
              value={post.status} 
              onChange={e => setPost({ ...post, status: e.target.value })}
            >
              <option value="draft">Draft</option>
              <option value="published">Published</option>
            </select>
          </div>
          <div style={{ display: 'flex', gap: '1rem' }}>
            <button type="submit" className="btn-primary">Create Post</button>
            <button type="button" onClick={() => navigate('/posts')}>Cancel</button>
          </div>
        </form>
      </div>
    </div>
  )
}
