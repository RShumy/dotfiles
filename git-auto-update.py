import subprocess
git_diff = subprocess.run(["git","diff"])

print(git_diff)

