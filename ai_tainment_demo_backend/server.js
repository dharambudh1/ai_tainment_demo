const express = require('express');
const cors = require('cors');
const os = require('os');

const app = express();
app.use(cors());
app.use(express.json());

// GET / - Root route
app.get('/', (req, res) => {
    res.send('Hello World!');
});

// Sample dataset (replace this with PostgreSQL, MongoDB, Prisma, etc.)
const subjectsData = Array.from({ length: 50 }, (_, i) => {
    const id = `subject_${i + 1}`;
    return {
        subjectId: id,
        subjectTitle: `Subject ${i + 1}`,
        topicCount: 50,
        topics: Array.from({ length: 50 }, (_, j) => ({
            topicId: `${id}_topic_${j + 1}`,
            topicTitle: `Topic ${j + 1}`,
        })),
    };
});

// GET /api/subjects?page=1&limit=10
app.get('/api/subjects', (req, res) => {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const offset = (page - 1) * limit;

    const paginatedSubjects = subjectsData
        .slice(offset, offset + limit)
        .map(({ topics, ...rest }) => ({ ...rest, topics: [] })); // omit nested topics in list view

    res.json(paginatedSubjects);
});

// GET /api/subjects/:subjectId/topics?page=1&limit=10
app.get('/api/subjects/:subjectId/topics', (req, res) => {
    const { subjectId } = req.params;
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const offset = (page - 1) * limit;

    const subject = subjectsData.find((s) => s.subjectId === subjectId);
    if (!subject) {
        return res.status(404).json({ error: 'Subject not found' });
    }

    const paginatedTopics = subject.topics.slice(offset, offset + limit);
    res.json(paginatedTopics);
});

// Helper to get local Wi-Fi / LAN IP address
function getNetworkIp() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    return null;
}

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, '0.0.0.0', () => {
    const address = server.address();
    const actualPort = typeof address === 'string' ? address : address.port;
    const networkIp = getNetworkIp();

    console.log(`\n🚀 Backend server running:`);
    console.log(`   ➜  Local:   http://localhost:${actualPort}`);
    if (networkIp) {
        console.log(`   ➜  Network: http://${networkIp}:${actualPort} (use this for physical phone)`);
    }
    console.log();
});

