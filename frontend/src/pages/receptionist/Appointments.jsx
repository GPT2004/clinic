import React, {useEffect, useState} from 'react';
import { getAppointments, checkInAppointment } from '../../services/appointmentService';
export default function AppointmentsPage(){
  const [appts,setAppts]=useState([]);
  useEffect(()=>{ (async ()=>{ const r = await getAppointments(); if(r && r.data) setAppts(r.data); else if(Array.isArray(r)) setAppts(r); })(); },[]);
  return (<div className='p-6'><h1 className='text-2xl font-bold mb-4'>Danh sách lịch hẹn</h1><div className='bg-white p-4 rounded shadow'><ul>{appts.map(a=>(<li key={a.id} className='flex justify-between items-center border p-2 mb-2'><div>{a.patientName} — {a.time}</div><div><button onClick={async()=>{await checkInAppointment(a.id); alert('Checked in');}} className='px-2 py-1 bg-green-600 text-white rounded'>Check-in</button></div></li>))}</ul></div></div>);
}
