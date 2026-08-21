allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Workaround for flutter_avif_android 3.1.0, which ships the SAME plugin class
// twice: `src/main/java/.../FlutterAvifPlugin.java` and
// `src/main/kotlin/.../FlutterAvifPlugin.kt`. Both declare
// `com.teknorota.flutter_avif.FlutterAvifPlugin`, so the Kotlin compiler fails
// with "Redeclaration: class FlutterAvifPlugin".
//
// Older AGP silently ignored the stray Java file; current toolchains compile
// both source sets and collide. Neither class does any AVIF work (decoding goes
// through Rust FFI) — they are `getPlatformVersion` stubs — so dropping the
// Java copy and keeping the Kotlin one is behaviour-preserving.
//
// Remove this block once the upstream package deletes the duplicate file.
subprojects {
    if (project.name == "flutter_avif_android") {
        project.plugins.withId("com.android.library") {
            project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                sourceSets.getByName("main") {
                    java.setSrcDirs(listOf("src/main/kotlin"))
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
