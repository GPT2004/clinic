import React, {useEffect, useState} from 'react';
import { getAllAppointments } from '../../services/appointmentService';
export default function AppointmentManagementPage(){ const [list,setList]=useState([]); useEffect(()=>{ (async ()=>{ const r = await getAllAppointments(); if(r && r.data) setList(r.data); })(); },[]); return (<div className='p-6'><h1 className='text-2xl font-bold mb-4'>Quản lý lịch hẹn</h1><div className='bg-white p-4 rounded shadow'>{list.length? list.map(a=>(<div key={a.id} className='py-2 border-b'>{a.time} - {a.patientName}</div>)):'Không có lịch'}</div></div>); }
