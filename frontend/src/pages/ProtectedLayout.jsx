import React from 'react'
import { Outlet, Navigate } from 'react-router-dom'

export default function ProtectedLayout() {
  const token = localStorage.getItem('accessToken')
  
  if (!token) {
    return <Navigate to="/login" replace />
  }

  return (
    <div className="app-layout">
      <nav style={{ padding: '1rem 2rem', background: 'rgba(0,0,0,0.2)', backdropFilter: 'blur(10px)', marginBottom: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1 style={{ fontSize: '1.2rem', fontWeight: '700' }}>G-Blog X</h1>
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
          <span style={{ fontSize: '0.8rem', color: 'rgba(255,255,255,0.6)' }}>{localStorage.getItem('username')}</span>
          <button 
            onClick={() => { localStorage.clear(); window.location.href='/login'; }} 
            className="btn-primary" 
            style={{ padding: '0.4rem 1rem', fontSize: '0.8rem' }}
          >
            Logout
          </button>
        </div>
      </nav>
      <Outlet />
    </div>
  )
}
