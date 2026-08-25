import { createServer } from "http";
import express from "express";
import multer from "multer";
import Datastore from "nedb";
import path from "path";
const messages = new Datastore({ filename: 'db/messages.db', autoload: true, timestampData : true})
const users = new Datastore({ filename: 'db/users.db', autoload: true });

const upload = multer({ dest: 'uploads/' });
const PORT = 3000;

const app = express();

app.use(express.urlencoded({ extended: false }));
app.use(express.json());

app.use(express.static("static"));

app.use(function (req, res, next) {
  console.log("HTTP request", req.method, req.url, req.body);
  next();
});

// const Message = (function () {
//   let id = 0;
//   return function item(message) {
//     this._id = id++;
//     this.content = message.content;
//     this.username = message.username;
//     this.upvote = 0;
//     this.downvote = 0;
//   };
// })();


// Create

// app.post("/api/users/", function (req, res, next) {
//   if (req.body.username in users)
//     return res
//       .status(409)
//       .end("Username:" + req.body.username + " already exists");
//   users[req.body.username] = req.picture;
//   return res.redirect("/");
// });

// app.post("/api/users/", function (req, res, next) {
//   users.findOne({ username: req.body.username }, function (err, existingUser) {
//     if (existingUser) {
//       return res.status(409).end("Username:" + req.body.username + " already exists");
//     }

//     users.insert({ username: req.body.username, picture: req.body.picture }, function (err, newUser) {
//       if (err) return next(err);
//       return res.redirect("/");
//     });
//   });
// });

app.post('/api/users/', upload.single('picture'), function (req, res, next) {
  const username = req.body.username;
  
  users.findOne({ username }, function (err, existingUser) {
    if (existingUser) {
      return res.status(409).end("Username:" + username + " already exists");
    }

    const userProfile = {
      username,
      picturePath: req.file.path,    // Save the path to the uploaded file
      mimetype: req.file.mimetype    // Store the mimetype for content-type header
    };

    users.insert(userProfile, function (err, newUser) {
      if (err) return next(err);
      return res.redirect('/');
    });
  });
});

// save the profile image
app.get('/api/users/:username/profile/picture/', function (req, res, next) {
  const username = req.params.username;

  users.findOne({ username }, function (err, user) {
    if (err || !user) {
      return res.status(404).end('Username ' + username + ' does not exist');
    }

    res.setHeader('Content-Type', user.mimetype);
    res.sendFile(path.resolve(user.picturePath));  // Serve the file from the filesystem
  });
});

// app.post("/api/messages/", function (req, res, next) {
//   const message = new Message(req.body);
//   messages.unshift(message);
//   return res.json(message);
// });

app.post("/api/messages/", function (req, res, next) {
  const message = {
    content: req.body.content,
    username: req.body.username,
    upvote: 0,
    downvote: 0
  };
  
  messages.insert(message, function (err, newMessage) {
    if (err) return next(err);
    return res.json(newMessage);
  });
});



// Read

// app.get("/api/messages/", function (req, res, next) {
//   return res.json(messages.slice(req.query.page * 5, req.query.page * 5 + 5));
// });

app.get("/api/messages/", function (req, res, next) {
  messages.find({})
    .sort({ createdAt: -1 })  
    .limit(5)                 
    .exec(function (err, docs) {
      if (err) return next(err);
      return res.json(docs);
    });
});


// app.get("/api/users/", function (req, res, next) {
//   return res.json(Object.keys(users));
// });

app.get("/api/users/", function (req, res, next) {
  users.find({}, function (err, userDocs) {
    if (err) return next(err);
    const usernames = userDocs.map(user => user.username);
    return res.json(usernames);
  });
});

// Update

// app.patch("/api/messages/:id/", function (req, res, next) {
//   const index = messages.findIndex(function (message) {
//     return message._id == req.params.id;
//   });
//   if (index === -1)
//     return res
//       .status(404)
//       .end("Message id:" + req.params.id + " does not exists");
//   const message = messages[index];
//   switch (req.body.action) {
//     case "upvote":
//       message.upvote += 1;
//       break;
//     case "downvote":
//       message.downvote += 1;
//       break;
//   }
//   return res.json(message);
// });

app.patch("/api/messages/:id/", function (req, res, next) {
  const update = {};
  if (req.body.action === "upvote") update.$inc = { upvote: 1 };
  else if (req.body.action === "downvote") update.$inc = { downvote: 1 };
  
  messages.update({ _id: req.params.id }, update, {}, function (err, numUpdated) {
    if (err) return next(err);
    if (numUpdated === 0) return res.status(404).end("Message id:" + req.params.id + " does not exist");
    messages.findOne({ _id: req.params.id }, function (err, updatedMessage) {
      if (err) return next(err);
      return res.json(updatedMessage);
    });
  });
});



// Delete

// app.delete("/api/messages/:id/", function (req, res, next) {
//   const index = messages.findIndex(function (message) {
//     return message._id == req.params.id;
//   });
//   if (index === -1)
//     return res
//       .status(404)
//       .end("Message id:" + req.params.id + " does not exists");
//   const message = messages[index];
//   messages.splice(index, 1);
//   return res.json(message);
// });

app.delete("/api/messages/:id/", function (req, res, next) {
  messages.remove({ _id: req.params.id }, {}, function (err, numRemoved) {
    if (err) return next(err);
    if (numRemoved === 0) return res.status(404).json({ error: "Message id: " + req.params.id + " does not exist" });

    // Return a success message in JSON format
    return res.status(200).json({ success: true, message: "Message deleted successfully." });
  });
});

// Start server

export const server = createServer(app).listen(PORT, function (err) {
  if (err) console.log(err);
  else console.log("HTTP server on http://localhost:%s", PORT);
});
