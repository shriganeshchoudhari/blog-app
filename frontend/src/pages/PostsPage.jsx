import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../services/api'

export default function PostsPage() {
  const [posts, setPosts] = useState([])
  const [loading, setLoading] = useState(true)
  const navigate = useNavigate()

  const fetchPosts = async () => {
    try {
      setLoading(true)
      const resp = await api.get('/posts')
      setPosts(resp.data.data || resp.data)
    } catch (err) {
      console.error('Failed to fetch posts', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchPosts()
  }, [])

  async function handleDelete(id) {
    if (!window.confirm('Are you sure you want to delete this post?')) return
    try {
      await api.delete(`/posts/${id}`)
      fetchPosts()
    } catch (err) {
      alert('Delete failed: ' + (err.response?.data?.message || 'Unauthorized'))
    }
  }

  return (
    <div className="container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
        <h2 style={{ fontSize: '1.8rem', fontWeight: '700' }}>Articles</h2>
        <button className="btn-primary" onClick={() => navigate('/posts/create')}>+ New Entry</button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '4rem' }}>Loading posts...</div>
      ) : (
        <div className="post-grid">
          {posts.map(p => (
            <div key={p.id} className="post-card">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '1rem' }}>
                <h3 style={{ fontSize: '1.2rem', color: '#fff' }}>{p.title}</h3>
                <span className={`badge badge-${p.status || 'draft'}`}>
                  {p.status || 'draft'}
                </span>
              </div>
              <p style={{ color: 'rgba(255,255,255,0.6)', marginBottom: '1.5rem', lineHeight: '1.5' }}>
                {p.summary || 'No summary available.'}
              </p>
              <div style={{ display: 'flex', gap: '1rem', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '1rem' }}>
                <button 
                  style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.1)', padding: '0.4rem 1rem', fontSize: '0.8rem' }}
                  onClick={() => navigate(`/posts/edit/${p.id}`)}
                >
                  Modify
                </button>
                <button 
                  className="btn-danger"
                  style={{ padding: '0.4rem 1rem', fontSize: '0.8rem' }}
                  onClick={() => handleDelete(p.id)}
                >
                  Remove
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {!loading && posts.length === 0 && (
        <div className="glass-card" style={{ textAlign: 'center', padding: '4rem' }}>
          <p style={{ color: 'rgba(255,255,255,0.5)' }}>The feed is currently empty. Start your journey by publishing an article!</p>
        </div>
      )}
    </div>
  )
}
