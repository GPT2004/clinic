import React, {useState} from 'react';
import { forgotPassword } from '../../services/authService';
export default function ForgotPasswordPage(){ const [email,setEmail]=useState(''); const [sent,setSent]=useState(false);
  const handle=async(e)=>{ e.preventDefault(); const r = await forgotPassword(email); if(r && r.errCode===0) setSent(true); else alert('Failed'); }
  return (<div className='min-h-screen flex items-center justify-center bg-gray-50 p-4'>{sent? (<div className='bg-white p-6 rounded shadow'>Yêu cầu đổi mật khẩu đã gửi. Vui lòng kiểm tra email.</div>): (<form onSubmit={handle} className='w-full max-w-md bg-white p-6 rounded shadow'><h1 className='text-xl font-semibold mb-4'>Quên mật khẩu</h1><input value={email} onChange={e=>setEmail(e.target.value)} placeholder='Email' className='mb-2 p-2 border rounded w-full' /><button className='mt-2 w-full bg-blue-600 text-white py-2 rounded'>Gửi</button></form>)}</div>); }
