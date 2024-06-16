# Server Management Application

This project is a Server Management Application that allows you to manage and monitor servers using a web interface. The application is built with a Node.js backend and a React frontend. It includes features such as server listing, adding, editing, deleting, and uploading CSV files to import server data into MongoDB.

## Features

- **Server Listing**: View a list of servers with their details.
- **Add Server**: Add new servers to the list.
- **Edit Server**: Edit existing server details.
- **Delete Server**: Delete servers from the list.
- **File Upload**: Upload CSV files to import server data into MongoDB.
- **Search**: Search servers by system name or IP address.

## Project Structure

```
server-management-app/
├── client/
│   ├── public/
│   │   └── tag.jpg
│   ├── src/
│   │   ├── components/
│   │   │   ├── FileUpload.js
│   │   │   ├── ServerForm.js
│   │   │   └── ServerList.js
│   │   ├── App.js
│   │   └── index.js
├── uploads/
├── server.js
└── package.json
```

## Prerequisites

- Node.js (v18.x)
- npm (v6.x or later)
- MongoDB (v6.0.6)

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/server-management-app.git
   cd server-management-app
   ```

2. **Install Backend Dependencies**

   ```bash
   npm install
   ```

3. **Setup MongoDB**

   - Ensure MongoDB is installed and running.

4. **Setup Environment Variables**

   - Create a `.env` file in the `client` directory with the following content:

     ```
     REACT_APP_BACKEND_URL=http://localhost:5000
     ```

5. **Install Frontend Dependencies**

   ```bash
   cd client
   npm install
   ```

6. **Move the Logo File**

   - Ensure the logo file `tag.jpg` is in the `client/public` directory.

## Usage

1. **Run the Backend**

   ```bash
   npm start
   ```

2. **Run the Frontend**

   ```bash
   cd client
   npm start
   ```

3. **Access the Application**

   - Open your browser and go to `http://localhost:3000`

## Backup and Restore

### Backup

To backup MongoDB data and application files, run the following script:

```bash
./backup.sh
```

### Restore

To restore MongoDB data and application files, run the following script:

```bash
./restore.sh
```

## Deployment

For deployment, ensure that the backend and frontend are properly configured and running on a server. You can use PM2 to manage the processes:

1. **Start the Backend with PM2**

   ```bash
   pm2 start server.js --name backend
   ```

2. **Start the Frontend with PM2**

   ```bash
   cd client
   pm2 start npm --name frontend -- start
   ```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any changes or suggestions.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Node.js](https://nodejs.org/)
- [React](https://reactjs.org/)
- [MongoDB](https://www.mongodb.com/)
- [PM2](https://pm2.keymetrics.io/)
