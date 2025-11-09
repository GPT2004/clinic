import React, {useEffect, useState} from 'react';
import { getAppointmentsByPatient } from '../../services/appointmentService';
export default function AppointmentsPage(){ const [list,setList]=useState([]);
useEffect(()=>{ (async ()=>{ const r = await getAppointmentsByPatient(1); if(r && r.data) setList(r.data); })(); },[]);
return (<div className='p-6'><h1 className='text-2xl font-bold mb-4'>Lịch hẹn của tôi</h1><div className='bg-white p-4 rounded shadow'>{list.length? list.map(a=>(<div key={a.id} className='py-2 border-b'>{a.time} - {a.doctorName}</div>)):'Không có lịch hẹn'}</div></div>); }
