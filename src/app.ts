import express from 'express';
import routes from './routes';
import errorHandler from './middlewares/error.middleware';
import client from 'prom-client';
import { metricsMiddleware } from './middlewares/metrics.middeware';
import cookieParser from 'cookie-parser';

const app = express();

app.use(express.json());
app.use(cookieParser());
app.use(metricsMiddleware);
app.use('/api', routes);
app.use(errorHandler);

app.get('/healthz', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

app.get('/metrics', async (req, res) => {
  const metrics = await client.register.metrics();
  res.set('Content-Type', client.register.contentType);
  res.send(metrics);
});

export default app;
