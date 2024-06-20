# ITE Open Systems Server Management

ITE Open Systems Server Management is a web-based application designed to manage server configurations, including details such as system name, IP address, function, pillar, frequency, analyst email, major version, offset, maintenance date, time, reboot status, customer email, and customer name. The application supports server entry additions, updates, deletions, cloning, CSV uploads, and data export functionalities.

## Features

1. **Add Server Entries**:
    - Allows adding new server entries with fields for system name, IP address, function, pillar, frequency, analyst email, major version, offset, maintenance date, time, reboot status, customer email, and customer name.
    - Validates that system names are in all caps, IP addresses follow the format, and certain fields such as major version and offset do not contain only zeros.
    - Ensures no duplicate entries for system name and IP address.
    - Confirms the action before adding a new server.

2. **Edit Server Entries**:
    - Enables editing existing server entries with the same validation rules as adding.
    - Confirms the action before updating a server entry.
    - Avoids duplicate entries during the update process.

3. **Delete Server Entries**:
    - Allows deleting individual server entries or multiple selected entries at once.
    - Confirms the action before deleting the server(s).

4. **Clone Server Entries**:
    - Provides functionality to clone an existing server entry to create a new one with similar details.
    - Automatically clears the system name and IP address fields to prevent unintentional duplicates.

5. **CSV Upload**:
    - Supports uploading server details in CSV format to bulk add multiple entries at once.
    - Validates and processes the uploaded CSV file, stripping BOM (Byte Order Mark) if present.
    - Inserts valid entries into the database and provides feedback on the success of the operation.

6. **Data Export**:
    - Exports the server data into a CSV file.
    - Allows users to download the CSV file containing all server entries.

7. **Search Functionality**:
    - Enables searching server entries by system name or IP address.

## Technology Stack

- **Frontend**: React.js
    - Axios for API requests.
    - CSS for styling and layout.

- **Backend**: Node.js with Express.js
    - Mongoose for MongoDB interaction.
    - Multer for handling file uploads.
    - CSV-parser for processing CSV files.
    - json2csv for exporting data to CSV.

- **Database**: MongoDB
    - Used to store server configuration details.

- **Process Management**: PM2
    - Manages the backend process, ensuring high availability and performance.

## Installation and Setup

### Prerequisites

- **Node.js** (version 18.x recommended)
- **MongoDB** (version 6.0.6 recommended)
- **PM2** for process management
- **Git** for version control

### Installation Steps

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/justrashad/server_db_app.git
    cd server_db_app
    ```

2. **Run the Setup Script**:
    - The setup script installs necessary dependencies, sets up MongoDB, and configures the application.
    ```sh
    ./systemdb.sh
    ```

### Backend Setup

- **Environment Variables**:
    - `BACKEND_PORT`: Port on which the backend server runs (default is 5000).
    - `FRONTEND_PORT`: Port on which the frontend server runs (default is 3000).

- **MongoDB Configuration**:
    - Ensure MongoDB is running and accessible.
    - The setup script creates the `serverdb` database and ensures the necessary collection exists.

### Frontend Setup

- **React Environment Variables**:
    - `REACT_APP_BACKEND_URL`: URL for the backend API (e.g., `http://10.113.111.113:5000`).

## Usage

### Running the Application

1. **Start the Backend**:
    - PM2 will automatically start the backend during setup.
    ```sh
    pm2 start server.js --name backend --update-env
    ```

2. **Start the Frontend**:
    - PM2 will automatically start the frontend during setup.
    ```sh
    pm2 start npm --name frontend -- start
    ```

### Accessing the Application

- **Frontend**:
    - Open a web browser and navigate to the frontend URL (e.g., `http://10.113.111.113:3000`).

### Data Management

#### Adding a Server

- Fill in the server details in the "Add Server Section".
- Click the "Add Server" button.
- A confirmation prompt will appear. Confirm to add the server.

#### Editing a Server

- Click the "Edit" button next to the server entry you wish to edit.
- Modify the server details in the form.
- Click the "Update Server" button.
- A confirmation prompt will appear. Confirm to update the server.

#### Deleting a Server

- Click the "Delete" button next to the server entry you wish to delete.
- A confirmation prompt will appear. Confirm to delete the server.

#### Cloning a Server

- Click the "Clone" button next to the server entry you wish to clone.
- Modify the necessary details in the form.
- Click the "Add Server" button to add the cloned server as a new entry.

#### CSV Upload

- Click the "Choose File" button in the "CSV Upload Section" and select a CSV file.
- Click the "Upload" button to upload and process the CSV file.

#### Data Export

- Click the "Export to CSV" button in the "Database Export Section" to download the server data as a CSV file.

### PM2 Usage

- **Start a Process**:
    ```sh
    pm2 start <script> --name <process_name>
    ```

- **Stop a Process**:
    ```sh
    pm2 stop <process_name>
    ```

- **Restart a Process**:
    ```sh
    pm2 restart <process_name>
    ```

- **View Logs**:
    ```sh
    pm2 logs <process_name>
    ```

- **List Processes**:
    ```sh
    pm2 list
    ```

## Backup and Restore

### Backup

- The setup script includes a backup function that backs up MongoDB data and application files.
- Backups are stored in the `backup` directory.
- To manually backup:
    ```sh
    mongodump --out <backup_directory>
    ```

### Restore

- To restore from a backup:
    ```sh
    mongorestore <backup_directory>
    ```

### Verify Import

- After uploading a CSV file, the backend processes the file and inserts valid entries into the database.
- To verify the import, you can access the backend`s verify import feature via:
    ```url
    http://<backend_url>/verify-import
    ```
- This URL provides feedback on the import status and any errors encountered.

### Project Structure

```
server_db_app/
├── server-management-app/
│   ├── client/
│   │   ├── public/
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── FileUpload.js
│   │   │   │   ├── ServerForm.js
│   │   │   │   ├── ServerList.js
│   │   │   │   ├── ExportButton.js
│   │   │   │   ├── CSVUpload.js
│   │   │   │   ├── SearchSection.js
│   │   │   │   ├── AddServerSection.js
│   │   ├── App.js
│   │   ├── index.js
│   ├── server.js
├── systemdb.sh
├── backup/
│   ├── mongo/
│   ├── app/
```

## Conclusion

ITE Open Systems Server Management is a robust and user-friendly application for managing server configurations efficiently. Its comprehensive features, such as server addition, update, deletion, cloning, CSV upload, and data export, provide a seamless experience for managing server data. The application leverages modern technologies like React, Node.js, and MongoDB to ensure high performance and reliability.
