package("xege")
	-- set_kind("library")
	set_homepage("https://github.com/wysaid/xege")
	set_description("A simple graphics library for teaching")

	add_urls("https://github.com/wysaid/xege.git")
	add_urls("https://github.com/wysaid/xege/archive/refs/tags/$(version).tar.gz")

	-- add_versions("20.08", "40bca13799e512b14570c41f3d285eca616ca9b1")


	add_deps("cmake")
	add_deps("libpng", "zlib")
	set_sourcedir(".")

	on_load(function (package)

		package:add("includedirs", "include")  -- 添加头文件搜索路径
		package:add("linkdirs", "lib")         -- 添加库文件搜索路径
		package:add("links", "graphics64")     -- 好像不用添加链接库也可以编译通过

		if package:is_plat("windows") then
			package:config("vs_runtime")
		elseif package:is_plat("mingw") then
			local third_lib = {"gdiplus","gdi32","imm32","msimg32","ole32","oleaut32","uuid","winmm"}
			for _,v in pairs(third_lib) do
				print(v)
				package:add("syslinks", v)
			end
		end
	end)

	on_install(function (package)
		-- print("脚本路径", package:scriptdir())
		-- print(package:cachedir().."\\build_"..package:buildhash():sub(1,8).."\\libgraphics*.a")
		local configs = {}

		-- 关闭合并libpng和zlib的选项，使用xmake依赖处理zlib和libpng
		table.insert(configs, "-DMERGE_LIBPNG_AND_ZLIB=OFF")
		-- table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
		-- table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
		table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
		import("package.tools.cmake").install(package, configs)

		-- 导出头文件
		local include_dir = package:installdir("include")                 -- 头文件导出路径
		local file_or_dir = { "src/ege.h", "src/graphics.h", "src/ege" }  -- 导出的头文件和目录
		for _,v in ipairs(file_or_dir) do                                 -- 遍历导出的文件和目录
			os.cp(v, include_dir)
		end

		-- 导出构建出来的库文件到安装路径中
		if package:is_plat("mingw") then
			os.cp(package:cachedir().."\\build_"..package:buildhash():sub(1,8).."\\libgraphics*.a", package:installdir("lib"))
		end
	end)

	on_test(function (package)

		-- initgraph无法消歧义，所以这个测试无法使用
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