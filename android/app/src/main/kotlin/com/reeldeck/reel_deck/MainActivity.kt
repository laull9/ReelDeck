package com.reeldeck.reel_deck

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private val worker = Executors.newSingleThreadExecutor()
    private val extensions = setOf("mp4", "mkv", "mov", "m4v", "webm", "avi", "mpg", "mpeg", "ts", "m2ts", "flv", "wmv", "jpg", "jpeg", "png", "webp", "bmp", "gif")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "reeldeck/storage")
            .setMethodCallHandler { call, result ->
                if (call.method == "pick") {
                    if (pending != null) { result.error("busy", "目录选择器已打开", null); return@setMethodCallHandler }
                    pending = result
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                    startActivityForResult(intent, 431)
                    return@setMethodCallHandler
                }
                if (call.method == "readImage") {
                    worker.execute {
                        try {
                            val uri = Uri.parse(call.argument<String>("uri") ?: error("缺少图片位置"))
                            val bytes = contentResolver.openInputStream(uri)?.use { stream ->
                                val output = java.io.ByteArrayOutputStream()
                                val buffer = ByteArray(65536)
                                while (true) {
                                    val count = stream.read(buffer)
                                    if (count < 0) break
                                    if (output.size() + count > 64 * 1024 * 1024) error("图片超过 64 MiB")
                                    output.write(buffer, 0, count)
                                }
                                output.toByteArray()
                            }
                            runOnUiThread { result.success(bytes) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("image", e.message, null) }
                        }
                    }
                    return@setMethodCallHandler
                }
                worker.execute {
                    try {
                        val locator = call.argument<String>("locator") ?: ""
                        val tree = Uri.parse(locator)
                        val root = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
                        val value: Any? = when (call.method) {
                            "resolve" -> {
                                contentResolver.query(root, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null)?.use {
                                    if (it.moveToFirst()) mapOf("path" to locator, "locator" to locator) else null
                                }
                            }
                            "scan" -> scan(tree, DocumentsContract.getTreeDocumentId(tree), "", call.argument<Boolean>("recursive") ?: true)
                            "media" -> resolveMedia(tree, call.argument<String>("path") ?: "")
                            else -> null
                        }
                        runOnUiThread { result.success(value) }
                    } catch (e: Exception) {
                        runOnUiThread { result.error("storage", e.message, null) }
                    }
                }
            }
    }

    @Deprecated("Activity result API required by FlutterActivity bridge")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 431) return
        val result = pending ?: return
        pending = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) { result.success(null); return }
        try {
            contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val root = DocumentsContract.buildDocumentUriUsingTree(uri, DocumentsContract.getTreeDocumentId(uri))
            var name = "视频目录"
            contentResolver.query(root, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use {
                if (it.moveToFirst()) name = it.getString(0)
            }
            result.success(mapOf("name" to name, "path" to uri.toString(), "locator" to uri.toString()))
        } catch (e: Exception) { result.error("permission", e.message, null) }
    }

    private fun scan(tree: Uri, id: String, prefix: String, recursive: Boolean): List<Map<String, Any>> {
        val result = mutableListOf<Map<String, Any>>()
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, id)
        val columns = arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID, DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE, DocumentsContract.Document.COLUMN_SIZE, DocumentsContract.Document.COLUMN_LAST_MODIFIED)
        val cursor = contentResolver.query(children, columns, null, null, null) ?: error("无法读取目录")
        cursor.use {
            while (it.moveToNext()) {
                val childId = it.getString(0)
                val name = it.getString(1)
                val path = if (prefix.isEmpty()) name else "$prefix/$name"
                if (it.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR) {
                    if (recursive) result.addAll(scan(tree, childId, path, true))
                } else if (extensions.contains(name.substringAfterLast('.', "").lowercase())) {
                    result.add(mapOf("path" to path, "size" to it.getLong(3), "modified" to it.getLong(4)))
                }
            }
        }
        return result
    }

    private fun resolveMedia(tree: Uri, path: String): String? {
        var id = DocumentsContract.getTreeDocumentId(tree)
        for (part in path.split('/')) {
            var found: String? = null
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, id)
            contentResolver.query(children, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use {
                while (it.moveToNext()) { if (it.getString(1) == part) { found = it.getString(0); break } }
            }
            id = found ?: return null
        }
        return DocumentsContract.buildDocumentUriUsingTree(tree, id).toString()
    }

    override fun onDestroy() { worker.shutdown(); super.onDestroy() }
}
