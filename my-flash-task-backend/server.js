import express from 'express';
import { createClient } from 'redis';

const app = express();
app.use(express.json());

const client = createClient({
  url: 'redis://default:bcTU5KogqBFQC4pAtthk0ltstOaO8i7Z@redis-16650.c305.ap-south-1-1.ec2.redns.redis-cloud.com:16650'
});

client.on('error', (err) => console.log('Redis Client Error', err));

await client.connect();

await client.sendCommand(['REDISQL.CREATE_DB', 'DB']);

app.get('/tasks', async (req, res) => {
  try {
    const result = await client.sendCommand([
      'REDISQL.EXEC',
      'DB',
      'SELECT * FROM tasks',
    ]);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/tasks', async (req, res) => {
  try {
    const { id, title, description, created_at } = req.body;
    const sql = `INSERT INTO tasks VALUES ('${id}', '${title}', '${description}', '${created_at}')`;
    await client.sendCommand(['REDISQL.EXEC', 'DB', sql]);
    res.status(201).send('Task added');
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/tasks/:id', async (req, res) => {
  try {
    const sql = `DELETE FROM tasks WHERE id = '${req.params.id}'`;
    await client.sendCommand(['REDISQL.EXEC', 'DB', sql]);
    res.send('Task deleted');
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

async function createTable() {
  const createTableSQL = `CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    title TEXT,
    description TEXT,
    created_at TEXT
  )`;
  await client.sendCommand(['REDISQL.EXEC', 'DB', createTableSQL]);
}

createTable();

app.listen(3000, () => {
  console.log('Backend API running on http://localhost:3000');
});
