import { type NextFunction, type Request, type Response } from 'express';
import { requestCounter } from './requestCounter';
import { activeRequestsGauge } from './activeRequests';
import { httpRequestDuration } from './requestTime';

export const metricsMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const startTime = Date.now();

  if (req.path !== '/metrics') activeRequestsGauge.inc();

  res.on('finish', () => {
    const endTime = Date.now();

    requestCounter.inc({
      method: req.method,
      route:
        req.route && req.baseUrl ? `${req.baseUrl}${req.route.path}` : req.path,
      status_code: res.statusCode,
    });

    const duration = endTime - startTime;
    httpRequestDuration.observe(
      {
        method: req.method,
        route:
          req.route && req.baseUrl
            ? `${req.baseUrl}${req.route.path}`
            : req.path,
        code: res.statusCode,
      },
      duration,
    );

    if (req.path !== '/metrics') activeRequestsGauge.dec();
  });
  next();
};
