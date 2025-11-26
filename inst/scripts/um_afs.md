# Upload files to your U-M AFS web space

Upload files and folders to your U-M personal web directory (`~/Public/html/`) using `scp` or `sftp`, or use `ssh` for remote command-line access. Duo two-factor authentication (**Duo**) is required for every new connection.

## Find your web hosting address

After uploading your files or folders to `Public/html/project`, they will be publicly available at:

```
https://websites.umich.edu/~uniqname/project
```

Replace `uniqname` with your U-M username, and `project` with your folder or file name as appropriate.

## Quick tips

- **Every method triggers Duo each time you connect.**  
- Use `scp` for quick, one-off uploads (each `scp` command requires Duo).
- Use `sftp` to batch upload multiple files or folders in a single session (one Duo approval).
- Use `ssh` for remote command-line access; you cannot upload or download files with `ssh` alone.

## Check prerequisites

- U-M uniqname and AFS access
- SSH tools installed:  
   - Mac/Linux: included by default  
   - Windows: use [Git Bash](https://gitforwindows.org/) or GUI SFTP clients ([WinSCP](https://winscp.net/), [FileZilla](https://filezilla-project.org/))

## Upload files using scp (for single files or folders)

To upload a file:
```sh
scp /path/to/local/file.html uniqname@sftp.itd.umich.edu:~/Public/html/
```
- **Duo will be triggered:** You'll get a Duo push after running this command.

To upload a directory:
```sh
scp -r /path/to/local/vignette uniqname@sftp.itd.umich.edu:~/Public/html/project
```
- **Duo will be triggered:** You'll get a Duo push after running this command.

## Upload files using sftp (batch uploads in an interactive session)

```sh
sftp uniqname@sftp.itd.umich.edu
# ------> Duo will be triggered here!
# Approve Duo, then you see the sftp prompt:
cd Public/html/project
put -r /path/to/local/vignette       # upload a folder
put /path/to/local/file.html         # upload a file
bye                                  # exit
```
- **Duo is only triggered once per session:** You can upload multiple files/folders after a single Duo approval.

## Access your files using ssh (remote command-line only)

To connect to your account:
```sh
ssh uniqname@sftp.itd.umich.edu
```
- **Duo will be triggered:** You'll get a Duo push after running this command.

**Note:**  
- `ssh` opens a remote terminal on the server for file management (view, move, or delete files).
- You **cannot upload or download files with only `ssh`**. Use `scp` or `sftp` for transferring files.

## Method comparison

| Method         | When Duo triggers      | Batch uploads?   | What is it for?                         |
|----------------|------------------------|------------------|-----------------------------------------|
| scp            | Each time you run scp  | No               | Single file or directory upload         |
| sftp session   | Once, at session start | Yes              | Multiple file/folder upload in session  |
| ssh            | Each time you connect  | Not applicable   | Remote access, file management only     |
