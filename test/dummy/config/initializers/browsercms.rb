Cms.attachment_file_permission = 0640

# A prefix that should be applied to all tables. New projects will start out with this prefix, so having it set to in the
# core project is a reasonable default.
#
# @todo It is worth testing without a prefix to make sure upgrading projects (from 3.3.x and earlier) will work.
Cms.table_prefix = "cms_"