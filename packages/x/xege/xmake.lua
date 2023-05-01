package("xege")
	-- set_kind("library")
	set_homepage("https://github.com/wysaid/xege")
	set_description("A simple graphics library for teaching")

	add_urls("https://github.com/wysaid/xege.git")
	add_urls("https://github.com/wysaid/xege/archive/refs/tags/$(version).tar.gz")

	-- add_versions("20.08", "40bca13799e512b14570c41f3d285eca616ca9b1")


	add_deps("cmake")
	add_deps("libpng", "zlib")
	-- set_sourcedir(".")

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
		os.cp("src/*.h", package:installdir("include"))
		os.cp("src/ege", package:installdir("include/ege"))

		package:add("includedirs", "include")
		package:add("linkdirs", "lib")
		-- package:add("links", "graphics64")

		-- 不知道为什么，好像mingw编译器导出的选项有问题
		-- 现在只有 VS 的编译是正常的
		if package:is_plat("mingw") then
			local third_lib = {"gdiplus","gdi32","imm32","msimg32","ole32","oleaut32","uuid","winmm"}
			for _,v in pairs(third_lib) do
				package:add("links", v)
			end
			os.cp(package:cachedir().."\\build_"..package:buildhash():sub(1,8).."\\libgraphics*.a", package:installdir("lib"))
		end
	end)

	-- 测试库安装是否正常
	on_test(function (package)
		-- assert(package:has_cxxfuncs("initgraph", {includes = "graphics.h"}))
		assert(package:check_cxxsnippets({test = [[
			#include <graphics.h>
			int main (int argc, char *argv []) {
				setinitmode (INIT_RENDERMANUAL);
				initgraph (800, 600);
				line(100,100,200,200);
				getch();
				closegraph ();
				return 0;
			}
		]]}))
	end)
package_end()