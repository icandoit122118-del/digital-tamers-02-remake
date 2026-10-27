using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Text.Json;
using UndertaleModLib.Models;

EnsureDataLoaded();

string outDir = @"D:\digimon-re\out\data";
Directory.CreateDirectory(outDir);
var opt = new JsonSerializerOptions { WriteIndented = false };

string N(UndertaleNamedResource r) => r?.Name?.Content;

// ---- sprites: origin / size / bbox / frame count
var sprites = Data.Sprites.Select(s => new {
    name = s.Name?.Content,
    w = s.Width, h = s.Height,
    originX = s.OriginX, originY = s.OriginY,
    bbox = new { l = s.MarginLeft, r = s.MarginRight, t = s.MarginTop, b = s.MarginBottom },
    bboxMode = s.BBoxMode.ToString(),
    sepMasks = s.SepMasks.ToString(),
    frames = s.Textures.Count,
    playbackSpeed = s.GMS2PlaybackSpeed,
    playbackType = s.GMS2PlaybackSpeedType.ToString()
}).ToList();
File.WriteAllText(Path.Combine(outDir, "sprites.json"), JsonSerializer.Serialize(sprites, opt));

// ---- objects: sprite mapping / flags / parent
var objects = Data.GameObjects.Select(o => new {
    name = o.Name?.Content,
    sprite = N(o.Sprite),
    mask = N(o.TextureMaskId),
    visible = o.Visible, solid = o.Solid, persistent = o.Persistent,
    depth = o.Depth,
    parent = N(o.ParentId)
}).ToList();
File.WriteAllText(Path.Combine(outDir, "objects.json"), JsonSerializer.Serialize(objects, opt));

// ---- rooms: size, instances, tile layers
var rooms = Data.Rooms.Select(r => new {
    name = r.Name?.Content,
    w = r.Width, h = r.Height, speed = r.Speed, persistent = r.Persistent,
    creationCode = N(r.CreationCodeId),
    views = r.Views.Where(v => v.Enabled).Select(v => new { v.ViewX, v.ViewY, v.ViewWidth, v.ViewHeight, v.PortX, v.PortY, v.PortWidth, v.PortHeight, follow = N(v.ObjectId) }).ToList(),
    instances = r.GameObjects.Select(g => new {
        id = g.InstanceID,
        obj = N(g.ObjectDefinition),
        x = g.X, y = g.Y,
        sx = g.ScaleX, sy = g.ScaleY, rot = g.Rotation,
        imgSpeed = g.ImageSpeed, imgIndex = g.ImageIndex,
        code = N(g.CreationCode)
    }).ToList(),
    layers = r.Layers.Select(l => new {
        name = l.LayerName?.Content,
        type = l.LayerType.ToString(),
        depth = l.LayerDepth,
        visible = l.IsVisible,
        xoff = l.XOffset, yoff = l.YOffset,
        bg = l.BackgroundData == null ? null : new {
            sprite = N(l.BackgroundData.Sprite),
            tiledH = l.BackgroundData.TiledHorizontally, tiledV = l.BackgroundData.TiledVertically,
            stretch = l.BackgroundData.Stretch, fg = l.BackgroundData.Foreground,
            color = l.BackgroundData.Color, visible = l.BackgroundData.Visible
        },
        instIds = l.InstancesData == null ? null : l.InstancesData.Instances.Select(i => i.InstanceID).ToList(),
        tiles = l.TilesData == null ? null : new {
            tileset = N(l.TilesData.Background),
            tilesX = l.TilesData.TilesX, tilesY = l.TilesData.TilesY,
            data = l.TilesData.TileData == null ? null : l.TilesData.TileData.Select(row => row.ToArray()).ToList()
        }
    }).ToList()
}).ToList();
File.WriteAllText(Path.Combine(outDir, "rooms.json"), JsonSerializer.Serialize(rooms, opt));

// ---- tilesets (backgrounds)
var tilesets = Data.Backgrounds.Select(b => new {
    name = b.Name?.Content,
    tileW = b.GMS2TileWidth, tileH = b.GMS2TileHeight,
    borderX = b.GMS2OutputBorderX, borderY = b.GMS2OutputBorderY,
    columns = b.GMS2TileColumns, count = b.GMS2TileCount,
    frames = b.GMS2TileIds.Count
}).ToList();
File.WriteAllText(Path.Combine(outDir, "tilesets.json"), JsonSerializer.Serialize(tilesets, opt));

Console.WriteLine($"DONE sprites={sprites.Count} objects={objects.Count} rooms={rooms.Count} tilesets={tilesets.Count}");
