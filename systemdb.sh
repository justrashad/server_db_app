#!/bin/bash

# Define color codes
GREEN_TEXT="\033[0;32m"
RESET_TEXT="\033[0m"
RED_TEXT="\033[0;31m"

# Define log file
LOG_FILE="setup.log"

# Define backup directory
BACKUP_DIR="backup"
MONGO_BACKUP_DIR="$BACKUP_DIR/mongo"
APP_BACKUP_DIR="$BACKUP_DIR/app"

# MongoDB version
MONGO_VERSION="6.0.6"
MONGO_PACKAGE="mongodb-linux-x86_64-ubuntu2004-$MONGO_VERSION.tgz"

# Node.js version
NODE_VERSION="18.x"

# Function to print debug messages in green
debug_message() {
    echo -e "${GREEN_TEXT}$1${RESET_TEXT}" | tee -a $LOG_FILE
}

# Function to print error messages in red
error_message() {
    echo -e "${RED_TEXT}$1${RESET_TEXT}" | tee -a $LOG_FILE
}

# Function to check the last command status and exit if it failed
check_command_status() {
    if [ $? -ne 0 ]; then
        error_message "Error: $1 failed. Exiting."
        exit 1
    fi
}

# Function to backup MongoDB data
backup_mongo() {
    debug_message "Backing up MongoDB data..."
    mkdir -p $MONGO_BACKUP_DIR
    mongodump --out $MONGO_BACKUP_DIR | tee -a $LOG_FILE
    check_command_status "Backing up MongoDB data"
    debug_message "MongoDB data backup completed."
}

# Function to backup application files
backup_app_files() {
    debug_message "Backing up application files..."
    mkdir -p $APP_BACKUP_DIR
    cp -r server-management-app $APP_BACKUP_DIR | tee -a $LOG_FILE
    check_command_status "Backing up application files"
    debug_message "Application files backup completed."
}

# Function to install pm2 if not already installed
install_pm2() {
    if ! command -v pm2 &> /dev/null; then
        debug_message "Installing pm2..."
        sudo npm install -g pm2 | tee -a $LOG_FILE
        check_command_status "Installing pm2"
    else
        debug_message "pm2 is already installed."
    fi
}

# Function to stop frontend and backend processes if they are running
stop_pm2_processes() {
    debug_message "Stopping frontend and backend processes..."
    pm2 stop frontend || debug_message "Frontend process not running."
    pm2 stop backend || debug_message "Backend process not running."
}

# Function to install system dependencies
install_dependencies() {
    debug_message "Installing system dependencies..."

    # Update package list
    sudo apt-get update | tee -a $LOG_FILE
    check_command_status "Updating package list"

    # Install curl, wget, and other necessary tools
    sudo apt-get install -y curl wget gnupg yarn | tee -a $LOG_FILE
    check_command_status "Installing curl, wget, gnupg, and yarn"

    # Install Node.js and npm
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | sudo -E bash - | tee -a $LOG_FILE
        check_command_status "Setting up Node.js repository"
        sudo apt-get install -y nodejs | tee -a $LOG_FILE
        check_command_status "Installing Node.js and npm"
    else
        debug_message "Node.js is already installed."
    fi

    # Install npx if not already installed
    if ! command -v npx &> /dev/null; then
        sudo npm install -g npx | tee -a $LOG_FILE
        check_command_status "Installing npx"
    else
        debug_message "npx is already installed."
    fi

    # Install Git if not already installed
    if ! command -v git &> /dev/null; then
        sudo apt-get install -y git | tee -a $LOG_FILE
        check_command_status "Installing Git"
    else
        debug_message "Git is already installed."
    fi

    # Install libssl1.1 if not already installed
    if ! dpkg -l | grep -q libssl1.1; then
        wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb | tee -a $LOG_FILE
        sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb | tee -a $LOG_FILE
        check_command_status "Installing libssl1.1"
    else
        debug_message "libssl1.1 is already installed."
    fi
}

# Function to install MongoDB without authentication
install_mongodb() {
    debug_message "Installing MongoDB..."

    # Check if MongoDB is already installed
    if ! command -v mongod &> /dev/null; then
        # Download MongoDB packages
        wget -q https://fastdl.mongodb.org/linux/$MONGO_PACKAGE | tee -a $LOG_FILE
        check_command_status "Downloading MongoDB package"

        # Extract the package
        tar -zxvf $MONGO_PACKAGE | tee -a $LOG_FILE
        check_command_status "Extracting MongoDB package"

        # Move the extracted files to /usr/local/mongodb
        sudo mkdir -p /usr/local/mongodb
        sudo mv mongodb-linux-x86_64-ubuntu2004-$MONGO_VERSION/* /usr/local/mongodb
        check_command_status "Moving MongoDB files"

        # Create symbolic links for MongoDB binaries
        sudo ln -s /usr/local/mongodb/bin/* /usr/local/bin/
        check_command_status "Creating symbolic links for MongoDB binaries"

        # Create MongoDB data and log directories
        sudo mkdir -p /var/lib/mongo
        sudo mkdir -p /var/log/mongodb
        sudo chown -R `id -u` /var/lib/mongo
        sudo chown -R `id -u` /var/log/mongodb
        check_command_status "Creating MongoDB data and log directories"

        # Create a systemd service file for MongoDB
        if [ ! -f /etc/systemd/system/mongod.service ]; then
            cat <<EOL | sudo tee /etc/systemd/system/mongod.service
[Unit]
Description=MongoDB Database Server
Documentation=https://docs.mongodb.org/manual
After=network.target

[Service]
User=$USER
ExecStart=/usr/local/bin/mongod --config /usr/local/mongodb/mongod.conf
PIDFile=/var/run/mongodb/mongod.pid
LimitNOFILE=64000
TimeoutStopSec=5
PermissionsStartOnly=true
# file size
LimitFSIZE=infinity
# cpu time
LimitCPU=infinity
# virtual memory size
LimitAS=infinity
# open files
LimitNOFILE=64000
# processes/threads
LimitNPROC=64000
# locked memory
LimitMEMLOCK=infinity
# total threads (user+kernel)
TasksMax=infinity
TasksAccounting=false

[Install]
WantedBy=multi-user.target
EOL
            check_command_status "Creating systemd service file for MongoDB"
        else
            debug_message "MongoDB systemd service file already exists."
        fi

        # Create a MongoDB configuration file without authentication
        if [ ! -f /usr/local/mongodb/mongod.conf ]; then
            cat <<EOL | sudo tee /usr/local/mongodb/mongod.conf
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
storage:
  dbPath: /var/lib/mongo
  journal:
    enabled: true
processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod.pid
net:
  bindIp: 0.0.0.0
EOL
            check_command_status "Creating MongoDB configuration file"
        else
            debug_message "MongoDB configuration file already exists."
        fi

        # Reload systemd and start MongoDB
        sudo systemctl daemon-reload

        sudo systemctl start mongod
        check_command_status "Starting MongoDB"

        # Enable MongoDB to start on boot
        sudo systemctl enable mongod
        check_command_status "Enabling MongoDB to start on boot"
    else
        debug_message "MongoDB is already installed."
    fi

    debug_message "MongoDB installation and setup complete."
}

# Function to create /var/run/mongodb directory with correct permissions
create_mongodb_run_directory() {
    debug_message "Creating /var/run/mongodb directory with correct permissions..."
    sudo mkdir -p /var/run/mongodb
    sudo chown mongodb:mongodb /var/run/mongodb
    sudo chmod 755 /var/run/mongodb
    check_command_status "Creating /var/run/mongodb directory"
}

# Function to create the backend
create_backend() {
    debug_message "Setting up the backend..."

    # Create backend directory if it doesn't exist
    if [ ! -d server-management-app ]; then
        mkdir -p server-management-app
    fi
    cd server-management-app || { error_message "Failed to change directory to server-management-app"; exit 1; }

    # Initialize npm and install dependencies
    if [ ! -f package.json ]; then
        npm init -y | tee -a $LOG_FILE
        check_command_status "Initializing npm"
    fi

    npm install express mongoose body-parser cors pm2 multer fs csv-parser strip-bom-buffer | tee -a $LOG_FILE
    check_command_status "Installing backend dependencies"

    # Create server.js if it doesn't exist
    if [ ! -f server.js ]; then
        cat <<EOL > server.js
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
    console.log(\`Server running on port \${port}\`);
});
EOL
        check_command_status "Creating server.js"
    else
        debug_message "server.js already exists."
    fi

    # Start the backend server with pm2
    debug_message "Starting the backend server with pm2..."
    pm2 start server.js --name backend --update-env || pm2 restart backend --update-env
    check_command_status "Starting backend server with pm2"
    cd ..
}

# Function to create the frontend
create_frontend() {
    debug_message "Setting up the frontend..."

    # Create React app if it doesn't exist
    if [ ! -d client ]; then
        npx create-react-app client --use-npm --skip-git | tee -a $LOG_FILE
        check_command_status "Creating React app"
    fi
    cd client || { error_message "Failed to change directory to client"; exit 1; }

    # Install Axios and the missing Babel plugin
    npm install axios @babel/plugin-proposal-private-property-in-object --save-dev | tee -a $LOG_FILE
    check_command_status "Installing Axios and Babel plugin"

    # Create .env file for environment variables if it doesn't exist
    if [ ! -f .env ]; then
        echo "REACT_APP_BACKEND_URL=http://10.0.7.125:${BACKEND_PORT}" > .env
        check_command_status "Creating .env file"
    else
        debug_message ".env file already exists."
    fi

    # Create components directory if it doesn't exist
    mkdir -p src/components | tee -a $LOG_FILE
    check_command_status "Creating components directory"

    # Move the logo file to the public directory
    mkdir -p public
    cp /opt/systemdb/MDACC_Rev_RGB_TC_tag_V.jpg public/
    check_command_status "Moving logo file to public directory"

    # Create App.js with new color scheme and environment variable if it doesn't exist
    cat <<EOL > src/App.js
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import ServerForm from './components/ServerForm';
import ServerList from './components/ServerList';
import FileUpload from './components/FileUpload';

const App = () => {
    const [servers, setServers] = useState([]);
    const [editingServer, setEditingServer] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    const apiUrl = process.env.REACT_APP_BACKEND_URL;

    useEffect(() => {
        const fetchServers = async () => {
            try {
                const response = await axios.get(\`\${apiUrl}/servers\`);
                setServers(response.data);
            } catch (error) {
                console.error('Error fetching servers:', error);
            }
        };
        fetchServers();
    }, [apiUrl]);

    const addServer = async (server) => {
        try {
            const response = await axios.post(\`\${apiUrl}/servers\`, server);
            setServers([...servers, response.data]);
        } catch (error) {
            console.error('Error adding server:', error);
        }
    };

    const updateServer = async (id, updatedServer) => {
        try {
            const response = await axios.put(\`\${apiUrl}/servers/\${id}\`, updatedServer);
            setServers(servers.map(server => (server._id === id ? response.data : server)));
        } catch (error) {
            console.error('Error updating server:', error);
        }
    };

    const deleteServer = async (id) => {
        try {
            await axios.delete(\`\${apiUrl}/servers/\${id}\`);
            setServers(servers.filter(server => server._id !== id));
        } catch (error) {
            console.error('Error deleting server:', error);
        }
    };

    const filteredServers = servers.filter(server =>
        (server.systemName && server.systemName.toLowerCase().includes(searchTerm.toLowerCase())) ||
        (server.ipAddress && server.ipAddress.includes(searchTerm))
    );

    return (
        <div className="App" style={{ backgroundColor: 'black', color: 'white' }}>
            <div style={{ display: 'flex', alignItems: 'center', padding: '10px' }}>
                <img src="/MDACC_Rev_RGB_TC_tag_V.jpg" alt="Logo" style={{ height: '50px', marginRight: '10px' }} />
                <h1 style={{ color: 'red' }}>Server Management</h1>
            </div>
            <FileUpload />
            <input
                type="text"
                placeholder="Search..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={{ backgroundColor: 'white', color: 'black' }}
            />
            <ServerForm addServer={addServer} editingServer={editingServer} updateServer={updateServer} />
            <ServerList servers={filteredServers} setEditingServer={setEditingServer} deleteServer={deleteServer} />
        </div>
    );
};

export default App;
EOL
    check_command_status "Creating App.js"

    # Create FileUpload.js component
    cat <<EOL > src/components/FileUpload.js
import React, { useState } from 'react';
import axios from 'axios';

const FileUpload = () => {
    const [file, setFile] = useState(null);
    const [message, setMessage] = useState('');

    const handleFileChange = (e) => {
        setFile(e.target.files[0]);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!file) {
            alert('Please select a file to upload');
            return;
        }

        const formData = new FormData();
        formData.append('file', file);

        try {
            const response = await axios.post(\`\${process.env.REACT_APP_BACKEND_URL}/upload\`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
            setMessage(response.data.message);
        } catch (error) {
            console.error('Error uploading file:', error);
            setMessage('Error uploading file');
        }
    };

    return (
        <div>
            <form onSubmit={handleSubmit} style={{ backgroundColor: 'black', color: 'white' }}>
                <input type="file" onChange={handleFileChange} style={{ backgroundColor: 'white', color: 'black' }} />
                <button type="submit" style={{ backgroundColor: 'red', color: 'white' }}>Upload</button>
            </form>
            {message && <p style={{ color: 'red' }}>{message}</p>}
        </div>
    );
};

export default FileUpload;
EOL
    check_command_status "Creating FileUpload.js"

    # Create ServerForm.js if it doesn't exist
    if [ ! -f src/components/ServerForm.js ]; then
        cat <<EOL > src/components/ServerForm.js
import React, { useState, useEffect } from 'react';

const ServerForm = ({ addServer, editingServer, updateServer }) => {
    const [server, setServer] = useState({
        systemName: '',
        ipAddress: '',
        function: '',
        pillar: '',
        frequency: '',
        analyst: '',
        majVersion: '',
        offset: '',
        maintDate: '',
        time: '',
        reboot: false,
        custEmail: '',
        customer: ''
    });

    useEffect(() => {
        if (editingServer) {
            setServer(editingServer);
        }
    }, [editingServer]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setServer({ ...server, [name]: value });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (editingServer) {
            updateServer(editingServer._id, server);
        } else {
            addServer(server);
        }
        setServer({
            systemName: '',
            ipAddress: '',
            function: '',
            pillar: '',
            frequency: '',
            analyst: '',
            majVersion: '',
            offset: '',
            maintDate: '',
            time: '',
            reboot: false,
            custEmail: '',
            customer: ''
        });
    };

    return (
        <form onSubmit={handleSubmit} style={{ backgroundColor: 'black', color: 'white' }}>
            <input type="text" name="systemName" value={server.systemName} onChange={handleChange} placeholder="System Name" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="ipAddress" value={server.ipAddress} onChange={handleChange} placeholder="IP Address" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="function" value={server.function} onChange={handleChange} placeholder="Function" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="pillar" value={server.pillar} onChange={handleChange} placeholder="Pillar" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="frequency" value={server.frequency} onChange={handleChange} placeholder="Frequency" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="analyst" value={server.analyst} onChange={handleChange} placeholder="Analyst" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="majVersion" value={server.majVersion} onChange={handleChange} placeholder="Major Version" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="offset" value={server.offset} onChange={handleChange} placeholder="Offset" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="date" name="maintDate" value={server.maintDate} onChange={handleChange} placeholder="Maintenance Date" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="time" value={server.time} onChange={handleChange} placeholder="Time" required style={{ backgroundColor: 'white', color: 'black' }} />
            <label>
                Reboot:
                <input type="checkbox" name="reboot" checked={server.reboot} onChange={(e) => setServer({ ...server, reboot: e.target.checked })} style={{ backgroundColor: 'white', color: 'black' }} />
            </label>
            <input type="email" name="custEmail" value={server.custEmail} onChange={handleChange} placeholder="Customer Email" required style={{ backgroundColor: 'white', color: 'black' }} />
            <input type="text" name="customer" value={server.customer} onChange={handleChange} placeholder="Customer" required style={{ backgroundColor: 'white', color: 'black' }} />
            <button type="submit" style={{ backgroundColor: 'red', color: 'white' }}>{editingServer ? 'Update' : 'Add'} Server</button>
        </form>
    );
};

export default ServerForm;
EOL
        check_command_status "Creating ServerForm.js"
    else
        debug_message "ServerForm.js already exists."
    fi

    # Create ServerList.js if it doesn't exist
    if [ ! -f src/components/ServerList.js ]; then
        cat <<EOL > src/components/ServerList.js
import React from 'react';

const ServerList = ({ servers, setEditingServer, deleteServer }) => {
    const formatDate = (dateString) => {
        const date = new Date(dateString);
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const year = date.getFullYear();
        return \`\${month}/\${day}/\${year}\`;
    };

    return (
        <div style={{ backgroundColor: 'white', color: 'black' }}>
            <h2 style={{ color: 'red' }}>Server List</h2>
            <table border="1" style={{ backgroundColor: 'white', color: 'black' }}>
                <thead>
                    <tr>
                        <th>System Name</th>
                        <th>IP Address</th>
                        <th>Function</th>
                        <th>Pillar</th>
                        <th>Frequency</th>
                        <th>Analyst</th>
                        <th>Major Version</th>
                        <th>Offset</th>
                        <th>Maintenance Date</th>
                        <th>Time</th>
                        <th>Reboot</th>
                        <th>Customer Email</th>
                        <th>Customer</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {servers.map(server => (
                        <tr key={server._id}>
                            <td>{server.systemName}</td>
                            <td>{server.ipAddress}</td>
                            <td>{server.function}</td>
                            <td>{server.pillar}</td>
                            <td>{server.frequency}</td>
                            <td>{server.analyst}</td>
                            <td>{server.majVersion}</td>
                            <td>{server.offset}</td>
                            <td>{formatDate(server.maintDate)}</td>
                            <td>{server.time}</td>
                            <td>{server.reboot ? 'Yes' : 'No'}</td>
                            <td>{server.custEmail}</td>
                            <td>{server.customer}</td>
                            <td>
                                <button onClick={() => setEditingServer(server)} style={{ backgroundColor: 'red', color: 'white' }}>Edit</button>
                                <button onClick={() => deleteServer(server._id)} style={{ backgroundColor: 'red', color: 'white' }}>Delete</button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default ServerList;
EOL
        check_command_status "Creating ServerList.js"
    else
        debug_message "ServerList.js already exists."
    fi

    # Build the React app
    npm run build
    check_command_status "Building React app"

    # Serve the React app with pm2
    debug_message "Starting the frontend server with pm2..."
    pm2 start npm --name frontend -- start || pm2 restart frontend --update-env
    check_command_status "Starting frontend server with pm2"
    cd ..
}

# Function to ensure MongoDB is running
ensure_mongodb_running() {
    debug_message "Ensuring MongoDB is running..."

    if ! pgrep -x "mongod" > /dev/null; then
        sudo systemctl start mongod
        check_command_status "Starting MongoDB"
    else
        debug_message "MongoDB is already running."
    fi
}

# Cleanup function
cleanup() {
    debug_message "Cleaning up temporary files..."
    rm -f $MONGO_PACKAGE
    rm -f libssl1.1_1.1.1f-1ubuntu2_amd64.deb
    check_command_status "Cleaning up temporary files"
}

# Main script execution
BACKEND_PORT=${1:-5000}
FRONTEND_PORT=${2:-3000}

stop_pm2_processes
backup_mongo
backup_app_files
install_dependencies
install_pm2
install_mongodb
create_mongodb_run_directory
ensure_mongodb_running
create_backend
create_frontend
cleanup

debug_message "Setup complete. The backend is running on port $BACKEND_PORT and the frontend is running on port $FRONTEND_PORT."
