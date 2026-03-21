# Microblog REST API Documentation

## Message API

### Create a new message

- URL: `POST /api/messages/`
  - content-type: `application/json`
  - body: object
    - content: (string) the content of the message
    - author: (string) the authors username
- response: 200
  - content-type: `application/json`
  - body: object
    - id: (string) the message id
    - content: (string) the content of the message
    - author: (string) the authors username
    - upvote: (int) the number of upvotes
    - downvote: (int) the number of downvotes
- response: 422
  - body: invalid arguments

```
$ curl -X POST
       -H "Content-Type: `application/json`"
       -d '{"content":"hello world","author":"me"}
       http://localhost:3000/api/messages/'
```

### Retrieve all messages

- URL: `GET /api/messages/`
- response: 200
  - content-type: `application/json`
  - body: object
    - total: (number) total number of messages
    - messages: list of objects
      - id: (string) the message id
      - content: (string) the content of the message
      - author: (string) the authors username
      - upvote: (int) the number of upvotes
      - downvote: (int) the number of downvotes

```
$ curl http://localhost:3000/api/messages/
```

### Retrieve a specified message

- URL: `GET /api/messages/:id/`
- response: 200
  - content-type: `application/json`
  - body: object
    - id: (string) the message id
    - content: (string) the content of the message
    - author: (string) the authors username
    - upvote: (int) the number of upvotes
    - downvote: (int) the number of downvotes
- response: 404
  - body: message id does not exists

```
$ curl http://localhost:3000/api/messages/1/
```

### Upvote/downvote a message

- URL: `PATCH /api/messages/:id/`
  - content-type: `application/json`
  - body: object
    - action: (string) either `upvote` or `downvote`
- response: 200
  - content-type: `application/json`
  - body: object
    - id: (string) the message id
    - content: (string) the content of the message
    - author: (string) the authors username
    - upvote: (int) the number of upvotes
    - downvote: (int) the number of downvotes
- response: 422
  - body: invalid arguments
- response: 404
  - body: message :id does not exists

```
$ curl -X PATCH
       -H 'Content-Type: application/json'
       -d '{"action":"upvote"}
       http://localhost:3000/api/messages/1/'
```

### Delete a message

- URL: `DELETE /api/messages/:id/`
- response: 200
  - content-type: `application/json`
  - body: object
    - id: (string) the message id
    - content: (string) the content of the message
    - author: (string) the authors username
    - upvote: (int) the number of upvotes
    - downvote: (int) the number of downvotes
- response: 404
  - body: message :id does not exists

```
$ curl -X DELETE
       http://localhost:3000/api/messages/1/
```
