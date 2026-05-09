import { useState } from 'react';
import { Link } from 'react-router-dom';

const PostCard = ({ post, onDelete }) => {
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-200">
      <div className="p-6">
        <h3 className="text-xl font-bold text-gray-900 mb-2 line-clamp-2">
          <Link to={`/posts/${post.id}`} className="hover:text-indigo-600">
            {post.title}
          </Link>
        </h3>
        
        <p className="text-gray-600 mb-4 line-clamp-3">
          {post.content}
        </p>
        
        <div className="flex flex-wrap gap-2 mb-4">
          {post.categories && post.categories.map((cat, index) => (
            <span key={index} className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
              {cat.name}
            </span>
          ))}
          {post.tags && post.tags.map((tag, index) => (
            <span key={index} className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
              {tag.name}
            </span>
          ))}
        </div>
        
        <div className="flex items-center justify-between text-sm text-gray-500">
          <span>Published: {formatDate(post.publishedAt || post.createdAt)}</span>
          {post.author && <span>By {post.author}</span>}
        </div>
      </div>
      
      <div className="bg-gray-50 px-6 py-3 flex items-center justify-between">
        <div className="flex space-x-4">
          <Link
            to={`/posts/${post.id}/edit`}
            className="text-sm font-medium text-indigo-600 hover:text-indigo-900"
          >
            Edit
          </Link>
          <button
            type="button"
            onClick={() => setShowDeleteConfirm(true)}
            className="text-sm font-medium text-red-600 hover:text-red-900"
          >
            Delete
          </button>
        </div>
        <Link
          to={`/posts/${post.id}`}
          className="text-sm font-medium text-gray-600 hover:text-gray-900"
        >
          Read more →
        </Link>
      </div>

      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-sm mx-4">
            <h3 className="text-lg font-medium text-gray-900 mb-2">Confirm Delete</h3>
            <p className="text-gray-600 mb-4">Are you sure you want to delete this post?</p>
            <div className="flex justify-end space-x-3">
              <button
                type="button"
                onClick={() => setShowDeleteConfirm(false)}
                className="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={() => {
                  onDelete(post.id);
                  setShowDeleteConfirm(false);
                }}
                className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PostCard;
