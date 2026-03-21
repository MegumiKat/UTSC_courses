import {createServer} from 'https';
import {rmSync, readFileSync} from "fs";
import express from 'express';
import multer from 'multer';
import path from 'path';
import Datastore from 'nedb';
import fs from 'fs';
import {fileURLToPath} from 'url';
import session from "express-session";
import {parse, serialize} from "cookie";
import {compare, genSalt, hash} from "bcrypt";
import {body, param, query, validationResult} from 'express-validator';
import validator from "validator";

const comments = new Datastore({filename: 'db/comments.db', autoload: true, timestampData: true});
const images = new Datastore({filename: 'db/images.db', autoload: true});
const users = new Datastore({filename: "db/users.db", autoload: true});

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const upload = multer({dest: 'uploads/'});
const PORT = 3000;
const app = express();

const privateKey = readFileSync('../server.key');
const certificate = readFileSync('../server.crt');
const config = {
    key: privateKey,
    cert: certificate
};

const escapeHtml = (unsafe) => {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
};

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

app.use(express.urlencoded({extended: false}));
app.use(express.json());
app.use(express.static('static'));

app.use('/uploads', express.static('uploads'));

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


const isAuthenticated = function (req, res, next) {
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

app.post("/signup/", checkUsername, [
    body('password').isLength({min: 3}).withMessage('Password must be at least 3 characters long')
], function (req, res, next) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({errors: errors.array()});
    }
    const username = escapeHtml(req.body.username);
    const password = escapeHtml(req.body.password);

    users.findOne({_id: username}, function (err, user) {
        if (err) return res.status(500).end(err);
        if (user)
            return res.status(409).end("username " + username + " already exists");

        const saltRounds = 10;
        genSalt(saltRounds, function (err, salt) {
            if (err) return res.status(500).end(err);

            hash(password, salt, function (err, hashedPassword) {
                if (err) return res.status(500).end(err);

                users.update(
                    {_id: username},
                    {_id: username, password: hashedPassword},
                    {upsert: true},
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

app.post("/signin/", checkUsername, [
    body('password').isString().withMessage('Password must be a string')
], function (req, res, next) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({errors: errors.array()});
    }
    const username = req.body.username;
    const password = req.body.password;
    // retrieve user from the database
    users.findOne({_id: username}, function (err, user) {
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


// Get all images
app.get('/api/images/', isAuthenticated, (req, res) => {

    images.find({}).sort({date: 1}).exec((err, docs) => {
        if (err) {
            res.status(500).json({error: 'Database error'});
        } else {
            res.json(docs);
        }
    });
});

// Get all users
app.get('/api/users', isAuthenticated, (req, res) => {
    users.find({}, (err, docs) => {
        if (err) {
            res.status(500).json({error: 'Database error'});
        } else {
            res.json(docs);
        }
    });
});

// Get a specific image by ID
app.get('/api/images/:id', isAuthenticated, checkId,(req, res) => {
    const {id} = req.params;

    // 查找 author 是 userId 的图片
    images.find({author: id}).sort({date: 1}).exec((err, docs) => {
        if (err) {
            return res.status(500).json({error: 'Database error'});
        }
        if (docs.length === 0) {  // 没有找到任何图片
            return res.status(404).json({error: 'No images found for this user'});
        }
        res.json(docs);  // 返回找到的图片
    });
});

// Add a new image
app.post('/api/images', isAuthenticated, upload.single('file'), (req, res) => {
    const {title, author} = req.body;
    const file = req.file;


    if (!title || !author || !file) {
        return res.status(400).json({error: 'fill'});
    }

    const filePath = `/uploads/${file.filename}`;

    const newImage = {
        title,
        author,
        url: filePath,
        date: new Date(),
    };

    images.insert(newImage, (err, doc) => {
        if (err) {
            res.status(500).json({error: 'error'});
        } else {
            res.json(doc);
        }
    });
});

// Delete an image by ID
app.delete('/api/images/:id', checkId, (req, res) => {
    const {id} = req.params;

    images.findOne({_id: id}, (err, doc) => {
        if (err || !doc) {
            return res.status(500).json({error: 'Database error or image not found'});
        }

        fs.unlink(path.join(__dirname, doc.url), (err) => {
            if (err) {
                console.error('Error deleting file:', err);
            }
        });

        images.remove({_id: id}, {}, (err, numRemoved) => {
            if (err) {
                res.status(500).json({error: 'Database error'});
            } else {
                res.json({success: true, numRemoved});
            }
        });
    });
});

// Get all comments for a specific image
app.get('/api/comments', isAuthenticated, (req, res) => {
    const {imageId} = req.query;
    if (!imageId) {
        return res.status(400).json({error: 'Missing imageId parameter'});
    }

    comments.find({imageId}, (err, docs) => {
        if (err) {
            res.status(500).json({error: 'Database error'});
        } else {
            res.json(docs);
        }
    });
});

// Add a comment to an image
app.post('/api/comments', isAuthenticated, sanitizeContent, (req, res) => {
    const {imageId, author, content} = req.body;

    if (!imageId || !author || !content) {
        return res.status(400).json({error: 'Missing required fields'});
    }

    const newComment = {
        imageId,
        author,
        content,
        date: new Date(),
    };

    comments.insert(newComment, (err, doc) => {
        if (err) {
            res.status(500).json({error: 'Database error'});
        } else {
            res.json(doc);
        }
    });
});

// Delete a comment by ID
app.delete('/api/comments/:id', isAuthenticated, checkId, (req, res) => {
    const {id} = req.params;

    comments.remove({_id: id}, {}, (err, numRemoved) => {
        if (err) {
            res.status(500).json({error: 'Database error'});
        } else {
            res.json({success: true, numRemoved});
        }
    });
});

// Start the server
export const server = createServer(config, app).listen(PORT, function (err) {
    if (err) console.log(err);
    else console.log("HTTPS server on https://localhost:%s", PORT);
});
