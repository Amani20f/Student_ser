import http from 'http';

const urls = [
    'http://127.0.0.1:8000/storage/study_schedules/YZif8ZU1DhwMA13JqdW5EhJoF3bOvYhOPgpbFidI.png',
    'http://127.0.0.1:8000/storage/receipts/RZiJf8p8ubUc4AFeIy1jtTkhMQcSDlyCVxnIl3lP.jpg',
    'http://127.0.0.1:8000/storage/requests/glAJuFQb4cipqituvrjlgwjpzjoZRMInJO3eZzDs.jpg',
    'http://127.0.0.1:8000/storage/applications/identity/DAyY3q7TO3fPsfMvWvY9bk1lJSigws6Nez9mKxTn.jpg'
];

async function checkUrl(url) {
    return new Promise((resolve) => {
        const req = http.request(url, {
            method: 'GET',
            headers: {
                'Origin': 'http://localhost:5000'
            }
        }, (res) => {
            const allowOrigin = res.headers['access-control-allow-origin'];
            if (res.statusCode === 200 && allowOrigin === '*') {
                resolve({ url, status: 'PASS', code: res.statusCode, cors: allowOrigin });
            } else {
                resolve({ url, status: 'FAIL', code: res.statusCode, cors: allowOrigin || 'Missing' });
            }
        });

        req.on('error', (e) => {
            resolve({ url, status: 'FAIL', error: e.message });
        });

        req.end();
    });
}

async function run() {
    for (const url of urls) {
        const result = await checkUrl(url);
        console.log(`URL: ${result.url}`);
        console.log(`Status: ${result.status}`);
        console.log(`HTTP Code: ${result.code}`);
        console.log(`CORS Header: ${result.cors}`);
        if (result.error) console.log(`Error: ${result.error}`);
        console.log('---');
    }
}

run();
