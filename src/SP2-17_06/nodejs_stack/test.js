const assert = require('assert');
const http = require('http');
const server = require('./index');

// Give the server 1 second to start and then make the health check request
setTimeout(() => {
  http.get('http://localhost:3000/health', (res) => {
    assert.strictEqual(res.statusCode, 200);
    console.log('Tests passed successfully!');
    server.close();
    process.exit(0);
  }).on('error', (err) => {
    console.error('Test failed:', err);
    server.close();
    process.exit(1);
  });
}, 1000);
