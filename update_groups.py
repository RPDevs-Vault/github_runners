import os
import glob

# Files in ops-manager
ops_files = glob.glob('/home/llmuser/projects/ops-manager/.github/workflows/*.yml')

for filepath in ops_files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    if 'group: linux-builders' in content:
        # replace with T430 for lightweight ops manager jobs
        new_content = content.replace('group: linux-builders', 'group: T430')
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

# For builder-manager and github_runners, let's check which ones have matrices
for repo in ['builder-manager', 'github_runners']:
    if repo == 'builder-manager':
        base_dir = '/home/llmuser/projects/builder-manager/.github/workflows'
    else:
        base_dir = '/home/llmuser/projects/github_runners/Workflows'
        
    for filepath in glob.glob(f'{base_dir}/*.yml'):
        with open(filepath, 'r') as f:
            content = f.read()
            
        if 'group: linux-builders' in content:
            if 'matrix:' in content and 'target_node' in content:
                # Replace with ${{ matrix.target_node }} but uppercase?
                # Actually wait, GitHub groups might be exact case. But let's look at the target_nodes.
                # In housekeeping.yml: `target_node: [t430, llmadmin01]`. 
                # GitHub runner groups we discovered are `llmadmin01` and `T430`.
                # If the matrix uses `t430`, wait, we can just replace the matrix values too.
                content = content.replace('target_node: [t430, llmadmin01]', 'target_node: [T430, llmadmin01]')
                content = content.replace('group: linux-builders', 'group: ${{ matrix.target_node }}')
            else:
                # If no matrix target_node, maybe it's just heavy?
                # E.g. base-image-builder is a build job, maybe it's heavy so llmadmin01
                # Wait, base-image-builder does not have a matrix target_node?
                content = content.replace('group: linux-builders', 'group: llmadmin01')
                
            with open(filepath, 'w') as f:
                f.write(content)
            print(f"Updated {filepath}")
