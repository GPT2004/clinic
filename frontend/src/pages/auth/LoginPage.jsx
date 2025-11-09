import React, {useState} from 'react';
import { login } from '../../services/authService';
import { useNavigate } from 'react-router-dom';

export default function LoginPage(){
  const [email,setEmail]=useState('');
  const [password,setPassword]=useState('');
  const [loading,setLoading]=useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try{
      const res = await login({email,password});
      if(res && (res.errCode===0 || res.token)){
        // naive storage
        localStorage.setItem('token', res.token || 'demo-token');
        const role = (res.data && res.data.role) || 'ADMIN';
        navigate(role.toLowerCase()==='doctor'?'/doctor/dashboard': (role.toLowerCase()==='patient'?'/patient/dashboard':'/admin/dashboard'));
      } else {
        alert(res.message || 'Login failed');
      }
    }catch(e){
      alert('Network error');
    }finally{ setLoading(false); }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-4">
      <form onSubmit={handleSubmit} className="w-full max-w-md bg-white p-6 rounded shadow">
        <h1 className="text-xl font-semibold mb-4">Đăng nhập</h1>
        <label className="block mb-2">Email<input type="email" value={email} onChange={e=>setEmail(e.target.value)} required className="mt-1 p-2 border rounded w-full"/></label>
        <label className="block mb-2">Mật khẩu<input type="password" value={password} onChange={e=>setPassword(e.target.value)} required className="mt-1 p-2 border rounded w-full"/></label>
        <div className="flex justify-between items-center mt-4">
          <button type="submit" disabled={loading} className="px-4 py-2 bg-blue-600 text-white rounded">{loading? 'Đang...' : 'Đăng nhập'}</button>
          <a className="text-sm text-blue-600" href="/forgot">Quên mật khẩu?</a>
        </div>
      </form>
    </div>
  );
}
