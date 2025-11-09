import React, {useEffect, useState} from 'react';
import { getTodayAppointments } from '../../services/doctorService';
export default function TodayAppointmentsPage(){ const [list,setList]=useState([]); useEffect(()=>{ (async ()=>{ const r = await getTodayAppointments(); if(r && r.data) setList(r.data); })(); },[]); return (<div className='p-6'><h1 className='text-2xl font-bold mb-4'>Lịch hôm nay</h1><div className='bg-white p-4 rounded shadow'>{list.length? list.map(i=>(<div key={i.id} className='py-2 border-b'>{i.time} - {i.patientName}</div>)) : 'Không có'}</div></div>); }
