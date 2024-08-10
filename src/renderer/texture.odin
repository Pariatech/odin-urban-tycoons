package renderer

import "core:fmt"
import "core:log"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

TEXTURE_SIZE :: 128

load_texture_2D_array :: proc(
	paths: [$T]cstring,
	width: i32 = TEXTURE_SIZE,
	height: i32 = TEXTURE_SIZE,
) -> (
	ok: bool = true,
) {
	textures :: len(paths)

	if (textures == 0) {
		fmt.println("No textures to load.")
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexImage3D(
		gl.TEXTURE_2D_ARRAY,
		0,
		gl.RGBA8,
		width,
		height,
		textures,
        0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		nil,
	)

	for path, i in paths {
		w, h: i32
		pixels := stbi.load(path, &w, &h, nil, 4)
		defer stbi.image_free(pixels)

		if pixels == nil {
			log.error("Failed to load texture: ", path)
			return false
		}

		if w != width {
			log.error(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				width,
				" got: ",
				w,
			)
			return false
		}

		if h != height {
			log.error(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				height,
				" got: ",
				h,
			)
			return false
		}

		gl.TexSubImage3D(
			gl.TEXTURE_2D_ARRAY,
			0,
			0,
			0,
			i32(i),
			width,
			height,
			1,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			pixels,
		)
	}

	gl.GenerateMipmap(gl.TEXTURE_2D_ARRAY)

	return
}
