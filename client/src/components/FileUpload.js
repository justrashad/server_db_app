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
            const response = await axios.post(`${process.env.REACT_APP_BACKEND_URL}/upload`, formData, {
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
