extends Control
## Painted native UI background. No textures, browser DOM, external URLs or server.

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()


func _draw() -> void:
    var width: float = size.x
    var height: float = size.y
    draw_rect(Rect2(Vector2.ZERO, size), Color("#07111b"))

    var accent_shape := PackedVector2Array([
        Vector2(width * 0.47, 0.0),
        Vector2(width, 0.0),
        Vector2(width, height * 0.67),
        Vector2(width * 0.74, height * 0.92),
        Vector2(width * 0.36, height * 0.15),
    ])
    draw_colored_polygon(accent_shape, Color("#0b2532"))

    var secondary_shape := PackedVector2Array([
        Vector2(width * 0.76, 0.0),
        Vector2(width, 0.0),
        Vector2(width, height * 0.38),
    ])
    draw_colored_polygon(secondary_shape, Color("#173545"))

    var line_color := Color(0.23, 0.48, 0.57, 0.14)
    var x: float = 0.0
    while x < width:
        draw_line(Vector2(x, 0.0), Vector2(x, height), line_color, 1.0)
        x += 64.0

    var y: float = 0.0
    while y < height:
        draw_line(Vector2(0.0, y), Vector2(width, y), line_color, 1.0)
        y += 64.0

    draw_line(Vector2(width * 0.60, 0.0), Vector2(width, height * 0.56), Color("#c38942"), 2.0, true)
