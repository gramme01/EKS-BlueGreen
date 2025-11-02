const express = require('express');
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 8080;
const version = process.env.APP_VERSION || '0.0.0';

const registry = new client.Registry();
client.collectDefaultMetrics({ register: registry });

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'request duration',
  labelNames: ['method', 'route', 'code'],
  buckets: [0.005,0.01,0.025,0.05,0.1,0.25,0.5,1,2,5]
});
registry.registerMetric(httpRequestDuration);

app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer({ method: req.method });
  res.on('finish', () => end({ route: req.path, code: res.statusCode }));
  next();
});

app.get('/healthz', (req,res)=> res.json({ status:'ok', version }));
app.get('/version', (req,res)=> res.send(version));
app.get('/metrics', async (req,res)=>{
  res.set('Content-Type', registry.contentType);
  res.end(await registry.metrics());
});
app.get('/', (req,res)=> res.send(`Hello from ${version}`));

app.listen(port, ()=> console.log(`API v${version} on :${port}`));
