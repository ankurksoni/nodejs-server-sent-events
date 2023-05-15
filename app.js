const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const compression = require('compression');

const app = express();
const PORT = 3000;
const { SSE_HEADERS } = require('./utility/constants');

let clients = [];
let facts = [];

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(compression());

app.get('/health', (req, res) => res.json({ status: 'healthy' }));
app.get('/status', (req, res) => res.json({ clients: clients.length }));

app.get('/events', eventsHandler);

app.post('/facts', addFact);
app.get('/facts', getFact);

app.listen(PORT, () => {
  console.log(`Facts Events service listening at http://localhost:${PORT}`)
});

function eventsHandler(req, res, next) {
  res.writeHead(200, SSE_HEADERS);
  res.write(`data: ${JSON.stringify(`CONNECTED TO SERVER FOR SSEvents`)}\n\n`);
  
  const clientId = Date.now();
  const newClient = { id: clientId, response: res };
  clients.push(newClient);

  req.on('close', () => {
    clients = clients.filter(client => client.id !== clientId);
    console.log(`${clientId} Connection closed, Total live clients: ${clients.length}`);
  });
}

async function addFact(req, res, next) {
  const newFact = req.body;
  facts.push(newFact);
  res.json({ result: 'fact added.' })
  notifyConnectedClients(newFact);
}

function notifyConnectedClients(newFact) {
  clients.forEach(client => client.response.write(`data: ${JSON.stringify(newFact)}\n\n`))
}

async function getFact(req, res, next) {
  res.json({ result: { facts } })
}

