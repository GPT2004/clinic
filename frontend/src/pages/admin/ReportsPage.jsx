import React, {useEffect, useState} from 'react';
import { getReportSummary } from '../../services/reportService';
export default function ReportsPage(){
  const [summary,setSummary]=useState(null);
  useEffect(()=>{ (async ()=>{ const r = await getReportSummary(); if(r && r.data) setSummary(r.data); })(); },[]);
  return (<div className="p-6"><h1 className="text-2xl font-bold mb-4">Báo cáo</h1><div className="bg-white p-4 rounded shadow">{summary? (<pre className='whitespace-pre-wrap'>{JSON.stringify(summary, null, 2)}</pre>): 'Không có dữ liệu'}</div></div>);
}
