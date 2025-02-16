import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import axios from 'axios';

dotenv.config();

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json({ limit: '50mb' }));

const HUGGING_FACE_API_URL = "https://api-inference.huggingface.co/models/pratikskarnik/face_problems_analyzer";

app.post('/api/analyze', async (req, res) => {
  try {
    const { image } = req.body;
    
    // Convert base64 to binary
    const base64Data = image.replace(/^data:image\/\w+;base64,/, "");
    const imageBuffer = Buffer.from(base64Data, 'base64');

    const response = await axios.post(HUGGING_FACE_API_URL, imageBuffer, {
      headers: {
        'Authorization': `Bearer ${process.env.HUGGING_FACE_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to analyze image' });
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});