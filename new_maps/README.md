# Submitting a Map

Place your `.pkz` file in this folder and create a new branch with the name of your map — the CI workflow will handle the rest automatically (S3 upload, map list update, and PR creation for the uberpak rebuild).

> **Prerequisite:** You need write access to this repository. Contact a maintainer if you need it granted, or send them your `.pkz` directly.

---

## Option A: GitHub Web UI (no git required) but 25MB limit

1. Navigate to the **`new_maps/`** folder on GitHub
2. Click **Add file → Upload files**
3. Drag and drop your `.pkz` file (25MB limit)
4. At the bottom, select **Commit directly to the `master` branch**
5. Click **Commit changes**

The workflow triggers automatically within seconds.

---

## Option B: Sparse Clone (command line) removes 25MB limit

This fetches only what's needed — none of the large binary content from the rest of the repo.

```bash
# Clone without downloading file contents
git clone --filter=blob:none --sparse git@github.com:aq2world/server.git
cd server

# Check out only the new_maps/ folder
git sparse-checkout set new_maps

# Copy your pkz in
cp /path/to/yourmap.pkz new_maps/

# Commit and push
git add new_maps/yourmap.pkz
git commit -m "Add map: yourmap"
git push
```

If you use HTTPS instead of SSH, replace the clone URL with `https://github.com/aq2world/server.git` and use your GitHub username and a [personal access token](https://github.com/settings/tokens) as the password.

---

## What happens after the push

1. The **Process New Map** workflow fires automatically
2. It extracts the `.pkz`, computes the CRC, uploads assets to S3, and updates the map lists
3. It opens a pull request (`map/yourmap`) to merge the map files into `uberpaks/`
4. A maintainer reviews and merges the PR — this triggers the uberpak rebuild

The full process takes about 1-2 minutes.

---

**Only one `.pkz` at a time is supported.** If multiple files are present the workflow will error.
