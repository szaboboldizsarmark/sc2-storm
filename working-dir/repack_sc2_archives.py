#!/usr/bin/env python3
"""Repack SupCom2 lua.scd and z_lua_dlc1.scd preserving original Storm zip metadata.

Assumes working-dir contains:
- lua/ (extracted tree)
- z_lua_dlc1/ (extracted tree)
- zz_STORM.scd/ (directory)

Behavior:
- Removes existing lua.scd, z_lua_dlc1.scd, zz_STORM.scd from gamedata
- Copies zz_STORM.scd directory into gamedata
- Rebuilds lua.scd and z_lua_dlc1.scd in gamedata using original-storm archives
"""
from pathlib import Path
import shutil
import zipfile

# Hardcoded gamedata path (as requested)
GAMEDATA = Path("/home/boldi/.local/share/Steam/steamapps/common/Supreme Commander 2/gamedata")

ROOT = Path("/home/boldi/supcom2-mod")
ORIGINAL = ROOT / "original-storm"
WORKING = ROOT / "working-dir"

WORK_LUA_DIR = WORKING / "lua"
WORK_DLC_DIR = WORKING / "z_lua_dlc1"
WORK_ZZ_DIR = WORKING / "zz_STORM.scd"

TEMPLATE_LUA = ORIGINAL / "lua.scd"
TEMPLATE_DLC = ORIGINAL / "z_lua_dlc1.scd"

OUT_LUA = GAMEDATA / "lua.scd"
OUT_DLC = GAMEDATA / "z_lua_dlc1.scd"
OUT_ZZ = GAMEDATA / "zz_STORM.scd"


def repack_from_template(template_zip: Path, source_dir: Path, out_zip: Path) -> None:
    if not template_zip.exists():
        raise FileNotFoundError(f"Template not found: {template_zip}")
    if not source_dir.exists():
        raise FileNotFoundError(f"Source dir not found: {source_dir}")

    with zipfile.ZipFile(template_zip) as zt, zipfile.ZipFile(out_zip, "w") as zo:
        for info in zt.infolist():
            if info.is_dir():
                continue
            name = info.filename
            rel_slash = name.replace("\\", "/")
            src_path = source_dir / rel_slash
            if not src_path.exists():
                src_path = source_dir / name  # fallback for literal backslash paths
            if not src_path.exists():
                raise FileNotFoundError(f"Missing source file for entry: {name}")

            data = src_path.read_bytes()
            zi = zipfile.ZipInfo(filename=info.filename, date_time=info.date_time)
            zi.compress_type = info.compress_type
            zi.comment = info.comment
            zi.extra = info.extra
            zi.create_system = info.create_system
            zi.create_version = info.create_version
            zi.extract_version = info.extract_version
            zi.flag_bits = info.flag_bits
            zi.internal_attr = info.internal_attr
            zi.external_attr = info.external_attr
            zo.writestr(zi, data)


def main() -> None:
    # Clean gamedata
    if OUT_LUA.exists():
        OUT_LUA.unlink()
    if OUT_DLC.exists():
        OUT_DLC.unlink()
    if OUT_ZZ.exists():
        if OUT_ZZ.is_dir():
            shutil.rmtree(OUT_ZZ)
        else:
            OUT_ZZ.unlink()

    # Copy zz_STORM.scd directory
    if not WORK_ZZ_DIR.exists():
        raise FileNotFoundError(f"Missing working zz_STORM.scd directory: {WORK_ZZ_DIR}")
    shutil.copytree(WORK_ZZ_DIR, OUT_ZZ)

    # Repack lua.scd and z_lua_dlc1.scd into gamedata
    repack_from_template(TEMPLATE_LUA, WORK_LUA_DIR, OUT_LUA)
    repack_from_template(TEMPLATE_DLC, WORK_DLC_DIR, OUT_DLC)

    print(f"Wrote {OUT_LUA}")
    print(f"Wrote {OUT_DLC}")
    print(f"Copied {OUT_ZZ}")


if __name__ == "__main__":
    main()
