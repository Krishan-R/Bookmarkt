
## Docker Installation
```bash
docker run -d \
--name=bookmarkt \
-p 5000:5000 \
-v /path/to/database:/database \
-v /path/to/thumbnails:/bookmarkt/Assets/Thumbnails \
iamafk/bookmarkt-server
```