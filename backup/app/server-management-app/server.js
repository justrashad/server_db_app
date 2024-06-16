const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const fs = require('fs');
const csv = require('csv-parser');
const stripBomBuffer = require('strip-bom-buffer');

const app = express();
const port = process.env.BACKEND_PORT || 5000;

// Enable CORS with specific settings
app.use(cors({
    origin: '*', // Allow requests from any origin
    methods: ['GET', 'POST', 'PUT', 'DELETE'], // Allow these HTTP methods
    allowedHeaders: ['Content-Type', 'Authorization'] // Allow these headers
}));

app.use(bodyParser.json());

mongoose.connect('mongodb://localhost:27017/serverdb', { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log('MongoDB connected'))
    .catch(err => console.error('MongoDB connection error:', err));

const ServerSchema = new mongoose.Schema({
    systemName: { type: String, unique: true },
    ipAddress: { type: String, unique: true },
    function: String,
    pillar: String,
    frequency: String,
    analyst: String,
    majVersion: String,
    offset: String,
    maintDate: Date,
    time: String,
    reboot: Boolean,
    custEmail: String,
    customer: String
});

const Server = mongoose.model('Server', ServerSchema);

// Multer setup for file upload
const upload = multer({ dest: 'uploads/' });

app.get('/servers', async (req, res) => {
    const servers = await Server.find();
    res.json(servers);
});

app.post('/servers', async (req, res) => {
    try {
        const newServer = new Server(req.body);
        await newServer.save();
        res.json(newServer);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.put('/servers/:id', async (req, res) => {
    try {
        const updatedServer = await Server.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(updatedServer);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.delete('/servers/:id', async (req, res) => {
    await Server.findByIdAndDelete(req.params.id);
    res.json({ message: 'Server deleted' });
});

app.post('/upload', upload.single('file'), async (req, res) => {
    if (!req.file) {
        console.error('No file uploaded');
        return res.status(400).json({ error: 'No file uploaded' });
    }

    const filePath = req.file.path;

    console.log('Reading file:', filePath);

    // Read file contents and strip BOM
    fs.readFile(filePath, (err, data) => {
        if (err) {
            console.error('Error reading file:', err);
            return res.status(500).json({ error: 'Error reading file' });
        }

        const strippedData = stripBomBuffer(data);
        const servers = [];

        // Process the stripped data with csv-parser
        require('stream').Readable.from(strippedData)
            .pipe(csv())
            .on('data', (row) => {
                console.log('Row:', row);  // Log each row
                if (row.systemName && row.ipAddress) {
                    servers.push({
                        systemName: row.systemName,
                        ipAddress: row.ipAddress,
                        function: row.function,
                        pillar: row.pillar,
                        frequency: row.frequency,
                        analyst: row.analyst,
                        majVersion: row.majVersion,
                        offset: row.offset,
                        maintDate: row.maintDate ? new Date(row.maintDate) : null,
                        time: row.time,
                        reboot: row.reboot === 'Y',
                        custEmail: row.custEmail,
                        customer: row.customer
                    });
                }
            })
            .on('end', async () => {
                try {
                    console.log('Servers to Insert:', servers);  // Log data to be inserted
                    await Server.insertMany(servers);
                    console.log('File imported successfully');
                    res.json({ message: 'File imported successfully' });
                } catch (error) {
                    console.error('Error inserting data:', error);  // Log any error
                    res.status(400).json({ error: error.message });
                } finally {
                    fs.unlinkSync(filePath); // Delete the file after processing
                }
            })
            .on('error', (error) => {
                console.error('Error processing file:', error);
                res.status(500).json({ error: 'Error processing file' });
            });
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
