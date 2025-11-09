import React, {useEffect, useState} from 'react';
import PageWrapper from './_AdminWrapper';
import { getAllMedicines, createMedicine, updateMedicine, deleteMedicine } from '../../services/medicineService';

export default function MedicinesPage(){
  const [meds,setMeds]=useState([]);
  const [name,setName]=useState('');
  useEffect(()=>{ (async ()=>{ const r = await getAllMedicines(); if(r && r.data) setMeds(r.data); })(); },[]);

  const add = async()=>{ if(!name) return alert('Nhập tên thuốc'); await createMedicine({name}); setName(''); const r=await getAllMedicines(); if(r && r.data) setMeds(r.data); }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Quản lý thuốc</h1>
      <div className="bg-white p-4 rounded shadow mb-4">
        <div className="flex gap-2"><input className="p-2 border rounded flex-1" value={name} onChange={e=>setName(e.target.value)} placeholder="Tên thuốc..." /><button onClick={add} className="px-4 py-2 bg-blue-600 text-white rounded">Thêm</button></div>
      </div>
      <div className="bg-white p-4 rounded shadow">
        <table className="min-w-full">
          <thead><tr className="text-left text-sm text-gray-600"><th className="py-2">#</th><th className="py-2">Tên</th><th className="py-2">Số lượng</th><th className="py-2">Hành động</th></tr></thead>
          <tbody>{(meds||[]).map((m,i)=>(<tr key={m.id||i} className="border-t"><td className="py-2">{i+1}</td><td className="py-2">{m.name}</td><td className="py-2">{m.stock||'-'}</td><td className="py-2"><button className="px-2 py-1 bg-yellow-500 text-white rounded mr-2">Sửa</button><button className="px-2 py-1 bg-red-500 text-white rounded">Xóa</button></td></tr>))}</tbody>
        </table>
      </div>
    </div>
  );
}
