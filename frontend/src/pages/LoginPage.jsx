import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../services/api'

export default function LoginPage() {
  const [username, setUsername] = useState('admin')
  const [password, setPassword] = useState('password')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()

  async function login(e) {
    e.preventDefault()
    setLoading(true)
    try {
      const resp = await api.post('/auth/login', { username, password })
      // Backend returns accessToken and refreshToken
      localStorage.setItem('accessToken', resp.data.accessToken)
      localStorage.setItem('refreshToken', resp.data.refreshToken)
      localStorage.setItem('username', username)
      navigate('/posts')
    } catch (err) {
      console.error(err)
      alert('Login failed: ' + (err.response?.data?.message || 'Unauthorized'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="container" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '80vh' }}>
      <div className="glass-card" style={{ width: '100%', maxWidth: '400px' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <h2 style={{ fontSize: '2rem', background: 'linear-gradient(45deg, #fff, #aaa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            G-Blog X
          </h2>
          <p style={{ color: 'rgba(255,255,255,0.6)' }}>Premium Microservices Blog</p>
        </div>
        
        <form onSubmit={login}>
          <div style={{ marginBottom: '1.5rem' }}>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.9rem', color: 'rgba(255,255,255,0.8)' }}>Username</label>
            <input 
              value={username} 
              onChange={e => setUsername(e.target.value)} 
              placeholder="admin" 
              required 
              style={{ width: '100%' }}
            />
          </div>
          <div style={{ marginBottom: '2rem' }}>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.9rem', color: 'rgba(255,255,255,0.8)' }}>Password</label>
            <input 
              type="password" 
              value={password} 
              onChange={e => setPassword(e.target.value)} 
              placeholder="password" 
              required 
              style={{ width: '100%' }}
            />
          </div>
          <button type="submit" className="btn-primary" style={{ width: '100%' }} disabled={loading}>
            {loading ? 'Authenticating...' : 'Login'}
          </button>
        </form>
      </div>
    </div>
  )
}
