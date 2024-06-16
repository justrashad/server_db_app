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
        <form onSubmit={handleSubmit}>
            <input type="text" name="systemName" value={server.systemName} onChange={handleChange} placeholder="System Name" required />
            <input type="text" name="ipAddress" value={server.ipAddress} onChange={handleChange} placeholder="IP Address" required />
            <input type="text" name="function" value={server.function} onChange={handleChange} placeholder="Function" required />
            <input type="text" name="pillar" value={server.pillar} onChange={handleChange} placeholder="Pillar" required />
            <input type="text" name="frequency" value={server.frequency} onChange={handleChange} placeholder="Frequency" required />
            <input type="text" name="analyst" value={server.analyst} onChange={handleChange} placeholder="Analyst" required />
            <input type="text" name="majVersion" value={server.majVersion} onChange={handleChange} placeholder="Major Version" required />
            <input type="text" name="offset" value={server.offset} onChange={handleChange} placeholder="Offset" required />
            <input type="date" name="maintDate" value={server.maintDate} onChange={handleChange} placeholder="Maintenance Date" required />
            <input type="text" name="time" value={server.time} onChange={handleChange} placeholder="Time" required />
            <label>
                Reboot:
                <input type="checkbox" name="reboot" checked={server.reboot} onChange={(e) => setServer({ ...server, reboot: e.target.checked })} />
            </label>
            <input type="email" name="custEmail" value={server.custEmail} onChange={handleChange} placeholder="Customer Email" required />
            <input type="text" name="customer" value={server.customer} onChange={handleChange} placeholder="Customer" required />
            <button type="submit">{editingServer ? 'Update' : 'Add'} Server</button>
        </form>
    );
};

export default ServerForm;
