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
                const response = await axios.get(`${apiUrl}/servers`);
                setServers(response.data);
            } catch (error) {
                console.error('Error fetching servers:', error);
            }
        };
        fetchServers();
    }, [apiUrl]);

    const addServer = async (server) => {
        if (window.confirm('Are you sure you want to add this server?')) {
            try {
                const response = await axios.post(`${apiUrl}/servers`, server);
                setServers([...servers, response.data]);
            } catch (error) {
                console.error('Error adding server:', error);
            }
        }
    };

    const updateServer = async (id, updatedServer) => {
        if (window.confirm('Are you sure you want to update this server?')) {
            try {
                const response = await axios.put(`${apiUrl}/servers/${id}`, updatedServer);
                setServers(servers.map(server => (server._id === id ? response.data : server)));
            } catch (error) {
                console.error('Error updating server:', error);
            }
        }
    };

    const deleteServer = async (id) => {
        if (Array.isArray(id)) {
            await Promise.all(id.map(async (serverId) => {
                try {
                    await axios.delete(`${apiUrl}/servers/${serverId}`);
                    setServers(servers.filter(server => server._id !== serverId));
                } catch (error) {
                    console.error('Error deleting server:', error);
                }
            }));
        } else {
            try {
                await axios.delete(`${apiUrl}/servers/${id}`);
                setServers(servers.filter(server => server._id !== id));
            } catch (error) {
                console.error('Error deleting server:', error);
            }
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
