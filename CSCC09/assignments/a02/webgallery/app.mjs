import { createServer } from 'http';
import express from 'express';
import multer from 'multer';
import path from 'path';
import Datastore from 'nedb';
import fs from 'fs';
import { fileURLToPath } from 'url';

const comments = new Datastore({ filename: 'db/comments.db', autoload: true, timestampData: true });
const images = new Datastore({ filename: 'db/images.db', autoload: true });

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const upload = multer({ dest: 'uploads/' });
const PORT = 3000;
const app = express();

app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(express.static('static'));

app.use('/uploads', express.static('uploads'));

app.use(function (req, res, next) {
    console.log("HTTP request", req.method, req.url, req.body);
    next();
});


// Get all images
app.get('/api/images', (req, res) => {
    images.find({}).sort({ date: 1 }).exec((err, docs) => { 
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else {
            res.json(docs);  
        }
    });
});

// Get a specific image by ID
app.get('/api/images/:id', (req, res) => {
    const { id } = req.params;
    images.findOne({ _id: id }, (err, doc) => {
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else if (!doc) {
            res.status(404).json({ error: 'Image not found' });
        } else {
            res.json(doc);
        }
    });
});

// Add a new image
app.post('/api/images', upload.single('file'), (req, res) => {
    const { title, author } = req.body;
    const file = req.file;

   
    if (!title || !author || !file) {
        return res.status(400).json({ error: 'fill' });
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
            res.status(500).json({ error: 'error' });
        } else {
            res.json(doc); 
        }
    });
});

// Delete an image by ID
app.delete('/api/images/:id', (req, res) => {
    const { id } = req.params;

    images.findOne({ _id: id }, (err, doc) => {
        if (err || !doc) {
            return res.status(500).json({ error: 'Database error or image not found' });
        }

        fs.unlink(path.join(__dirname, doc.url), (err) => {
            if (err) {
                console.error('Error deleting file:', err);
            }
        });

        images.remove({ _id: id }, {}, (err, numRemoved) => {
            if (err) {
                res.status(500).json({ error: 'Database error' });
            } else {
                res.json({ success: true, numRemoved });
            }
        });
    });
});

// Get all comments for a specific image
app.get('/api/comments', (req, res) => {
    const { imageId } = req.query;
    if (!imageId) {
        return res.status(400).json({ error: 'Missing imageId parameter' });
    }

    comments.find({ imageId }, (err, docs) => {
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else {
            res.json(docs);
        }
    });
});

// Add a comment to an image
app.post('/api/comments', (req, res) => {
    const { imageId, author, content } = req.body;

    if (!imageId || !author || !content) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const newComment = {
        imageId,
        author,
        content,
        date: new Date(),
    };

    comments.insert(newComment, (err, doc) => {
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else {
            res.json(doc);
        }
    });
});

// Delete a comment by ID
app.delete('/api/comments/:id', (req, res) => {
    const { id } = req.params;

    comments.remove({ _id: id }, {}, (err, numRemoved) => {
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else {
            res.json({ success: true, numRemoved });
        }
    });
});

// Start the server
export const server = createServer(app).listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});


