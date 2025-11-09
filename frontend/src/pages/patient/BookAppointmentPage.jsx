import React, {useState} from 'react';
import { createAppointment } from '../../services/appointmentService';
export default function BookAppointmentPage(){ const [name,setName]=useState(''); const [time,setTime]=useState('');
const handle=async()=>{ if(!name||!time) return alert('Nhập đầy đủ'); await createAppointment({name,time}); alert('Đã đặt lịch'); setName(''); setTime(''); }
return (<div className='p-6'><h1 className='text-2xl font-bold mb-4'>Đặt lịch khám</h1><div className='bg-white p-4 rounded shadow'><label className='block mb-2'>Tên<input value={name} onChange={e=>setName(e.target.value)} className='mt-1 p-2 border rounded w-full'/></label><label className='block mb-2'>Thời gian<input value={time} onChange={e=>setTime(e.target.value)} className='mt-1 p-2 border rounded w-full'/></label><button onClick={handle} className='mt-2 px-4 py-2 bg-blue-600 text-white rounded'>Đặt</button></div></div>); }
