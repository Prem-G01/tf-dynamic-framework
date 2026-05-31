data "archive_file" "function_zip" {

  for_each = var.functions

  type = "zip"

  source_dir = "${path.root}/../Functions/${replace(each.value.function_name, "-function", "")}"

  output_path = "${path.root}/tmp/${each.value.function_name}.zip"
}

resource "google_storage_bucket_object" "function_zip" {

  for_each = var.functions

  name   = "${each.value.function_name}.zip"

  bucket = each.value.source_bucket

  source = data.archive_file.function_zip[each.key].output_path
}