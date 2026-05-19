#!/bin/bash

copy_if_changed() {
    local src_file="$1"
    local dst_file="$2"

    if [[ ! -f "$src_file" ]]; then
        echo "Error: Source file $src_file does not exist or is not a file."
        return 1
    fi

    if [[ -f "$dst_file" ]] && cmp -s "$src_file" "$dst_file"; then
        echo "    Skipping unchanged file: $dst_file"
        return 0
    fi

    echo "    Syncing $src_file ---> $dst_file"

    # Prefer hardlinks to save space/time; fallback to copy (e.g., cross-filesystem).
    if ln -f -v "$src_file" "$dst_file"; then
        echo "    Hardlinked: $dst_file"
    else
        echo "    Hardlink failed, falling back to copy: $dst_file"
        cp -v "$src_file" "$dst_file"
    fi
}

distribute_gguf_components() {
    local src_dir="$SNAPCRAFT_PROJECT_DIR/$1"
    local component_name_prefix="$2" # Contains the target component name, e.g. "model-30b" or the prefix for sharded models like "model-30b" for components named "model-30b-1-of-6", "model-30b-2-of-6", etc.
    
    echo "Distributing GGUF files from $src_dir in component(s): $component_name_prefix"

    if [[ ! -d "$src_dir" ]]; then
        echo "Error: Directory $src_dir does not exist."
        return 1
    fi
    
    # 1. Find all GGUF files and sort them.
    local -a gguf_files=()
    mapfile -d '' -t gguf_files < <(find "$src_dir" -maxdepth 1 -type f -name '*.gguf' -print0 | sort -z)
    local total_files=${#gguf_files[@]}

    if [ "$total_files" -eq 0 ]; then
        echo "Error: no GGUF files found in $src_dir"
        return 1
    fi

    if [ "$total_files" -gt 1 ]; then
        echo "  Multiple GGUF files found in $src_dir. Assuming sharded model with $total_files shards."
    else
        echo "  Single GGUF file found in $src_dir. Distributing as a single component."
    fi

    for (( i=0; i<$total_files; i++ )); do
        local current_file="${gguf_files[$i]}"
        local filename=$(basename "$current_file")

        # 2. Extract shard info (e.g., 00001 and 00006) from filename
        # This regex looks for the numbers surrounding "-of-"
        if [[ $filename =~ ([0-9]+)-of-([0-9]+)\.gguf$ ]]; then
            local shard_idx=$((10#${BASH_REMATCH[1]})) # 10# removes leading zeros
            local shard_total=$((10#${BASH_REMATCH[2]}))
        else
            # Fallback if regex fails: use loop index
            local shard_idx=$((i + 1))
            local shard_total=$total_files
        fi

        # 3. Construct target directory name
        local component_name="$component_name_prefix"
        if [ "$total_files" -gt 1 ]; then 
            local component_name="${component_name_prefix}-${shard_idx}-of-${shard_total}"
        fi
        
        echo "  Distributing shard $shard_idx of $shard_total for file $filename, using component: $component_name"
        
        local component_name_env=$(echo "$component_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        local target_env="CRAFT_COMPONENT_${component_name_env}_PRIME"
        local target_dir="${!target_env}"

        # Ensure the target directory exists
        if [[ ! -d "$target_dir" ]]; then
            echo "Error: Target directory $target_dir does not exist."
            echo "Make sure that you have a component named $component_name in snapcraft.yaml"
            return 1
        fi
        
        echo "  Creating $target_dir..."
        mkdir -p "$target_dir"

        # 4. Copy the GGUF file
        copy_if_changed "$current_file" "$target_dir/$filename"

        # 5. Handle component.yaml logic
        if [ "$i" -eq 0 ]; then
            copy_if_changed "$src_dir/component.yaml" "$target_dir/component.yaml"
        else
            echo "  Writing empty component file: $target_dir/component.yaml"
            echo "# No config" > "$target_dir/component.yaml"
        fi
    done

    echo "Distribution complete."
}

# Usage:
# distribute_gguf_components <source_dir> <component_name_prefix>
# distribute_gguf_components "components/model-30b-a3b-reasoning-q4-k-m" "model-30b-a3b-reasoning-q4-k-m"