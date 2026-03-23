import os
import subprocess

REPO = r"c:\Users\Buddhima\Desktop\medifind_app\medifind_app"
os.chdir(REPO)

# Items to KEEP in the root directory
KEEP = {
    ".git",
    "backend",
    ".agent",
    ".agents",
    "check_db.js",
    "skills-lock.json"
}

# The new directory
FRONTEND_DIR = "frontend"
if not os.path.exists(FRONTEND_DIR):
    os.makedirs(FRONTEND_DIR)

def run(cmd):
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"FAIL: {cmd[:80]}\n{r.stderr[:200]}")
    else:
        print(f"OK: {cmd[:80]}")

# Process tracked files first
r = subprocess.run("git ls-tree --name-only HEAD", shell=True, capture_output=True, text=True)
tracked_items = r.stdout.strip().split("\n")

for item in tracked_items:
    if not item or item in KEEP or item == FRONTEND_DIR:
        continue
    # Move tracked items using git mv
    print(f"Moving tracked item: {item}")
    run(f'git mv "{item}" "{FRONTEND_DIR}/{item}"')

# Move any remaining untracked files
for item in os.listdir(REPO):
    if item in KEEP or item == FRONTEND_DIR or item == "move_to_frontend.py":
        continue
    # Don't move if it's already inside frontend!
    src = os.path.join(REPO, item)
    dst = os.path.join(REPO, FRONTEND_DIR, item)
    if os.path.exists(src) and not os.path.exists(dst):
        print(f"Moving untracked item: {item}")
        try:
            os.rename(src, dst)
        except Exception as e:
            print(f"Failed to move {item}: {e}")

run('git add -A')
run('git commit -m "refactor: move all frontend files to frontend/ directory"')
print("\n=== RESTRUCTURING COMPLETE ===")
