import { BrowserRouter, Routes, Route } from 'react-router-dom';
import PostsPage from './pages/PostsPage';
import PostCreatePage from './pages/PostCreatePage';
import PostEditPage from './pages/PostEditPage';
import PostDetailPage from './pages/PostDetailPage';
import LoginPage from './pages/LoginPage';
import ProtectedLayout from './pages/ProtectedLayout';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

function App() {
  return (
    <>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          
          <Route element={<ProtectedLayout />}>
            <Route path="/" element={<PostsPage />} />
            <Route path="/posts" element={<PostsPage />} />
            <Route path="/posts/:id" element={<PostDetailPage />} />
            <Route path="/posts/create" element={<PostCreatePage />} />
            <Route path="/posts/:id/edit" element={<PostEditPage />} />
          </Route>
        </Routes>
      </BrowserRouter>
      <ToastContainer position="bottom-right" autoClose={3000} />
    </>
  );
}

export default App;
