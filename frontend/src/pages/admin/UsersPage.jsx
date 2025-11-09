import React, {useEffect, useState} from 'react';
import { getAllUsers } from '../../services/userService';

export default function UsersPage(){
  const [users,setUsers]=useState([]);
  useEffect(()=>{ (async ()=>{ const r = await getAllUsers(); if(r && r.data) setUsers(r.data); })(); },[]);
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Quản lý người dùng</h1>
      <div className="bg-white p-4 rounded shadow">
        <table className="min-w-full">
          <thead><tr className="text-left text-sm text-gray-600"><th className="py-2">#</th><th className="py-2">Tên</th><th className="py-2">Email</th><th className="py-2">Vai trò</th></tr></thead>
          <tbody>{(users||[]).map((u,i)=>(<tr key={u.id} className="border-t"><td className="py-2">{i+1}</td><td className="py-2">{u.fullName||u.name}</td><td className="py-2">{u.email}</td><td className="py-2">{u.role}</td></tr>))}</tbody>
        </table>
      </div>
    </div>
  );
}
