const XLSX = require('xlsx');
const path = require('path');

const filePath = path.join(__dirname, 'test_medicines.xlsx');
const workbook = XLSX.readFile(filePath);
const ws = workbook.Sheets[workbook.SheetNames[0]];
const data = XLSX.utils.sheet_to_json(ws, { header: 1 });

const headers = data[0].map(h => (h || '').toString().toLowerCase().trim());
const rows = data.slice(1);

const results = [];
const errors = [];

rows.forEach((row, idx) => {
  const rowNum = idx + 2;
  const item = {};
  try {
    headers.forEach((h, colIndex) => {
      const value = row[colIndex];
      if (h === 'expiry_date') {
        if (value !== undefined && value !== null && value !== '') {
          let dateObj = null;
          if (typeof value === 'number') {
            const parsed = XLSX.SSF.parse_date_code(value);
            if (parsed && parsed.y) dateObj = new Date(parsed.y, parsed.m - 1, parsed.d);
          } else if (value instanceof Date) {
            dateObj = value;
          } else if (typeof value === 'string') {
            const str = value.trim();
            const dm = str.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/);
            if (dm) {
              const d = parseInt(dm[1], 10);
              const m = parseInt(dm[2], 10);
              const y = parseInt(dm[3], 10);
              dateObj = new Date(y, m - 1, d);
            } else {
              const tmp = new Date(str);
              if (!isNaN(tmp.getTime())) dateObj = tmp;
            }
          }

          if (!dateObj || isNaN(dateObj.getTime())) {
            throw new Error('Invalid expiry date');
          }

          // Format using local date components to avoid timezone shift
          const y = dateObj.getFullYear();
          const m = String(dateObj.getMonth() + 1).padStart(2, '0');
          const d = String(dateObj.getDate()).padStart(2, '0');
          item.expiry_date = `${y}-${m}-${d}`;
        }
      } else {
        // map other fields simply
        item[h] = value;
      }
    });

    results.push(item);
  } catch (err) {
    errors.push(`Row ${rowNum}: ${err.message}`);
  }
});

console.log('Parsed rows:');
console.log(results);
console.log('\nErrors:');
console.log(errors);
