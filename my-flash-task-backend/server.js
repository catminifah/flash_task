import express from 'express';
import cors from 'cors';
import { createClient } from 'redis';
import { v4 as uuidv4 } from 'uuid';
import 'dotenv/config';

const app = express();
app.use(cors());
app.use(express.json());

const client = createClient({
  url: process.env.REDIS_URL,
  password: process.env.REDIS_PASSWORD,
});

client.on('error', (err) => console.log('Redis Client Error', err));

async function start() {
  await client.connect();

  // GET all tasks
  app.get('/tasks', async (req, res) => {
    try {
      const keys = await client.keys('task:*');
      const tasks = [];
      for (const key of keys) {
        const data = await client.hGetAll(key);
        if (!data || Object.keys(data).length === 0) continue;
        tasks.push({
          id: key.replace('task:', ''),
          title: data.title || '',
          description: data.description || '',
          created_at: data.created_at || null,
          tag: data.tag || null,
          priority: data.priority || null,
          due_date: data.due_date || null,
        });
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
      const {
        title = '',
        description = '',
        created_at = new Date().toISOString(),
        tag = '',
        priority = '',
        due_date = '',
      } = req.body;

      await client.hSet(`task:${id}`, {
        title,
        description,
        created_at,
        tag,
        priority,
        due_date,
      });

      res.status(201).json({ id, title, description, created_at, tag, priority, due_date });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // UPDATE task (PUT)
  app.put('/tasks/:id', async (req, res) => {
    try {
      const id = req.params.id;
      const key = `task:${id}`;
      const exists = await client.exists(key);
      if (!exists) return res.status(404).json({ error: 'Task not found' });

      const {
        title,
        description,
        tag,
        priority,
        due_date,
      } = req.body;

      const updateObj = {};
      if (title !== undefined) updateObj.title = title;
      if (description !== undefined) updateObj.description = description;
      if (tag !== undefined) updateObj.tag = tag;
      if (priority !== undefined) updateObj.priority = priority;
      if (due_date !== undefined) updateObj.due_date = due_date;

      if (Object.keys(updateObj).length > 0) {
        await client.hSet(key, updateObj);
      }

      const data = await client.hGetAll(key);
      res.json({
        id,
        title: data.title,
        description: data.description,
        created_at: data.created_at,
        tag: data.tag,
        priority: data.priority,
        due_date: data.due_date,
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // DELETE
  app.delete('/tasks/:id', async (req, res) => {
    try {
      await client.del(`task:${req.params.id}`);
      res.send('Task deleted');
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Backend API running on port ${port}`);
  });
}

start().catch(console.error);
