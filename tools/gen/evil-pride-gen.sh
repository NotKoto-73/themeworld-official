#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bc openscad imagemagick ffmpeg

# Generate multiple Plymouth themes using both approaches

# Theme configurations
declare -A themes=(
    ["evil-nix"]="local"
    ["rainbow-nix"]="local"
    ["pride-nix"]="local"
)
# Color schemes
declare -A colors=(
    ["evil-nix"]="#cc0000 #990000 #660000"
    ["rainbow-nix"]="#ff0000 #ff7f00 #ffff00 #00ff00 #0000ff #4b0082 #9400d3"
    ["pride-nix"]="#e40303 #ff8c00 #ffed00 #008018 #004cff #732982"
)

generate_local_theme() {
    local theme_name=$1
    
    case "$theme_name" in
        "evil-nix")
            scad_file="evilnix.scad"
            ;;
        "rainbow-nix")
            # Modify good-logo.scad for rainbow colors
            sed 's/colors = \["#5277c3", "#7caedc"\];/colors = ["#ff0000", "#ff7f00", "#ffff00", "#00ff00", "#0000ff"];/' \
                "good-logo.scad" > "temp-${theme_name}.scad"
            scad_file="temp-${theme_name}.scad"
            ;;
        "pride-nix")
            # Modify good-logo.scad for pride colors
            sed 's/colors = \["#5277c3", "#7caedc"\];/colors = ["#e40303", "#ff8c00", "#ffed00", "#008018", "#004cff"];/' \
                "good-logo.scad" > "temp-${theme_name}.scad"
            scad_file="temp-${theme_name}.scad"
            ;;
        *)
            scad_file="good-logo.scad"
            ;;
    esac
    
    echo "Generating ${theme_name} using ${scad_file}..."
    
    # Check if SCAD file exists
    if [ ! -f "$scad_file" ]; then
        echo "ERROR: $scad_file not found!"
        return 1
    fi
    
    mkdir -p "${theme_name}-plymouth"
    
    # Generate 30 frames for smoother animation
    for i in $(seq 0 29); do
        t=$(echo "scale=6; $i / 29" | bc -l)
        echo "Frame $((i+1))/30 (t=${t})"
        
        openscad -o "evil-frame-${i}.png" \
    -D "\$t=${t}" \
    --export-format=png \
    --imgsize=400,400 \
    "evilnix.scad"
        
        if [ -f "${theme_name}-frame-${i}.svg" ]; then
            convert "evil-nix-plymouth/$(printf "%03d.png" $((i+1)))" \
    -colorspace RGB \
    -fill "#cc0000" \
    -tint 100 \
    "evil-nix-plymouth/$(printf "%03d.png" $((i+1)))"
            rm "${theme_name}-frame-${i}.svg"
        else
            echo "WARNING: Frame ${i} failed to generate"
        fi
    done
}

generate_genix7000_theme() {
    local theme_name=$1
    local color_string=${colors[$theme_name]}
    
    echo "Generating ${theme_name} using genix7000..."
    mkdir -p "${theme_name}-plymouth"
    
    # Create animation using genix7000
    nix run github:cab404/genix7000#to-image -- \
        "${theme_name}.mp4" \
        $color_string \
        --animation '{ rotation: ($rotation - $i * 3) }' \
        --duration 2 \
        --fps 15 \
        --imgsize "400,400"
    
    # Extract frames if MP4 was created
    if [ -f "${theme_name}.mp4" ]; then
        ffmpeg -i "${theme_name}.mp4" \
            -vf "scale=200:200" \
            "${theme_name}-plymouth/%03d.png" 2>/dev/null
        rm "${theme_name}.mp4"
    else
        echo "MP4 generation failed, trying individual frames..."
        # Fallback to individual frame generation
        for i in $(seq 0 29); do
            rotation=$((i * 12))  # 360/30 frames
            nix run github:cab404/genix7000#to-image -- \
                "${theme_name}-frame-${i}.png" \
                $color_string \
                --rotation "$rotation" \
                --imgsize "200,200"
            
            if [ -f "${theme_name}-frame-${i}.png" ]; then
                mv "${theme_name}-frame-${i}.png" \
                   "${theme_name}-plymouth/$(printf "%03d.png" $((i+1)))"
            fi
        done
    fi
}

create_plymouth_files() {
    local theme_name=$1
    local frame_count=$(ls "${theme_name}-plymouth"/*.png 2>/dev/null | wc -l)
    
    echo "Creating Plymouth configuration for ${theme_name} (${frame_count} frames)"
    
    # Create .plymouth file
    cat > "${theme_name}-plymouth/${theme_name}.plymouth" << EOF
[Plymouth Theme]
Name=${theme_name}
Description=${theme_name^} Nix Logo Animation
Comment=Animated Nix logo theme for boot splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/${theme_name}
ScriptFile=/usr/share/plymouth/themes/${theme_name}/${theme_name}.script
EOF

    # Create .script file
    cat > "${theme_name}-plymouth/${theme_name}.script" << EOF
# ${theme_name^} Plymouth Theme

image_quantity = ${frame_count};
frame_rate = 15;
frame_counter = 0;
current_frame = 1;

# Load frames
for (i = 1; i <= image_quantity; i++)
{
    frame_image[i] = Image(sprintf("%03d.png", i));
}

# Create and position sprite
logo_sprite = Sprite();
logo_sprite.SetImage(frame_image[1]);

logo_width = frame_image[1].GetWidth();
logo_height = frame_image[1].GetHeight();
logo_sprite.SetX(Window.GetX() + (Window.GetWidth() / 2 - logo_width / 2));
logo_sprite.SetY(Window.GetY() + (Window.GetHeight() / 2 - logo_height / 2));

# Animation
fun refresh_callback()
{
    frame_counter++;
    if (frame_counter % (60 / frame_rate) == 0)
    {
        current_frame++;
        if (current_frame > image_quantity)
            current_frame = 1;
        logo_sprite.SetImage(frame_image[current_frame]);
    }
}

Plymouth.SetRefreshFunction(refresh_callback);

# LUKS messages
fun message_callback(text)
{
    if (text)
    {
        message_image = Image.Text(text, 1, 1, 1);
        message_sprite = Sprite(message_image);
        message_sprite.SetX(Window.GetX() + (Window.GetWidth() / 2 - message_image.GetWidth() / 2));
        message_sprite.SetY(logo_sprite.GetY() + logo_height + 30);
    }
}

Plymouth.SetMessageFunction(message_callback);
EOF

    # Create install script
    cat > "${theme_name}-plymouth/install.sh" << EOF
#!/bin/bash
sudo cp -r . /usr/share/plymouth/themes/${theme_name}/
sudo plymouth-set-default-theme ${theme_name}
sudo update-initramfs -u
echo "${theme_name^} Plymouth theme installed!"
EOF
    
    chmod +x "${theme_name}-plymouth/install.sh"
}

echo "Plymouth Multi-Theme Generator"
echo "=============================="

# Check dependencies
echo "Checking dependencies..."
which openscad >/dev/null && echo "✓ OpenSCAD available" || echo "✗ OpenSCAD missing"
which convert >/dev/null && echo "✓ ImageMagick available" || echo "✗ ImageMagick missing"
which bc >/dev/null && echo "✓ bc available" || echo "✗ bc missing"

# Check files
echo "Checking files..."
[ -f "evilnix.scad" ] && echo "✓ evilnix.scad found" || echo "✗ evilnix.scad missing"
[ -f "good-logo.scad" ] && echo "✓ good-logo.scad found" || echo "✗ good-logo.scad missing"

generate_evil_nix() {
    echo "Generating evil-nix..."
    mkdir -p "evil-nix-plymouth"
    
    for i in $(seq 0 29); do
        t=$(echo "scale=6; $i / 29" | bc -l)
        echo "Frame $((i+1))/30"
        
        openscad -o "evil-frame-${i}.svg" \
            -D "\$t=${t}" \
            --export-format=svg \
            --imgsize=400,400 \
            "evilnix.scad"
        
        if [ -f "evil-frame-${i}.svg" ]; then
            convert "evil-frame-${i}.svg" \
                -background black \
                -flatten \
                -resize 200x200 \
                "evil-nix-plymouth/$(printf "%03d.png" $((i+1)))"
            rm "evil-frame-${i}.svg"
        fi
    done
}

generate_evil_nix
echo "Complete!"
ls -ld *plymouth* 2>/dev/null
