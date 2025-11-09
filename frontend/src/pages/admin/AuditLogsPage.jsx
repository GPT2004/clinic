import React, {useEffect, useState} from 'react';
import PageWrapper from './_AdminWrapper';

export default function AuditLogsPage(){
  const [logs,setLogs]=useState([]);
  useEffect(()=>{ (async ()=>{ /* TODO: fetch audit logs */ setLogs([]); })(); },[]);
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Audit Logs</h1>
      <div className="bg-white p-4 rounded shadow">
        <div className="text-sm text-gray-600 mb-2">Recent actions</div>
        {logs.length===0 ? <div className="text-gray-500">Không có logs</div> : <ul className="space-y-2">{logs.map(l=>(<li key={l.id} className='border p-2 rounded'>{l.message}</li>))}</ul>}
      </div>
    </div>
  );
}
