import React, {useEffect, useState} from 'react';
import PageWrapper from './_AdminWrapper';
import { getAllUsers } from '../../services/userService';

export default function DoctorsPage(){
  const [doctors,setDoctors]=useState([]);
  const [query,setQuery]=useState('');
  useEffect(()=>{ (async ()=>{ const r = await getAllUsers({role:'DOCTOR'}); if(r && r.data) setDoctors(r.data); })(); },[]);
  const filtered = (doctors||[]).filter(d=> (d.fullName||d.name||'').toLowerCase().includes(query.toLowerCase()));
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Quản lý bác sĩ</h1>
      <div className="bg-white p-4 rounded shadow mb-4 flex gap-2">
        <input value={query} onChange={(e)=>setQuery(e.target.value)} placeholder="Tìm kiếm bác sĩ..." className="p-2 border rounded flex-1" />
        <button className="px-4 py-2 bg-blue-600 text-white rounded">Thêm bác sĩ</button>
      </div>
      <div className="bg-white p-4 rounded shadow">
        {filtered.length===0 ? <div className="text-gray-500">Không có bác sĩ</div> :
        <table className="min-w-full"><thead><tr className="text-left text-sm text-gray-600"><th className="py-2">Tên</th><th className="py-2">Email</th><th className="py-2">Chuyên môn</th><th className="py-2">Hành động</th></tr></thead>
        <tbody>{filtered.map(d=>(<tr key={d.id} className="border-t"><td className="py-2">{d.fullName||d.name}</td><td className="py-2">{d.email}</td><td className="py-2">{d.specialty||'-'}</td><td className="py-2"><button className="px-2 py-1 bg-yellow-500 text-white rounded mr-2">Sửa</button><button className="px-2 py-1 bg-red-500 text-white rounded">Xóa</button></td></tr>))}</tbody></table>
        }
      </div>
    </div>
  );
}
