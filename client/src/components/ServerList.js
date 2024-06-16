import React, { useState } from 'react';

const ServerList = ({ servers, setEditingServer, deleteServer }) => {
    const [selectedServers, setSelectedServers] = useState([]);

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
    };

    const handleSelectServer = (id) => {
        setSelectedServers((prevSelected) =>
            prevSelected.includes(id)
                ? prevSelected.filter((serverId) => serverId !== id)
                : [...prevSelected, id]
        );
    };

    const handleDeleteSelected = () => {
        if (window.confirm('Are you sure you want to delete the selected servers?')) {
            selectedServers.forEach((id) => deleteServer(id));
            setSelectedServers([]);
        }
    };

    const handleDelete = (id) => {
        if (window.confirm('Are you sure you want to delete this server?')) {
            deleteServer(id);
        }
    };

    return (
        <div style={{ backgroundColor: 'white', color: 'black' }}>
            <h2 style={{ color: 'red' }}>Server List</h2>
            <button
                onClick={handleDeleteSelected}
                disabled={selectedServers.length === 0}
                style={{ backgroundColor: 'red', color: 'white', marginBottom: '10px' }}
            >
                Delete Selected
            </button>
            <table border="1" style={{ backgroundColor: 'white', color: 'black' }}>
                <thead>
                    <tr>
                        <th>Select</th>
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
                    {servers.map((server) => (
                        <tr key={server._id}>
                            <td>
                                <input
                                    type="checkbox"
                                    checked={selectedServers.includes(server._id)}
                                    onChange={() => handleSelectServer(server._id)}
                                />
                            </td>
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
                                <button
                                    onClick={() => setEditingServer(server)}
                                    style={{ backgroundColor: 'red', color: 'white' }}
                                >
                                    Edit
                                </button>
                                <button
                                    onClick={() => handleDelete(server._id)}
                                    style={{ backgroundColor: 'red', color: 'white' }}
                                >
                                    Delete
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default ServerList;
