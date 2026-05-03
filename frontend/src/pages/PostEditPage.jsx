import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'

export default function PostEditPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const [post, setPost] = useState({ title: '', content: '', status: 'draft', summary: '' })
  const [token] = useState(localStorage.getItem('token'))

  useEffect(() => {
    fetch(`http://localhost:8080/api/v1/posts/${id}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    })
      .then(res => res.json())
      .then(data => {
        // Handle both Post and PostDetailDTO formats
        const p = data.post || data;
        setPost({
          title: p.title || '',
          content: p.content || '',
          status: p.status || 'draft',
          summary: p.summary || ''
        })
      })
  }, [id, token])

  async function handleSubmit(e) {
    e.preventDefault()
    const resp = await fetch(`http://localhost:8080/api/v1/posts/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(post)
    })
    if (resp.ok) {
      navigate('/posts')
    } else {
      alert('Failed to update post')
    }
  }

  return (
    <div className="container">
      <div className="glass-card">
        <h2>Edit Post</h2>
        <form onSubmit={handleSubmit}>
          <div>
            <label>Title</label>
            <input 
              value={post.title} 
              onChange={e => setPost({ ...post, title: e.target.value })} 
              required
            />
          </div>
          <div>
            <label>Summary</label>
            <input 
              value={post.summary} 
              onChange={e => setPost({ ...post, summary: e.target.value })} 
            />
          </div>
          <div>
            <label>Content</label>
            <textarea 
              rows="10"
              value={post.content} 
              onChange={e => setPost({ ...post, content: e.target.value })} 
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
            <button type="submit" className="btn-primary">Update Post</button>
            <button type="button" onClick={() => navigate('/posts')}>Cancel</button>
          </div>
        </form>
      </div>
    </div>
  )
}
