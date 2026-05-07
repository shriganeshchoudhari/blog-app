import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import api from '../services/api'

export default function PostEditPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const [post, setPost] = useState({ title: '', content: '', status: 'draft', summary: '' })

  useEffect(() => {
    api.get(`/posts/${id}`)
      .then(resp => {
        const data = resp.data;
        // Handle both Post and PostDetailDTO formats
        const p = data.post || data.data || data;
        setPost({
          title: p.title || '',
          content: p.content || '',
          status: p.status || 'draft',
          summary: p.summary || ''
        })
      })
      .catch(err => console.error('Failed to load post', err))
  }, [id])

  async function handleSubmit(e) {
    e.preventDefault()
    try {
      await api.put(`/posts/${id}`, post)
      navigate('/posts')
    } catch (err) {
      console.error(err)
      alert('Failed to update post: ' + (err.response?.data?.message || 'Error'))
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
