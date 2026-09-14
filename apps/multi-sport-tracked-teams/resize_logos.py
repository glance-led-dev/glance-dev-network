from PIL import Image
from pathlib import Path

TARGET = 64

folder = Path(".")
backup = folder / "original_logos"

backup.mkdir(exist_ok=True)

for path in folder.glob("*.png"):
    # Skip files already inside backup folder
    if path.parent == backup:
        continue

    with Image.open(path) as img:
        img = img.convert("RGBA")

        # Don't enlarge already-small images
        if img.width <= TARGET and img.height <= TARGET:
            print(f"Skipping {path.name} ({img.width}x{img.height})")
            continue

        # Save original
        backup_path = backup / path.name
        if not backup_path.exists():
            img.save(backup_path)

        # Resize proportionally
        img.thumbnail((TARGET, TARGET), Image.Resampling.LANCZOS)

        # Put it on a transparent 64x64 canvas
        canvas = Image.new("RGBA", (TARGET, TARGET), (0, 0, 0, 0))

        x = (TARGET - img.width) // 2
        y = (TARGET - img.height) // 2

        canvas.paste(img, (x, y), img)
        canvas.save(path)

        print(f"Resized {path.name} -> 64x64")
