#Bookmarkt server
This folder holds all the code for the Bookmarkt server written using Python and Flask. API requests are handled by the server, often manipulating the SQL database. Instructions on installation can be seen below.

## Docker Installation

Below a template can be seen which allows for rapid deployment of the Bookmarkt server using Docker. This will pull the image `iamafk/bookmarkt-server` from the DockerHub repository and spin up a container in detached mode. This image works on x86-64 (AMD64) processors, and will work on any operating system will Docker installed. 

This is the preferred method of running the Bookmarkt server due easy deployment and management. The Docker image has been tested on both Ubuntu 20.04 and Windows 10, both running a x86-64 processor.

### Docker Run Template
```bash
docker run -d \
--name=bookmarkt \
-p 5000:5000 \
-v /path/to/database:/database \
-v /path/to/thumbnails:/bookmarkt/Assets/Thumbnails \
iamafk/bookmarkt-server
```

### Parameters

Containers can be configured using parameters and flags during creation. Parameters are separated by colons, indicating `<external>:<internal>` where external is outside the container and internal is inside the container. For example `-p 8080:80` would expose port `80` from inside the container which is accessible on the host's port `8080` outside the container.

| Parameter        | Function        |
| :-------------: |:-------------|
| `-d`      | Runs the container in detached mode |
| `--name=bookmarkt`      | The name of the container      |
| `-p 5000:5000` | Exposes the ports in the container and in the host machine      |
| `-v /database` | Path on the server where the folder containing the database are stored      |
| `-v /bookmarkt/Assets/Thumbnails` | Path on the server where the folder containing the book thumbnails are stored      |

## Flask Installation

This method of installation requires downloading all the relevant files, installing the necessary requirements and running the Flask server in a command prompt/terminal window. Below are some instructions to help installation.

To install with this method, you need Python 3.8 installed and added to the PATH.

1. Download the server files locally

`git clone https://campus.cs.le.ac.uk/gitlab/ug_project/20-21/kr217.git && cd "kr217/Bookmarkt Flask"`

2. Install all the python requirements

`pip install -r requirements.txt`

3. Set the FLASK_APP environmental variable (Note. if running in Windows command prompt replace `export` with `set`, and if running in Windows powershell replace with `\$env:` to set environmental variable)

`export FLASK_APP=bookmarkt.py`

4. Run the Flask server 

`python -m flask run --host 0.0.0.0`

5. Accept any firewall requirements if prompted


6. The server is now running, to access this on your mobile device you must use the IP address of the host machine. This can be found with `ipconfig` on Windows and `` on Linux