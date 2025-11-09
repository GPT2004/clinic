import React, {useEffect, useState} from 'react';
import PageWrapper from './_AdminWrapper';

export default function AdminDashboard(){
  const [stats, setStats] = useState({users:0, doctors:0, appointments:0, rooms:0});
  useEffect(()=>{ (async ()=>{ /* TODO: call reportService.getReportSummary */ })(); },[]);
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Admin Dashboard</h1>
      <div className="grid grid-cols-4 gap-4">
        <div className="p-4 bg-white rounded shadow"><div className="text-sm text-gray-500">Users</div><div className="text-2xl font-bold">{stats.users}</div></div>
        <div className="p-4 bg-white rounded shadow"><div className="text-sm text-gray-500">Doctors</div><div className="text-2xl font-bold">{stats.doctors}</div></div>
        <div className="p-4 bg-white rounded shadow"><div className="text-sm text-gray-500">Appointments</div><div className="text-2xl font-bold">{stats.appointments}</div></div>
        <div className="p-4 bg-white rounded shadow"><div className="text-sm text-gray-500">Rooms</div><div className="text-2xl font-bold">{stats.rooms}</div></div>
      </div>
    </div>
  );
}
