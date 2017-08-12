
//
// Injects Swift relevant tasks into gradle build process
// Mostly these are performed by scripts in ~/.gradle/scripts
// installed when the plugin is setup by "create_scripts.sh"
//

package net.zhuoweizhang.swiftandroid

import org.gradle.api.*
import org.gradle.api.tasks.*

public class SwiftAndroidPlugin implements Plugin<Project> {
	@Override
	public void apply(Project project) {
        Task generateSwiftTask = createScriptTask(project, "generateSwift", "generate-swift.sh")
        Task compileSwiftTask = createScriptTask(project, "compileSwift", "swift-build.sh")
		Task copySwiftStdlibTask = createCopyStdlibTask(project, "copySwiftStdlib")
		Task copySwiftTask = createCopyTask(project, "copySwift")
		copySwiftTask.dependsOn("compileSwift", "copySwiftStdlib")
		Task cleanSwiftTask = project.task(
			type: Delete, "cleanSwift") {
			// I don't trust Swift Package Manager's --clean
			delete "src/main/swift/.build"
		}
		project.afterEvaluate {
			// according to Protobuf gradle plugin, the Android variants are only available here
			// TODO: read those variants; we only support debug right now
            Task compileNdkTask = project.tasks.getByName("compileDebugNdk")
            compileNdkTask.dependsOn("copySwift")
            Task preBuildTask = project.tasks.getByName("preBuild")
            preBuildTask.dependsOn("generateSwift")
			Task cleanTask = project.tasks.getByName("clean")
			cleanTask.dependsOn("cleanSwift")
		}
	}
	public static String getScriptRoot() {
		return System.getenv("HOME")+"/.gradle/scripts/"
	}

    public static Task createScriptTask(Project project, String name, String script) {
        return project.task(type: Exec, name) {
            commandLine(getScriptRoot()+script)
            workingDir("src/main/swift")
        }
    }
    public static Task createCopyStdlibTask(Project project, String name) {
        return project.task(type: Exec, name) {
            commandLine(getScriptRoot()+"copy-libraries.sh",
                "src/main/jniLibs/armeabi-v7a")
        }
    }
	public static Task createCopyTask(Project project, String name) {
		return project.task(type: Copy, name) {
			from("src/main/swift/.build/debug")
			include("*.so")
			into("src/main/jniLibs/armeabi-v7a")
		}
	}
}
