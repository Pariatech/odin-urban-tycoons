package game

import "core:log"
import "core:strings"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

Textures_Context :: struct {
	textures: map[string]Texture,
}

Texture :: struct {
	handle:   u32,
	uploaded: bool,
}

bind_texture_from_path :: proc(
	using ctx: ^Textures_Context,
	path: string,
) -> bool {
	tex, ok := &textures[path]
	if !ok {
		textures[path] = {}
		tex = &textures[path]
	}

	if !tex.uploaded {
		gl.TexParameteri(gl.TEXTURE, gl.TEXTURE_WRAP_S, gl.REPEAT)
		gl.TexParameteri(gl.TEXTURE, gl.TEXTURE_WRAP_T, gl.REPEAT)

		gl.TexParameteri(
			gl.TEXTURE_2D,
			gl.TEXTURE_MIN_FILTER,
			gl.LINEAR_MIPMAP_LINEAR,
		)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

		max_anisotropy: f32
		gl.GetFloatv(gl.MAX_TEXTURE_MAX_ANISOTROPY, &max_anisotropy)
		gl.TexParameterf(
			gl.TEXTURE_2D,
			gl.TEXTURE_MAX_ANISOTROPY,
			max_anisotropy,
		)

		stbi.set_flip_vertically_on_load(0)
		stbi.set_flip_vertically_on_load_thread(false)

		w, h: i32
		pixels := stbi.load(
			strings.unsafe_string_to_cstring(path),
			&w,
			&h,
			nil,
			4,
		)
		defer stbi.image_free(pixels)

		if pixels == nil {
			log.error("Failed to load texture: ", path)
			return false
		}

		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGBA8,
			w,
			h,
			0,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			nil,
		)

		gl.GenerateMipmap(gl.TEXTURE_2D_ARRAY)

		tex.uploaded = true
	}

	bind_texture_from_texture(tex)

	return true
}

bind_texture_from_texture :: proc(using tex: ^Texture) {
	gl.BindTexture(gl.TEXTURE_2D, handle)
}

bind_texture :: proc {
	bind_texture_from_path,
	bind_texture_from_texture,
}
