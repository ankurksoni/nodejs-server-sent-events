# nodejs-server-sent-events
An app with Node.js engine, express.js, server sent events.

## Subscribers

* Open multiple console and run below command,
    ```bash
    curl -H Accept:text/event-stream http://localhost:3000/events
    ```
* All these request are waiting for any input to be sent from the server.

## producers

* open a single tab and run below command,
    ```bash
    curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"info": "Some info", "source": "Some source"}'\
    -s http://localhost:3000/facts
    ```
* Make sure the above subscribers are ready and listening.
* Upon firing above command, the other subscriber console will get this data.

## Queries
* To get the no. of clients connected to the server, use below command,
    ```bash
    curl -X GET http://localhost:3000/status
    ```
* To get the facts sent to the server, use below command,
    ```bash
    curl -X GET http://localhost:3000/facts
    ```

## Project in nutshell
<img src="./server-sent-events.svg" alt="Git" />