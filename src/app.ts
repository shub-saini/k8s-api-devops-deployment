import express from 'express';
import routes from './routes';
import errorHandler from './middlewares/error.middleware';
import client from 'prom-client';
import { metricsMiddleware } from './middlewares/metrics.middeware';
import cookieParser from 'cookie-parser';
import logger from './config/logger';

const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use(cookieParser());
app.use(metricsMiddleware);
app.use('/api', routes);
app.use(errorHandler);

app.get('/', (req, res) => {
  res.status(200).send('Test endpoint for cicd');
});

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

app.listen(PORT, () => {
  logger.info('Server started', { port: PORT });
});

export default app;
