import { createServer } from "http";
import express from "express";


const PORT = 3000;
const app = express();
app.use(express.json());
app.use(express.static("static"));

let id = 1;
let messages = [];


app.use(function (req, res, next) {
  console.log("HTTP request", req.method, req.url, req.body);
  next();
});

// app.post("/", function (req, res, next) {
//   res.json(req.body);
//   next();
// });

app.post("/api/messages/", function (req, res) {
  const { content, author } = req.body;

  if (!content || !author) {
    return res.status(422).json({ error: "Invalid arguments" });
  }

  const newMessage = {
    id: id++,
    content,
    author,
    upvote: 0,
    downvote: 0,
  };

  messages.push(newMessage);
  res.status(200).json(newMessage);
});

app.get("/api/messages/", function (req, res) {
  console.log(messages);
  res.status(200).json({
    total: messages.length,
    messages,
  });
});

app.get("/api/messages/:id/", function (req, res) {
  const { id } = req.params;
  // console.log(messages);
  const mID = parseInt(id,10);
  const message = messages.find((msg) => msg.id === mID);
  // console.log(message);
  if (!message) {
    console.log("false");
    return res.status(404).json({ error: "Message id does not exist" });
  }

  res.status(200).json(message);
});


app.patch("/api/messages/:id/", function (req, res) {
  const { id } = req.params;
  const { action } = req.body;
  const mID = parseInt(id,10);

  const message = messages.find((msg) => msg.id === mID);

  if (!message) {
    return res.status(404).json({ error: "Message id does not exist" });
  }

  if (action === "upvote") {
    message.upvote += 1;
  } else if (action === "downvote") {
    message.downvote += 1;
  } else {
    return res.status(422).json({ error: "Invalid action" });
  }

  res.status(200).json(message);
});


app.delete("/api/messages/:id/", function (req, res) {
  const { id } = req.params;
  const mID = parseInt(id,10);
  const messageIndex = messages.findIndex((msg) => msg.id === mID);

  if (messageIndex === -1) {
    return res.status(404).json({ error: "Message id does not exist" });
  }

  const deletedMessage = messages.splice(messageIndex, 1)[0];
  res.status(200).json(deletedMessage);
});




export const server = createServer(app).listen(PORT, function (err) {
  if (err) console.log(err);
  else console.log("HTTP server on http://localhost:%s", PORT);
});
