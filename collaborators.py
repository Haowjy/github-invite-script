
import csv
import subprocess

TOKEN = "YOUR_TOKEN_HERE"
with open('GitHub Workshop Sign In.csv', 'r') as f:
    reader = csv.reader(f)
    github_usernames = []
    for i,row in enumerate(reader):
        if i != 0:
            github_usernames.append(row[3])
            
    subprocess.run(["./github-collaborators.sh", "-u", TOKEN, "-r", "gdsc-ur/git-github-workshop", ",".join(github_usernames)])