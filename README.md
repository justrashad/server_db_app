# Server Management Application

The Server Management Application is a comprehensive web-based tool designed to facilitate the management and monitoring of server infrastructure. This application provides a user-friendly interface for administrators to add, edit, delete, and search server records. It also supports bulk operations, such as mass deletion, and the ability to import server data from CSV files directly into MongoDB.

## Features

- **Server Listing**: View detailed information about each server, including system name, IP address, function, pillar, frequency, analyst, major version, offset, maintenance date, time, reboot status, customer email, and customer name.
- **Add Server**: Add new servers to the list with a straightforward form. Confirmation prompts ensure that actions are intentional.
- **Edit Server**: Modify existing server records with ease. Confirmation prompts help prevent accidental changes.
- **Delete Server**: Remove servers from the list individually, with confirmation prompts to ensure deliberate actions.
- **Mass Delete Servers**: Select multiple servers and delete them simultaneously, with a confirmation prompt to prevent mistakes.
- **File Upload**: Upload CSV files to bulk import server data into MongoDB. The application handles the parsing and insertion of data, ensuring a seamless import process.
- **Search**: Quickly find servers by system name or IP address using the search functionality.
- **Responsive Design**: The frontend is built with React, ensuring a responsive and dynamic user experience.

## Project Structure

```
server-management-app/
├── client/
│   ├── public/
│   │   └── MDACC_Rev_RGB_TC_tag_V.jpg
│   ├── src/
│   │   ├── components/
│   │   │   ├── FileUpload.js
│   │   │   ├── ServerForm.js
│   │   │   └── ServerList.js
│   │   ├── App.js
│   │   └── index.js
├── uploads/
├── backup/
│   ├── mongo/
│   ├── app/
├── server.js
└── package.json
```

### Client

The client-side application is built using React, providing a modern and interactive user interface. The `client` directory contains the React components and related files.

- **public/**: Contains static files, including the application logo.
- **src/**: Contains the source code for the React application, including components for uploading files, managing server data, and rendering the main application interface.

### Server

The server-side application is built using Node.js and Express. It handles API requests from the frontend, connects to MongoDB for data storage, and manages file uploads.

- **uploads/**: Directory for storing uploaded CSV files temporarily.
- **backup/**: Directory for storing backup data.
  - **mongo/**: Stores MongoDB backups.
  - **app/**: Stores application file backups.
- **server.js**: The main server file that sets up the Express application, defines API routes, and handles business logic.
- **package.json**: Contains the project’s dependencies and scripts.

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

   - Ensure the logo file `MDACC_Rev_RGB_TC_tag_V.jpg` is in the `client/public` directory.

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

The backup functionality creates a backup of both the MongoDB database and the application files. It stores the backups in the `backup` directory.

- **MongoDB Backup**: The script uses the `mongodump` command to create a backup of the MongoDB database and saves it in the `backup/mongo` directory.

- **Application Files Backup**: The script copies the application files to the `backup/app` directory.

To perform a backup, run the following script:

```bash
./backup.sh
```

### Restore

The restore functionality restores the MongoDB database and the application files from the backups stored in the `backup` directory.

- **MongoDB Restore**: The script uses the `mongorestore` command to restore the MongoDB database from the backup files in the `backup/mongo` directory.

- **Application Files Restore**: The script copies the application files from the `backup/app` directory back to the original location.

To perform a restore, run the following script:

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
