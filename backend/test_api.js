const axios = require('axios');

async function testAPI() {
  try {
    const response = await axios.get('http://localhost:3000/api/specialties');
    console.log('API Response:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('API Error:', error.response?.data || error.message);
  }
}

testAPI();