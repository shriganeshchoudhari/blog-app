import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { postApi, commentApi } from '../services/api';
import { PostSkeleton } from '../components/Skeleton';
import { toast } from 'react-toastify';

const PostDetailPage = () => {
  const { id } = useParams();
  const [post, setPost] = useState(null);
  const [comments, setComments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [newComment, setNewComment] = useState('');
  const [submittingComment, setSubmittingComment] = useState(false);

  useEffect(() => {
    const fetchPostData = async () => {
      try {
        const response = await postApi.getPostById(id);
        setPost(response.data);
        setComments(response.data.comments || []);
      } catch (err) {
        toast.error('Failed to load post details');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchPostData();
  }, [id]);

  const handleCommentSubmit = async (e) => {
    e.preventDefault();
    if (!newComment.trim()) return;

    setSubmittingComment(true);
    try {
      const response = await commentApi.createComment(id, { content: newComment });
      setComments([...comments, response.data]);
      setNewComment('');
      toast.success('Comment added!');
    } catch (err) {
      toast.error('Failed to add comment');
    } finally {
      setSubmittingComment(false);
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  if (loading) return <div className="max-w-4xl mx-auto p-8"><PostSkeleton /></div>;
  if (!post) return <div className="text-center py-12">Post not found.</div>;

  return (
    <div className="min-h-screen bg-white py-12">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <Link to="/posts" className="text-indigo-600 hover:text-indigo-500 mb-8 inline-block">
          ← Back to all posts
        </Link>
        
        <article>
          <header className="mb-8">
            <h1 className="text-4xl font-extrabold text-gray-900 mb-4">{post.title}</h1>
            <div className="flex items-center text-gray-500 text-sm space-x-4">
              <span>Published on {formatDate(post.publishedAt || post.createdAt)}</span>
              <span>•</span>
              <span>By {post.author || 'Anonymous'}</span>
            </div>
            
            <div className="mt-4 flex flex-wrap gap-2">
              {post.categories?.map((cat) => (
                <span key={cat.id} className="px-3 py-1 bg-indigo-100 text-indigo-800 rounded-full text-xs font-medium">
                  {cat.name}
                </span>
              ))}
              {post.tags?.map((tag) => (
                <span key={tag.id} className="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-xs font-medium">
                  #{tag.name}
                </span>
              ))}
            </div>
          </header>

          <div className="prose prose-indigo prose-lg max-w-none text-gray-700 leading-relaxed whitespace-pre-wrap">
            {post.content}
          </div>
        </article>

        <section className="mt-16 border-t border-gray-200 pt-10">
          <h2 className="text-2xl font-bold text-gray-900 mb-8">Comments ({comments.length})</h2>
          
          <form onSubmit={handleCommentSubmit} className="mb-12">
            <textarea
              rows="4"
              className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm p-4 border"
              placeholder="Add a comment..."
              value={newComment}
              onChange={(e) => setNewComment(e.target.value)}
            ></textarea>
            <div className="mt-3 flex justify-end">
              <button
                type="submit"
                disabled={submittingComment}
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
              >
                {submittingComment ? 'Posting...' : 'Post Comment'}
              </button>
            </div>
          </form>

          <div className="space-y-8">
            {comments.map((comment) => (
              <div key={comment.id} className="flex space-x-4">
                <div className="flex-shrink-0">
                  <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center font-bold text-gray-500">
                    {comment.author?.[0]?.toUpperCase() || 'U'}
                  </div>
                </div>
                <div className="flex-1 bg-gray-50 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="text-sm font-bold text-gray-900">{comment.author || 'User'}</h3>
                    <span className="text-xs text-gray-500">{formatDate(comment.createdAt)}</span>
                  </div>
                  <p className="text-gray-700 text-sm">{comment.content}</p>
                </div>
              </div>
            ))}
            {comments.length === 0 && (
              <p className="text-gray-500 text-center italic">No comments yet. Be the first to share your thoughts!</p>
            )}
          </div>
        </section>
      </div>
    </div>
  );
};

export default PostDetailPage;
