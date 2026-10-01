allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// 本机可选择已完整安装的 NDK；同一版本同时应用于 app 和原生插件。
val reelDeckNdk = providers.gradleProperty("reeldeckNdkVersion").orNull
if (reelDeckNdk != null) {
    subprojects {
        afterEvaluate {
            val androidExtension = extensions.findByName("android")
            androidExtension?.javaClass?.methods
                ?.firstOrNull { it.name == "setNdkVersion" && it.parameterCount == 1 }
                ?.invoke(androidExtension, reelDeckNdk)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
