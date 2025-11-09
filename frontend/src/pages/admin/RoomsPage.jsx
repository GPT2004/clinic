import React, { useEffect, useState } from "react";

export default function RoomsPage() {
  const [rooms, setRooms] = useState([]);

  useEffect(() => {
    // TODO: fetch rooms tại đây
    setRooms([]);
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Quản lý phòng khám</h1>
      <div className="bg-white p-4 rounded shadow">
        {rooms.length ? (
          rooms.map((r) => <div key={r.id}>{r.name}</div>)
        ) : (
          "Chưa có phòng"
        )}
      </div>
    </div>
  );
}
