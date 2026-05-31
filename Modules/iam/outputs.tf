output "iam_members" {

  value = {

    for k,v in google_project_iam_member.bindings :

    k => {
      role   = v.role
      member = v.member
    }
  }
}