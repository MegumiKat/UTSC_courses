import { rmSync, readFileSync } from "fs";
import { createServer } from "https";
import express from "express";
import Datastore from "nedb";
import session from "express-session";
import { parse, serialize } from "cookie";
import { compare, genSalt, hash } from "bcrypt";
import { body, param, query, validationResult } from 'express-validator';
import validator from "validator";


const PORT = 3000;

const app = express();

app.use(express.json());

const privateKey = readFileSync('server.key');
const certificate = readFileSync('server.crt');
const config = {
  key: privateKey,
  cert: certificate
};

function isAuthenticated(req, res, next) {
  if (!req.username) return res.status(401).end("Authentication failed");
  next();
};


const checkUsername = function (req, res, next) {
  if (!validator.isAlphanumeric(req.body.username)) return res.status(400).end("bad input");
  next();
};

const sanitizeContent = function (req, res, next) {
  req.body.content = validator.escape(req.body.content);
  next();
}

const checkId = function (req, res, next) {
  if (!validator.isAlphanumeric(req.params.id)) return res.status(400).end("bad input");
  next();
};

const escapeHtml = (unsafe) => {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
};

const users = new Datastore({ filename: "db/users.db", autoload: true });
const messages = new Datastore({
  filename: "db/messages.db",
  autoload: true,
  timestampData: true,
});

app.use(
  session({
    secret: "please change this secret",
    resave: false,
    saveUninitialized: true,
    cookie: {
      httpOnly: true,
      secure: true,
      sameSite: 'strict'
    }
  })
);

app.use(function (req, res, next) {
  req.username = req.session.username
  // const cookies = parse(req.headers.cookie || "");
  // req.username = cookies.username ? cookies.username : null;
  console.log("HTTPS request", req.username, req.method, req.url, req.body);
  next();
});

app.use((req, res, next) => {
  if (!req.secure) {
    return res.redirect(`https://${req.headers.host}${req.url}`);
  }
  next();
});


// curl -H "Content-Type: application/json" -X POST -d '{"username":"alice","password":"alice"}' -c cookie.txt localhost:3000/signup/
app.post("/signup/", checkUsername, [
  body('password').isLength({ min: 3 }).withMessage('Password must be at least 3 characters long')
], function (req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  const username = escapeHtml(req.body.username);
  const password = escapeHtml(req.body.password);

  users.findOne({ _id: username }, function (err, user) {
    if (err) return res.status(500).end(err);
    if (user)
      return res.status(409).end("username " + username + " already exists");

    const saltRounds = 10;
    genSalt(saltRounds, function (err, salt) {
      if (err) return res.status(500).end(err);

      hash(password, salt, function (err, hashedPassword) {
        if (err) return res.status(500).end(err);

        users.update(
          { _id: username },
          { _id: username, password: hashedPassword },
          { upsert: true },
          function (err) {
            if (err) return res.status(500).end(err);
            // initialize cookie
            res.setHeader(
              "Set-Cookie",
              serialize("username", username, {
                path: "/",
                maxAge: 60 * 60 * 24 * 7,
                httpOnly: false,
                secure: true,
                sameSite: 'strict'
              }),
            );
            req.session.username = username;
            return res.json(username);
          },
        );
      });
    });
  });
});

// curl -H "Content-Type: application/json" -X POST -d '{"username":"alice","password":"alice"}' -c cookie.txt localhost:3000/signin/
app.post("/signin/", checkUsername, [
  body('password').isString().withMessage('Password must be a string')
], function (req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  const username = req.body.username;
  const password = req.body.password;
  // retrieve user from the database
  users.findOne({ _id: username }, function (err, user) {
    if (err) return res.status(500).end(err);
    if (!user) return res.status(401).end("sign up first");

    compare(password, user.password, function (err, result) {
      // result is true is the password matches the salted hash from the database
      if (err) return res.status(500).end(err);
      if (!result) return res.status(401).end("password incorrect");

      req.session.username = username;


      // initialize cookie
      res.setHeader(
        "Set-Cookie",
        serialize("username", username, {
          path: "/",
          maxAge: 60 * 60 * 24 * 7,
          httpOnly: false, // 防止 JavaScript 访问该 cookie
          secure: true, // 仅在 HTTPS 连接中发送
          sameSite: 'strict'
        }),
      );
      return res.json(username);
    });
  });
});

// curl -b cookie.txt -c cookie.txt localhost:3000/signout/
app.get("/signout/", function (req, res, next) {
  res.setHeader(
    "Set-Cookie",
    serialize("username", "", {
      path: "/",
      maxAge: 60 * 60 * 24 * 7, // 1 week in number of seconds
      httpOnly: false, 
      secure: true, 
      sameSite: 'strict'
    }),
  );
  res.redirect("/");
});



// curl -b cookie.txt -H "Content-Type: application/json" -X POST -d '{"content":"hello world!"}' localhost:3000/api/messages/
app.post("/api/messages/", isAuthenticated, sanitizeContent, checkUsername, function (req, res, next) {
  // const errors = validationResult(req);
  // if (!errors.isEmpty()) {
  //   return res.status(400).json({ errors: errors.array() });
  // }
  // const sanitizedContent = escapeHtml(req.body.content);
  const message = {
    content: req.body.content,
    username: req.body.username,
    upvote: 0,
    downvote: 0,
  };

  messages.insert(message, function (err, message) {
    if (err) return res.status(500).end(err);
    return res.json(message);
  });
});

// curl -b cookie.txt localhost:3000/api/messages/
app.get("/api/messages/", [
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('page').optional().isInt({ min: 0 }).withMessage('Page must be a non-negative integer')
], function (req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  const limit = Math.max(5, (req.query.limit) ? parseInt(req.query.limit) : 5);
  const page = (req.query.page) || 0;
  messages
    .find({})
    .sort({ createdAt: -1 })
    .skip(page * limit)
    .limit(limit)
    .exec(function (err, messages) {
      if (err) return res.status(500).end(err);
      return res.json(messages.reverse());
    });
});

// curl -b cookie.txt -H "Content-Type: application/json" -X PATCH -d '{"action":"upvote"}' localhost:3000/api/messages/a66mKb0o3pnnYig4/
app.patch("/api/messages/:id/", isAuthenticated, checkId, [body('action').isIn(['upvote', 'downvote']).withMessage('Action must be either upvote or downvote')
], function (req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  if (["upvote", "downvote"].indexOf(req.body.action) == -1)
    return res.status(400).end("unknown action" + req.body.action);
  messages.findOne({ _id: req.params.id }, function (err, message) {
    if (err) return res.status(500).end(err);
    if (!message)
      return res
        .status(404)
        .end("Message id #" + req.params.id + " does not exists");
    const update = {};
    message[req.body.action] += 1;
    update[req.body.action] = 1;
    messages.update(
      { _id: message._id },
      { $inc: update },
      { multi: false },
      function (err, num) {
        res.json(message);
      },
    );
  });
});

// curl -b cookie.txt -X DELETE localhost:3000/api/messages/a66mKb0o3pnnYig4/
app.delete("/api/messages/:id/", isAuthenticated, checkId, function (req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  messages.findOne({ _id: req.params.id }, function (err, message) {
    if (err) return res.status(500).end(err);
    if (!message)
      return res
        .status(404)
        .end("Message id #" + req.params.id + " does not exists");

    if (message.username != req.username)
      return res.status(403).end("You are not the author of this message");

    messages.remove(
      { _id: message._id },
      { multi: false },
      function (err, num) {
        res.json(message);
      },
    );
  });
});

app.use(express.static("static"));

// This is for testing purpose only
export function createTestDb(db) {
  messages = new Datastore({
    filename: "testdb/messages.db",
    autoload: true,
    timestampData: true,
  });
  users = new Datastore({
    filename: "testdb/users.db",
    autoload: true,
  });
}

// This is for testing purpose only
export function deleteTestDb(db) {
  rmSync("testdb", { recursive: true, force: true });
}

// This is for testing purpose only
export function getMessages(callback) {
  return messages
    .find({})
    .sort({ createdAt: -1 })
    .exec(function (err, messages) {
      if (err) return callback(err, null);
      return callback(err, messages.reverse());
    });
}

// This is for testing purpose only
export function getUsers(callback) {
  return users
    .find({})
    .sort({ createdAt: -1 })
    .exec(function (err, users) {
      if (err) return callback(err, null);
      return callback(err, users.reverse());
    });
}

export const server = createServer(config, app).listen(PORT, function (err) {
  if (err) console.log(err);
  else console.log("HTTPS server on https://localhost:%s", PORT);
});
