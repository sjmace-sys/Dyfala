from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageDraw


ASSETS = (
    Path("assets/approved/home-en-final.webp"),
    Path("assets/approved/home-cy-final.webp"),
)


def scaled_box(w, h, box):
    x0, y0, x1, y1 = box
    return (
        round(x0 * w / 941),
        round(y0 * h / 1672),
        round(x1 * w / 941),
        round(y1 * h / 1672),
    )


def polish(path: Path) -> None:
    image = Image.open(path).convert("RGB")
    w, h = image.size

    # Keep the established Build 65 scene and colour language intact.
    # A tiny contrast/colour lift removes some of the worked-over softness
    # without flattening the atmospheric distance.
    base = ImageEnhance.Contrast(image).enhance(1.025)
    base = ImageEnhance.Color(base).enhance(1.015)

    mild = base.filter(
        ImageFilter.UnsharpMask(radius=1.15, percent=115, threshold=4)
    )
    strong = base.filter(
        ImageFilter.UnsharpMask(radius=1.0, percent=180, threshold=3)
    )

    # Gradually introduce detail below the mountain line. The distant sky and
    # mountains remain deliberately soft.
    foreground = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(foreground)
    y0 = round(h * 0.43)
    y1 = round(h * 0.72)
    for y in range(y0, h):
        amount = 90 if y >= y1 else round(90 * (y - y0) / max(1, y1 - y0))
        draw.line((0, y, w, y), fill=amount)
    result = Image.composite(mild, base, foreground)

    # Extra crispness where the artwork needs to read as premium illustration:
    # signpost and dragon. Coordinates are based on the locked 941x1672 master
    # and scale automatically if the asset dimensions ever change.
    detail = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(detail)
    d.rounded_rectangle(
        scaled_box(w, h, (45, 700, 430, 1015)),
        radius=max(8, round(40 * w / 941)),
        fill=155,
    )
    d.ellipse(scaled_box(w, h, (580, 840, 960, 1195)), fill=170)
    result = Image.composite(strong, result, detail)

    # A restrained final pass on near vegetation. Keep the path itself smooth.
    vegetation = Image.new("L", (w, h), 0)
    v = ImageDraw.Draw(vegetation)
    v.rectangle((0, round(h * 0.61), w, h), fill=40)
    result = Image.composite(mild, result, vegetation)

    result.save(path, "WEBP", quality=95, method=6)


for asset in ASSETS:
    polish(asset)
    print(f"Build 66 polished {asset}")
