import React from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import LoginPage from './pages/LoginPage.jsx'
import PostsPage from './pages/PostsPage.jsx'
import ProtectedLayout from './pages/ProtectedLayout.jsx'
import PostCreatePage from './pages/PostCreatePage.jsx'
import PostEditPage from './pages/PostEditPage.jsx'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route element={<ProtectedLayout />}> 
          <Route path="/posts" element={<PostsPage />} />
          <Route path="/posts/create" element={<PostCreatePage />} />
          <Route path="/posts/edit/:id" element={<PostEditPage />} />
        </Route>
        <Route path="*" element={<Navigate to="/login" />} />
      </Routes>
    </BrowserRouter>
  )
}
