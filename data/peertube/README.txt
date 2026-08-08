PeerTube (Streaming) data directory.

Layout after install:
  data/     ← videos, thumbnails, and other media
  config/   ← PeerTube configuration
  redis/    ← Redis persistence for this app

Open:
  https://stream.community.home.arpa

Notes:
  • Transcoding uses significant CPU, RAM, and disk. Prefer a host
    with spare capacity if you expect many uploads or live streams.
  • Removing the app stops containers but keeps this directory.
  • Delete this directory only if you intend to erase all videos.
  • Live RTMP ingest (if used) listens on host port 1935.
