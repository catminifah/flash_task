import express from 'express';
import { createClient } from 'redis';
import { v4 as uuidv4 } from 'uuid';

const app = express();
app.use(express.json());

const client = createClient({
  url: process.env.REDIS_URL,
  password: process.env.REDIS_PASSWORD,
});

client.on('error', (err) => console.log('Redis Client Error', err));

await client.connect();

// GET all tasks
app.get('/tasks', async (req, res) => {
  try {
    const keys = await client.keys('task:*');
    const tasks = [];
    for (const key of keys) {
      const task = await client.hGetAll(key);
      tasks.push({ id: key.replace('task:', ''), ...task });
    }
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// CREATE task
app.post('/tasks', async (req, res) => {
  try {
    const id = uuidv4();
    const { title, description } = req.body;
    const created_at = new Date().toISOString();

    await client.hSet(`task:${id}`, {
      title,
      description,
      created_at,
    });

    res.status(201).json({ id, title, description, created_at });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE task
app.delete('/tasks/:id', async (req, res) => {
  try {
    await client.del(`task:${req.params.id}`);
    res.send('Task deleted');
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(3000, () => {
  console.log('Backend API running on http://localhost:3000');
});
