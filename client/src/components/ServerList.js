import React from 'react';

const ServerList = ({ servers, setEditingServer, deleteServer }) => {
    const formatDate = (dateString) => {
        const date = new Date(dateString);
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
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
