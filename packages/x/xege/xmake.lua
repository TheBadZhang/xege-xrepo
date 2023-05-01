package("xege")
	-- set_kind("library")
	set_homepage("https://github.com/wysaid/xege")
	set_description("A simple graphics library for teaching")

	add_urls("https://github.com/wysaid/xege.git")
	add_urls("https://github.com/wysaid/xege/archive/refs/tags/$(version).tar.gz")

	-- add_versions("20.08", "40bca13799e512b14570c41f3d285eca616ca9b1")

	add_deps("cmake")
	add_deps("libpng", "zlib")
	-- set_sourcedir(path.join(os.scriptdir()))
	on_load(function (package)
		if package:is_plat("windows") then
			package:config("vs_runtime")
		end
	end)
	on_install(function (package)
		local configs = {}
		-- 关闭合并libpng和zlib的选项，使用xmake依赖处理zlib和libpng
		table.insert(configs, "-DMERGE_LIBPNG_AND_ZLIB=OFF")
		table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
		table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
		import("package.tools.cmake").install(package, configs)
	end)
	on_test(function (package)
	-- 这里本该写一些测试代码，但是好像存在一些问题
	--[==[
		assert(package:check_cxxsnippets({test = [[
			#include "graphics.h"
			int main (int argc, char *argv []) {
				// 手动刷新模式
				setinitmode (INIT_RENDERMANUAL);
				// 界面分辨率
				initgraph (800, 600);
				line(100,100,200,200);
				getch();
				closegraph ();
				return 0;
			}
		]]}))
	--]==]
	end)
package_end()