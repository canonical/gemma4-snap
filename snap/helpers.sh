copy_if_changed() {
    local src_file="$1"
    local dst_file="$2"

    if [[ -f "$dst_file" ]] && cmp -s "$src_file" "$dst_file"; then
        echo "Skipping unchanged file: $dst_file"
        return 0
    fi

    echo "Copying $src_file ---> $dst_file"
    cp -v "$src_file" "$dst_file"
}

distribute_gguf_components() {
    set +x # reduce noise

    local src_dir="$SNAPCRAFT_PROJECT_DIR/$1"
    local component_name_prefix="$2"
    
    if [[ ! -d "$src_dir" ]]; then
        echo "Error: Directory $src_dir does not exist."
        return 1
    fi

    # 1. Generate the base name (e.g., model-30b-a3b... -> MODEL_30B_A3B...)
    local dir_basename=$(basename "$src_dir")
    
    # 2. Find all GGUF files and sort them
    local gguf_files=($(\ls "$src_dir"/*.gguf | sort))
    local total_files=${#gguf_files[@]}

    if [ "$total_files" -eq 0 ]; then
        echo "No GGUF files found in $src_dir"
        return 1
    fi

    echo "Found $total_files shards. Distributing..."

    for (( i=0; i<$total_files; i++ )); do
        local current_file="${gguf_files[$i]}"
        local filename=$(basename "$current_file")

        # 3. Extract shard info (e.g., 00001 and 00006) from filename
        # This regex looks for the numbers surrounding "-of-"
        if [[ $filename =~ ([0-9]+)-of-([0-9]+)\.gguf$ ]]; then
            local shard_idx=$((10#${BASH_REMATCH[1]})) # 10# removes leading zeros
            local shard_total=$((10#${BASH_REMATCH[2]}))
        else
            # Fallback if regex fails: use loop index
            local shard_idx=$((i + 1))
            local shard_total=$total_files
        fi

        # 4. Construct target directory name
        local component_name=$(echo "$component_name_prefix" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        if [ "$total_files" -gt 1 ]; then 
            echo "Multiple GGUF files found. Assuming sharded model with $total_files shards."
            echo "new component name will be ${component_name}_${shard_idx}_OF_${shard_total}"
            local component_name="${component_name}_${shard_idx}_OF_${shard_total}"
        fi
        local target_env="CRAFT_COMPONENT_${component_name}_PRIME"
        local target_dir="${!target_env}"
        
        echo "Creating $target_dir..."
        mkdir -p "$target_dir"

        # 5. Copy the GGUF file
        copy_if_changed "$current_file" "$target_dir/$filename"

        # 6. Handle component.yaml logic
        if [ "$i" -eq 0 ]; then
            copy_if_changed "$src_dir/component.yaml" "$target_dir/component.yaml"
        else
            echo "Writing empty component file: $target_dir/component.yaml"
            echo "# No config" > "$target_dir/component.yaml"
        fi
    done

    echo "Distribution complete."
    set -x # re-enable debug
}

# Usage:
# distribute_gguf_components <source_dir> <component_name_prefix>
# distribute_gguf_components "components/model-30b-a3b-reasoning-q4-k-m" "model-30b-a3b-reasoning-q4-k-m"